"""Benchmark download speeds from WorldPop, CHIRPS, and CDS (ERA5-Land) APIs.

Measures download throughput and wall-clock time for each data source,
producing a PDF report with embedded plots, a markdown report, and traceroute
analysis. Designed to be run from multiple networks for comparison.

Usage:
  # Quick test (skip CDS and full CHIRPS download)
  uv run python examples/benchmark_download_speeds.py --iterations 1 --skip-cds --skip-chirps-full

  # Full benchmark
  uv run python examples/benchmark_download_speeds.py --iterations 3

  # Custom region (bbox is auto-derived from the country code)
  uv run python examples/benchmark_download_speeds.py --country-code VNM
"""

import argparse
import dataclasses
from datetime import date as date_type
import multiprocessing
import os
import platform
import socket
import statistics
import subprocess
import tempfile
import time
from datetime import datetime, timezone

import httpx

# Optional imports - gracefully degrade if missing
try:
    import rioxarray  # noqa: F401

    HAS_RIOXARRAY = True
except ImportError:
    HAS_RIOXARRAY = False  # type: ignore[assignment]

try:
    from ecmwf.datastores import Client as CDSClient

    HAS_CDS = True
except ImportError:
    HAS_CDS = False  # type: ignore[assignment]

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

DEFAULT_COUNTRY_CODE = "SLE"
DEFAULT_ITERATIONS = 3
DEFAULT_OUTPUT_DIR = "output"
CHUNK_SIZE = 64 * 1024  # 64 KB chunks for streaming downloads

# Approximate bounding boxes for countries commonly used with these APIs.
# Format: (west, south, east, north)
COUNTRY_BBOXES: dict[str, tuple[float, float, float, float]] = {
    "SLE": (-13.5, 6.9, -10.2, 10.0),
    "VNM": (102.1, 8.4, 109.5, 23.4),
    "ETH": (33.0, 3.4, 48.0, 14.9),
    "NGA": (2.7, 4.3, 14.7, 13.9),
    "KEN": (33.9, -4.7, 41.9, 5.5),
    "GHA": (-3.3, 4.7, 1.2, 11.2),
    "MOZ": (30.2, -26.9, 40.8, -10.5),
    "TZA": (29.3, -11.7, 40.4, -1.0),
    "UGA": (29.6, -1.5, 35.0, 4.2),
    "MWI": (32.7, -17.1, 35.9, -9.4),
    "LAO": (100.1, 13.9, 107.7, 22.5),
    "NOR": (4.5, 58.0, 31.1, 71.2),
}

API_SERVERS = {
    "WorldPop": "data.worldpop.org",
    "CHIRPS": "data.chc.ucsb.edu",
    "CDS": "cds.climate.copernicus.eu",
}


def worldpop_url(year: int, country_code: str, version: str) -> str:
    cc = country_code.lower()
    CC = country_code.upper()
    if version == "global1":
        return f"https://data.worldpop.org/GIS/Population/Global_2000_2020/{year}/{CC}/{cc}_ppp_{year}_UNadj.tif"
    return (
        f"https://data.worldpop.org/GIS/Population/Global_2015_2030/R2025A/"
        f"{year}/{CC}/v1/100m/constrained/{cc}_pop_{year}_CN_100m_R2025A_v1.tif"
    )


def chirps_url(year: int, month: int, day: int) -> str:
    return (
        f"https://data.chc.ucsb.edu/products/CHIRPS/v3.0/daily/final/rnl/"
        f"{year}/chirps-v3.0.rnl.{year}.{month:02d}.{day:02d}.tif"
    )


# ---------------------------------------------------------------------------
# Host info & traceroute
# ---------------------------------------------------------------------------


def get_host_info() -> dict[str, str]:
    """Get public IP address and approximate location via ip-api.com."""
    info: dict[str, str] = {
        "hostname": socket.gethostname(),
        "platform": f"{platform.system()} {platform.machine()}",
        "public_ip": "unknown",
        "location": "unknown",
        "isp": "unknown",
    }
    try:
        resp = httpx.get("https://ipinfo.io/json", timeout=5)
        if resp.is_success:
            data = resp.json()
            info["public_ip"] = data.get("ip", "unknown")
            city = data.get("city", "")
            region = data.get("region", "")
            country = data.get("country", "")
            info["location"] = ", ".join(p for p in [city, region, country] if p)
            info["isp"] = data.get("org", "unknown")
    except Exception:
        pass
    return info


def run_traceroute(host: str, max_hops: int = 30) -> str:
    """Run traceroute to a host and return the output as a string."""
    if platform.system() == "Windows":
        cmd = ["tracert", "-h", str(max_hops), "-w", "2000", host]
    else:
        # -q 1: one probe per hop (3x faster than default 3)
        # -w 2: 2s wait per probe (enough for intercontinental)
        cmd = ["traceroute", "-m", str(max_hops), "-w", "2", "-q", "1", host]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=180)
        return result.stdout or result.stderr or "(no output)"
    except FileNotFoundError:
        return "(traceroute not available on this system)"
    except subprocess.TimeoutExpired:
        return "(traceroute timed out after 180s)"
    except Exception as e:
        return f"(traceroute error: {e})"


def count_hops(traceroute_output: str) -> int:
    """Count the number of responsive hops in traceroute/tracert output."""
    count = 0
    for line in traceroute_output.strip().split("\n")[1:]:  # skip header
        stripped = line.strip()
        if not stripped or stripped.startswith("traceroute") or stripped.startswith("Tracing"):
            continue
        # Skip non-hop lines
        if "* * *" in stripped or "Request timed out" in stripped:
            continue
        if stripped.startswith("Trace complete"):
            continue
        count += 1
    return count


# ---------------------------------------------------------------------------
# Result dataclass
# ---------------------------------------------------------------------------


@dataclasses.dataclass
class BenchmarkResult:
    api_name: str
    test_name: str
    iteration: int
    file_size_bytes: int
    download_time_s: float
    total_time_s: float
    speed_mbps: float  # MB/s (megabytes, not megabits); 0 when not meaningful (e.g. CHIRPS bbox)
    error: str | None = None


# ---------------------------------------------------------------------------
# Benchmark helpers
# ---------------------------------------------------------------------------


def _stream_download(url: str, timeout: int = 300) -> tuple[float, int, float]:
    """Download a URL with streaming, return (download_time, size, ttfb)."""
    t0 = time.monotonic()
    with httpx.stream("GET", url, timeout=timeout, follow_redirects=True) as resp:
        resp.raise_for_status()
        ttfb = time.monotonic() - t0

        size = 0
        t_dl_start = time.monotonic()
        with tempfile.NamedTemporaryFile(delete=True) as tmp:
            for chunk in resp.iter_bytes(chunk_size=CHUNK_SIZE):
                tmp.write(chunk)
                size += len(chunk)
    download_time = time.monotonic() - t_dl_start
    return download_time, size, ttfb


# ---------------------------------------------------------------------------
# Benchmark functions
# ---------------------------------------------------------------------------


def benchmark_worldpop(
    iterations: int, country_code: str, year: int, version: str
) -> list[BenchmarkResult]:
    api_name = "WorldPop"
    test_name = f"worldpop_{version}"
    url = worldpop_url(year, country_code, version)

    results: list[BenchmarkResult] = []
    for i in range(1, iterations + 1):
        print(f"  [{test_name}] iteration {i}/{iterations} ...", end=" ", flush=True)
        try:
            t0 = time.monotonic()
            _, size, _ = _stream_download(url)
            total = time.monotonic() - t0
            # Speed based on total wall-clock time (includes connection setup)
            speed = (size / 1_000_000) / total if total > 0 else 0
            print(f"{size / 1_000_000:.1f} MB in {total:.1f}s ({speed:.2f} MB/s)")
            results.append(
                BenchmarkResult(api_name, test_name, i, size, total, total, speed)
            )
        except Exception as e:
            print(f"ERROR: {e}")
            results.append(
                BenchmarkResult(api_name, test_name, i, 0, 0, 0, 0, error=str(e))
            )
    return results


def benchmark_chirps_full(iterations: int, year: int, month: int, day: int) -> list[BenchmarkResult]:
    api_name = "CHIRPS"
    test_name = "chirps_full"
    url = chirps_url(year, month, day)

    results: list[BenchmarkResult] = []
    for i in range(1, iterations + 1):
        print(f"  [{test_name}] iteration {i}/{iterations} ...", end=" ", flush=True)
        try:
            t0 = time.monotonic()
            _, size, _ = _stream_download(url, timeout=600)
            total = time.monotonic() - t0
            speed = (size / 1_000_000) / total if total > 0 else 0
            print(f"{size / 1_000_000:.1f} MB in {total:.1f}s ({speed:.2f} MB/s)")
            results.append(
                BenchmarkResult(api_name, test_name, i, size, total, total, speed)
            )
        except Exception as e:
            print(f"ERROR: {e}")
            results.append(
                BenchmarkResult(api_name, test_name, i, 0, 0, 0, 0, error=str(e))
            )
    return results


def _chirps_bbox_single(url: str, bbox: tuple[float, float, float, float]) -> tuple[float, int]:
    """Run a single CHIRPS bbox download in isolation. Returns (total_time, decoded_bytes).

    Called as a subprocess target to avoid GDAL's in-process caches
    (block cache, dataset cache, connection pool) which make iterations
    2+ appear instant even after VSICurlClearCache().
    """
    import rioxarray  # noqa: F811

    xmin, ymin, xmax, ymax = bbox
    t0 = time.monotonic()
    da = rioxarray.open_rasterio(url, chunks=None)
    da = da.rio.clip_box(minx=xmin, miny=ymin, maxx=xmax, maxy=ymax)
    da.load()
    total = time.monotonic() - t0
    return total, int(da.nbytes)


def _chirps_bbox_worker(url: str, bbox: tuple[float, float, float, float], q: multiprocessing.Queue) -> None:  # type: ignore[type-arg]
    """Subprocess target for CHIRPS bbox benchmark."""
    try:
        result = _chirps_bbox_single(url, bbox)
        q.put(("ok", result))
    except Exception as e:
        q.put(("error", str(e)))


def benchmark_chirps_bbox(
    iterations: int, year: int, month: int, day: int, bbox: tuple[float, float, float, float]
) -> list[BenchmarkResult]:
    api_name = "CHIRPS"
    test_name = "chirps_bbox"
    url = chirps_url(year, month, day)

    results: list[BenchmarkResult] = []
    for i in range(1, iterations + 1):
        print(f"  [{test_name}] iteration {i}/{iterations} ...", end=" ", flush=True)
        try:
            # Run in a separate process so GDAL starts with a clean cache.
            # We time from the parent to include process spawn, module import,
            # and IPC overhead — reflecting what the user actually waits for.
            # Using multiprocessing.Process so we can kill a hung worker.
            q: multiprocessing.Queue = multiprocessing.Queue()  # type: ignore[type-arg]

            t0 = time.monotonic()
            proc = multiprocessing.Process(target=_chirps_bbox_worker, args=(url, bbox, q))
            proc.start()
            proc.join(timeout=300)

            if proc.is_alive():
                proc.kill()
                proc.join()
                raise TimeoutError("CHIRPS bbox download timed out after 300s")

            if proc.exitcode != 0:
                raise RuntimeError(f"Worker process exited with code {proc.exitcode}")

            status, payload = q.get_nowait()
            if status == "error":
                raise RuntimeError(payload)

            _, decoded_size = payload
            total = time.monotonic() - t0

            print(f"decoded {decoded_size / 1_000_000:.2f} MB in {total:.1f}s (wall-clock)")
            results.append(
                BenchmarkResult(api_name, test_name, i, 0, total, total, 0.0)
            )
        except Exception as e:
            print(f"ERROR: {e}")
            results.append(
                BenchmarkResult(api_name, test_name, i, 0, 0, 0, 0, error=str(e))
            )
    return results


def benchmark_cds(
    iterations: int, bbox: tuple[float, float, float, float], year: int, month: int
) -> list[BenchmarkResult]:
    api_name = "CDS"
    test_name = "cds_era5land"
    xmin, ymin, xmax, ymax = bbox

    # Let the client determine if credentials are valid — it may support
    # env vars, config files, or other auth methods we don't know about.
    try:
        client = CDSClient()
        client.check_authentication()
    except Exception as e:
        print(f"  [cds_era5land] SKIPPED: {e}")
        print("    Set ECMWF_DATASTORES_URL + ECMWF_DATASTORES_KEY in .env or as env vars")
        return []

    params = {
        "variable": ["2m_temperature"],
        "year": str(year),
        "month": [f"{month:02d}"],
        "day": ["01", "02", "03"],  # just 3 days to keep it small
        "time": [f"{h:02d}:00" for h in range(24)],
        "area": [ymax, xmin, ymin, xmax],  # N, W, S, E
        "data_format": "netcdf",
        "download_format": "unarchived",
    }

    results: list[BenchmarkResult] = []
    for i in range(1, iterations + 1):
        print(f"  [{test_name}] iteration {i}/{iterations} ...", end=" ", flush=True)
        try:
            # submit() is a local HTTP call to enqueue the request.
            # download() blocks until the server finishes processing
            # and then transfers the file, so it includes both the
            # server-side queue/processing wait AND the download.
            # We can only reliably measure total wall-clock time.
            t0 = time.monotonic()
            remote = client.submit("reanalysis-era5-land", params)
            t_submitted = time.monotonic()
            submit_time = t_submitted - t0

            with tempfile.NamedTemporaryFile(suffix=".nc", delete=False) as tmp:
                tmp_path = tmp.name
            try:
                remote.download(tmp_path)
                t_done = time.monotonic()

                size = os.path.getsize(tmp_path)
                total = t_done - t0
                wait_and_download = t_done - t_submitted
                # We cannot separate server queue time from transfer time
                # since remote.download() blocks for both.
                # speed_mbps=0 signals "not a throughput measurement".
                print(
                    f"{size / 1_000_000:.2f} MB in {total:.1f}s "
                    f"(submit: {submit_time:.1f}s, wait+dl: {wait_and_download:.1f}s)"
                )
                results.append(
                    BenchmarkResult(
                        api_name, test_name, i, size, total, total, 0.0,
                    )
                )
            finally:
                os.unlink(tmp_path)
        except Exception as e:
            print(f"ERROR: {e}")
            results.append(
                BenchmarkResult(api_name, test_name, i, 0, 0, 0, 0, error=str(e))
            )
    return results


# ---------------------------------------------------------------------------
# Report generation
# ---------------------------------------------------------------------------


import re


def _extract_last_rtt(traceroute_output: str) -> float | None:
    """Extract the RTT (ms) of the last responsive hop."""
    for line in reversed(traceroute_output.strip().split("\n")):
        # Match "286.908 ms", "<1 ms", "0.5 ms"
        matches = re.findall(r"<?(\d+\.?\d*)\s*ms", line)
        if matches:
            return float(matches[-1])
    return None


def _identify_server_location(traceroute_output: str) -> str:
    """Try to identify the server location from traceroute hostnames."""
    lines = traceroute_output.strip().split("\n")
    # Look at the last few responsive hops for identifying hostnames
    keywords = {
        "soton.ac.uk": "University of Southampton, UK",
        "ja.net": "JANET (UK academic network)",
        "ucsb.edu": "UC Santa Barbara, California, USA",
        "cenic.net": "CENIC (California research network)",
        "internet2.edu": "Internet2 (US research network)",
        "ecmwf": "ECMWF, Bologna, Italy",
        "garr.net": "GARR (Italian research network)",
        "cogentco.com": "Cogent Communications",
        "telstraglobal": "Telstra Global (submarine cable)",
        "worldpop": "WorldPop, University of Southampton",
    }
    found = []
    for line in lines[-10:]:
        for keyword, location in keywords.items():
            if keyword in line.lower() and location not in found:
                found.append(location)
    return " → ".join(found) if found else "Unknown"


def _identify_network_path(traceroute_output: str) -> list[str]:
    """Extract major network segments from traceroute."""
    segments: list[str] = []
    seen: set[str] = set()
    networks = {
        "viettel": "Viettel (Vietnam ISP)",
        "telstraglobal": "Telstra Global (submarine cable)",
        "cogentco": "Cogent Communications",
        "ja.net": "JANET (UK academic)",
        "internet2": "Internet2 (US research)",
        "cenic": "CENIC (California)",
        "garr.net": "GARR (Italian research)",
        "soton.ac.uk": "University of Southampton",
        "ucsb.edu": "UC Santa Barbara",
        "ecmwf": "ECMWF",
    }
    for line in traceroute_output.strip().split("\n"):
        for keyword, name in networks.items():
            if keyword in line.lower() and name not in seen:
                segments.append(name)
                seen.add(name)
    return segments


def _generate_findings(
    results: list[BenchmarkResult],
    host_info: dict[str, str],
    traceroutes: dict[str, str],
) -> list[str]:
    """Generate key findings and analysis as a list of markdown lines."""
    lines: list[str] = []
    lines.append("## Key Findings\n")

    # Group results
    tests: dict[str, list[BenchmarkResult]] = {}
    for r in results:
        if r.error is None:
            tests.setdefault(r.test_name, []).append(r)

    # 1. Overall speed ranking
    lines.append("### Download Performance\n")

    # Rank by median total time (all tests)
    ranked = []
    for t, rs in tests.items():
        median_time = statistics.median(r.total_time_s for r in rs)
        median_speed = statistics.median(r.speed_mbps for r in rs)
        size = rs[0].file_size_bytes
        ranked.append((t, rs[0].api_name, median_time, median_speed, size))
    ranked.sort(key=lambda x: x[2], reverse=True)

    if ranked:
        slowest = ranked[0]
        fastest = ranked[-1]
        lines.append(
            f"- **Slowest:** {slowest[1]} ({slowest[0]}) at {slowest[2]:.0f}s median"
        )
        if slowest[3] > 0:
            lines.append(f"  ({slowest[3]:.2f} MB/s for {_fmt_size(slowest[4])})")
        lines.append(
            f"- **Fastest:** {fastest[1]} ({fastest[0]}) at {fastest[2]:.1f}s median"
        )

    # Throughput comparison
    throughput_tests = [(t, rs) for t, rs in tests.items() if any(r.speed_mbps > 0 for r in rs)]
    if throughput_tests:
        lines.append("")
        lines.append("**Throughput comparison** (streaming downloads only):\n")
        for t, rs in sorted(throughput_tests, key=lambda x: statistics.median(r.speed_mbps for r in x[1])):
            med = statistics.median(r.speed_mbps for r in rs)
            speeds = [r.speed_mbps for r in rs]
            variability = ""
            if len(speeds) > 1:
                lo, hi = min(speeds), max(speeds)
                variability = f" (range: {lo:.3f}–{hi:.3f})"
            lines.append(f"- {rs[0].api_name} ({t}): **{med:.3f} MB/s**{variability}")
        max_speed = max(statistics.median(r.speed_mbps for r in rs) for _, rs in throughput_tests)
        if max_speed < 1.0:
            lines.append("")
            lines.append(
                f"All measured speeds are below 1 MB/s (max: {max_speed:.2f} MB/s). "
                "For reference, a typical broadband connection can sustain 10–100 MB/s to well-connected servers."
            )

    # 2. Server location analysis
    if traceroutes:
        lines.append("")
        lines.append("### Server Locations & Network Paths\n")

        # Filter to traceroutes that actually produced usable data
        # (not error placeholders like "traceroute not available")
        usable_traceroutes = {
            name: out for name, out in traceroutes.items()
            if count_hops(out) > 0
        }

        if not usable_traceroutes:
            lines.append("Traceroute data was not usable for analysis.\n")
        else:
            # Summarize what we can infer — only claim what the data shows
            locations_found = []
            measured_rtts = []
            for api_name, output in usable_traceroutes.items():
                loc = _identify_server_location(output)
                if loc != "Unknown":
                    locations_found.append(f"{api_name} ({loc.split(' → ')[-1]})")
                rtt = _extract_last_rtt(output)
                if rtt is not None:
                    measured_rtts.append(rtt)

            if locations_found:
                summary = f"Based on traceroute hostname analysis: {'; '.join(locations_found)}."
                if measured_rtts and min(measured_rtts) > 100:
                    summary += (
                        f" Round-trip latencies ({min(measured_rtts):.0f}–{max(measured_rtts):.0f}ms) "
                        f"suggest these servers are geographically distant from "
                        f"{host_info.get('location', 'this location')}."
                    )
                lines.append(summary + "\n")
            elif measured_rtts:
                lines.append(
                    "Server locations could not be determined from traceroute hostnames.\n"
                )
            else:
                lines.append(
                    "Traceroute completed but no RTT or location data could be extracted.\n"
                )

        for api_name, output in usable_traceroutes.items():
            rtt = _extract_last_rtt(output)
            location = _identify_server_location(output)
            hops = count_hops(output)
            path = _identify_network_path(output)

            lines.append(f"**{api_name}** (`{API_SERVERS.get(api_name, '')}`)")
            lines.append(f"- Server location: {location}")
            lines.append(f"- Network hops: {hops}")
            if rtt is not None:
                lines.append(f"- Round-trip latency: {rtt:.0f} ms")
            if path:
                lines.append(f"- Network path: {' → '.join(path)}")
            lines.append("")

    # 3. Possible contributing factors (only include claims supported by data)
    if tests:
        lines.append("")
        lines.append("### Possible Contributing Factors\n")

        factors: list[str] = []
        factor_num = 1

        # RTT-based observation (only if traceroute data exists)
        if traceroutes:
            rtts = {name: _extract_last_rtt(out) for name, out in traceroutes.items()}
            hop_counts = {name: count_hops(out) for name, out in traceroutes.items()}
            rtt_range = [v for v in rtts.values() if v is not None]

            if rtt_range and min(rtt_range) > 100:
                rtt_str = f"{min(rtt_range):.0f}–{max(rtt_range):.0f}ms"
                factors.append(
                    f"{factor_num}. **High latency:** Measured round-trip times ({rtt_str}) "
                    f"indicate significant geographic distance between "
                    f"{host_info.get('location', 'this location')} and the servers."
                )
                factor_num += 1

            max_hops_api = max(hop_counts, key=lambda k: hop_counts[k]) if hop_counts else None
            if max_hops_api and hop_counts[max_hops_api] > 20:
                factors.append(
                    f"{factor_num}. **High hop counts:** {max_hops_api} requires "
                    f"{hop_counts[max_hops_api]} network hops from this location, "
                    "increasing the probability of congestion and packet loss."
                )
                factor_num += 1

        # Throughput observation (always available if tests exist)
        throughput_speeds = [
            statistics.median(r.speed_mbps for r in rs)
            for rs in tests.values()
            if any(r.speed_mbps > 0 for r in rs)
        ]
        if throughput_speeds and max(throughput_speeds) < 1.0:
            factors.append(
                f"{factor_num}. **Low throughput:** All measured speeds are below 1 MB/s. "
                "This may indicate bandwidth limitations at the server, network congestion, "
                "or the lack of nearby CDN/mirror servers."
            )
            factor_num += 1

        factors.append(
            f"{factor_num}. **Single-threaded downloads:** The download libraries use single "
            "HTTP connections. Parallel or multi-connection transfers could improve throughput."
        )

        for f in factors:
            lines.append(f)

    # 4. Practical impact — use each API's own measured time (always shown)
    if tests:
        lines.append("")
        lines.append("### Practical Impact\n")
        lines.append(
            "Based on actual measured times from this location, here is how long "
            "typical workloads take:\n"
        )

        lines.append("| Workload | Measured | Extrapolated |")
        lines.append("|----------|--------:|-----------:|")

        for t, rs in tests.items():
            if t == "worldpop_global2":
                med = statistics.median(r.total_time_s for r in rs)
                lines.append(f"| WorldPop 1 country/year (100m) | {_fmt_time(med)} | — |")
                lines.append(f"| WorldPop 5 years (100m) | — | ~{_fmt_time(med * 5)} |")
            elif t == "worldpop_global1":
                med = statistics.median(r.total_time_s for r in rs)
                lines.append(f"| WorldPop 1 country/year (1km) | {_fmt_time(med)} | — |")
            elif t == "chirps_bbox":
                med = statistics.median(r.total_time_s for r in rs)
                lines.append(f"| CHIRPS 1 day (bbox, median) | {_fmt_time(med)} | — |")
                lines.append(f"| CHIRPS 1 month (~30 days, bbox) | — | ~{_fmt_time(med * 30)} |")
            elif t == "chirps_full":
                med = statistics.median(r.total_time_s for r in rs)
                lines.append(f"| CHIRPS 1 day (full global file) | {_fmt_time(med)} | — |")
            elif t == "cds_era5land":
                med = statistics.median(r.total_time_s for r in rs)
                lines.append(f"| ERA5-Land 3 days (1 var, queue+dl) | {_fmt_time(med)} | — |")
                lines.append(f"| ERA5-Land 1 month (1 var, queue+dl) | — | ~{_fmt_time(med * 10)} |")

        lines.append("")
        lines.append(
            "*Extrapolated times assume linear scaling. Actual times may differ due to "
            "server-side caching, rate limiting, or network variability.*"
        )

    # 5. Recommendations (always shown)
    lines.append("")
    lines.append("### Recommendations\n")

    if tests:
        slowest_time = max(
            (statistics.median(r.total_time_s for r in rs), rs[0].api_name)
            for rs in tests.values()
        )
        lines.append(
            f"1. **Pre-download data** before workshops or fieldwork. Don't rely on live "
            f"downloads during sessions — even a single file can take {_fmt_time(slowest_time[0])}."
        )
    else:
        lines.append(
            "1. **Pre-download data** before workshops or fieldwork. Don't rely on live "
            "downloads during sessions."
        )
    lines.append(
        "2. **Use bbox clipping** for CHIRPS when possible. The COG range-request "
        "approach transfers far less data than downloading the full global GeoTIFF."
    )
    lines.append(
        "3. **Cache aggressively.** The dhis2eo download functions skip files that "
        "already exist on disk. Ensure output directories are preserved between runs."
    )
    lines.append(
        "4. **Consider running from a cloud VM** in Europe (e.g. AWS eu-west, GCP europe-west) "
        "for bulk downloads, then transfer the processed results."
    )
    lines.append(
        "5. **Run this benchmark** from each workshop location to set expectations "
        "and plan data preparation accordingly."
    )

    lines.append("")
    return lines


def _fmt_time(seconds: float) -> str:
    if seconds >= 3600:
        return f"{seconds / 3600:.1f}h"
    if seconds >= 60:
        return f"{seconds / 60:.1f}min"
    return f"{seconds:.0f}s"


def _fmt_size(b: int) -> str:
    if b >= 1_000_000:
        return f"{b / 1_000_000:.1f} MB"
    if b >= 1_000:
        return f"{b / 1_000:.1f} KB"
    return f"{b} B"


def generate_report(
    results: list[BenchmarkResult],
    output_dir: str,
    args: argparse.Namespace,
    host_info: dict[str, str],
    traceroutes: dict[str, str],
) -> str:
    os.makedirs(output_dir, exist_ok=True)
    path = os.path.join(output_dir, "benchmark_report.md")

    # Group by test_name
    tests: dict[str, list[BenchmarkResult]] = {}
    for r in results:
        tests.setdefault(r.test_name, []).append(r)

    lines: list[str] = []
    lines.append("# API Download Speed Benchmark Report\n")

    # Host info section
    lines.append("## Network Environment\n")
    lines.append(f"| Property | Value |")
    lines.append(f"|----------|-------|")
    lines.append(f"| Date | {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')} |")
    lines.append(f"| Hostname | {host_info['hostname']} |")
    lines.append(f"| Platform | {host_info['platform']} |")
    lines.append(f"| Public IP | {host_info['public_ip']} |")
    lines.append(f"| Location | {host_info['location']} |")
    lines.append(f"| ISP | {host_info['isp']} |")
    lines.append(f"| Country/Region | {args.country_code} (bbox: {args.bbox}) |")
    lines.append(f"| Iterations | {args.iterations} |")
    lines.append("")

    # Summary table
    lines.append("## Summary\n")
    lines.append("| API | Test | File Size | Median Speed (MB/s) | Mean Total Time (s) | Errors |")
    lines.append("|-----|------|-----------|--------------------:|--------------------:|-------:|")

    for test_name, test_results in tests.items():
        ok = [r for r in test_results if r.error is None]
        errs = len(test_results) - len(ok)
        if ok:
            api = ok[0].api_name
            median_speed = statistics.median(r.speed_mbps for r in ok)
            mean_total = statistics.mean(r.total_time_s for r in ok)
            size = _fmt_size(ok[0].file_size_bytes) if ok[0].file_size_bytes > 0 else "n/a"
            speed_str = f"{median_speed:.2f}" if median_speed > 0 else "n/a"
            lines.append(
                f"| {api} | {test_name} | {size} | {speed_str} | {mean_total:.1f} | {errs} |"
            )
        else:
            api = test_results[0].api_name
            lines.append(f"| {api} | {test_name} | - | - | - | {errs} |")

    lines.append("")

    # CDS note
    cds_results = [r for r in results if r.api_name == "CDS" and r.error is None]
    if cds_results:
        lines.append("### CDS Note\n")
        lines.append("CDS total time includes server-side queue, processing, and download.")
        lines.append("These cannot be separated because `remote.download()` blocks for all three phases.")
        lines.append("")

    # Key findings and analysis
    findings = _generate_findings(results, host_info, traceroutes)
    lines.extend(findings)

    # Detailed results
    lines.append("## Detailed Results\n")
    for test_name, test_results in tests.items():
        api = test_results[0].api_name
        lines.append(f"### {api} - {test_name}\n")
        lines.append("| Iteration | Size | Time (s) | Speed (MB/s) | Status |")
        lines.append("|----------:|-----:|---------:|-------------:|--------|")
        for r in test_results:
            if r.error:
                lines.append(f"| {r.iteration} | - | - | - | {r.error[:50]} |")
            else:
                speed_str = f"{r.speed_mbps:.2f}" if r.speed_mbps > 0 else "n/a"
                size_str = _fmt_size(r.file_size_bytes) if r.file_size_bytes > 0 else "n/a"
                lines.append(
                    f"| {r.iteration} | {size_str} | "
                    f"{r.total_time_s:.2f} | {speed_str} | OK |"
                )
        lines.append("")

    # Traceroute section
    lines.append("## Traceroute Analysis\n")
    for api_name, output in traceroutes.items():
        host = API_SERVERS.get(api_name, "unknown")
        hops = count_hops(output)
        lines.append(f"### {api_name} ({host}) - {hops} hops\n")
        lines.append("```")
        lines.append(output.strip())
        lines.append("```\n")

    # Methodology
    lines.append("## Methodology\n")
    lines.append("- **WorldPop & CHIRPS (full):** HTTP GET with streaming. ")
    lines.append("  Speed = file_size / total_wall_clock_time (includes connection setup and transfer).")
    lines.append("- **CHIRPS (bbox):** `rioxarray.open_rasterio()` with `rio.clip_box()`, ")
    lines.append("  measures the COG range-request workflow that users actually experience. ")
    lines.append("  Wall-clock time only — no throughput number because the bytes transferred ")
    lines.append("  over HTTP differ from the decoded in-memory array size.")
    lines.append("- **CDS ERA5-Land:** ECMWF API submit + wait + download (inseparable). ")
    lines.append("  Total wall-clock time is reported. Request: 3 days of `2m_temperature` for the test bbox.")
    lines.append("")
    lines.append("## How to compare across networks\n")
    lines.append("Run this script from each network and compare the generated reports.")
    lines.append("The public IP, location, and traceroute data help identify routing differences.\n")
    lines.append("```bash")
    lines.append("uv run python examples/benchmark_download_speeds.py --iterations 3")
    lines.append("```")

    report = "\n".join(lines) + "\n"
    with open(path, "w") as f:
        f.write(report)
    print(f"Report saved to {path}")
    return path


def _subtitle(fig: object, host_info: dict[str, str]) -> None:
    """Add location subtitle to a figure. Call before tight_layout."""
    fig.text(  # type: ignore[union-attr]
        0.5, 0.01,
        f"From: {host_info['location']} ({host_info['public_ip']}) | {host_info['isp']}",
        ha="center", fontsize=9, style="italic", color="gray",
    )


def generate_plots(
    results: list[BenchmarkResult],
    output_dir: str,
    host_info: dict[str, str],
    traceroutes: dict[str, str],
) -> list[str]:
    """Generate PNG plots. Returns list of saved file paths."""
    import matplotlib.pyplot as plt

    os.makedirs(output_dir, exist_ok=True)
    saved: list[str] = []

    ok_results = [r for r in results if r.error is None]
    if not ok_results:
        print("No successful results to plot.")
        return saved

    # Group by test_name, preserving order
    tests: dict[str, list[BenchmarkResult]] = {}
    for r in ok_results:
        tests.setdefault(r.test_name, []).append(r)

    test_names = list(tests.keys())
    colors_map = {
        "worldpop_global1": "#2196F3",
        "worldpop_global2": "#1565C0",
        "chirps_full": "#4CAF50",
        "chirps_bbox": "#66BB6A",
        "cds_era5land": "#FF9800",
    }
    colors = [colors_map.get(t, "#9E9E9E") for t in test_names]

    # =========================================================
    # Chart 1: Horizontal bar - Wall-clock time per download
    # This is the most useful chart: "how long do I actually wait?"
    # =========================================================
    fig, ax = plt.subplots(figsize=(10, max(4, len(test_names) * 1.2 + 1)))

    # Use median total time across iterations
    median_totals = [statistics.median(r.total_time_s for r in tests[t]) for t in test_names]
    median_sizes = [statistics.median(r.file_size_bytes for r in tests[t]) for t in test_names]
    labels = [
        f"{tests[t][0].api_name} - {t}\n({_fmt_size(int(s))})" if s > 0
        else f"{tests[t][0].api_name} - {t}\n(wall-clock only)"
        for t, s in zip(test_names, median_sizes)
    ]

    y_pos = range(len(test_names))
    bars = ax.barh(y_pos, median_totals, color=colors, alpha=0.85, height=0.6)

    # Add time labels on bars, using the stored speed_mbps (0 when not meaningful)
    median_speeds = [statistics.median(r.speed_mbps for r in tests[t]) for t in test_names]
    for bar, t_val, speed in zip(bars, median_totals, median_speeds):
        label = f" {_fmt_time(t_val)}  ({speed:.2f} MB/s)" if speed > 0 else f" {_fmt_time(t_val)}"
        ax.text(bar.get_width(), bar.get_y() + bar.get_height() / 2,
                label, va="center", fontsize=10, fontweight="bold")

    ax.set_yticks(list(y_pos))
    ax.set_yticklabels(labels, fontsize=10)
    ax.set_xlabel("Wall-Clock Time (seconds)", fontsize=12)
    ax.set_title("How Long Does Each Download Take?", fontsize=14, fontweight="bold")
    ax.grid(axis="x", alpha=0.3)
    ax.invert_yaxis()

    _subtitle(fig, host_info)
    plt.tight_layout()
    fig.subplots_adjust(bottom=0.12)
    path = os.path.join(output_dir, "download_times.png")
    fig.savefig(path, dpi=150)
    plt.close(fig)
    saved.append(path)
    print(f"Download time chart saved to {path}")

    # =========================================================
    # Chart 2: Per-iteration scatter + bar showing all runs
    # Useful even with 1 iteration, and shows variability with more
    # =========================================================
    fig, ax = plt.subplots(figsize=(10, max(4, len(test_names) * 1.2 + 1)))

    y_pos = range(len(test_names))
    ax.barh(y_pos, median_totals, color=colors, alpha=0.3, height=0.5, label="Median")

    # Overlay individual iteration points
    for idx, t in enumerate(test_names):
        times = [r.total_time_s for r in tests[t]]
        ax.scatter(times, [idx] * len(times), color=colors[idx], zorder=5, s=60, edgecolors="white", linewidth=1)
        for i, tv in enumerate(times):
            ax.annotate(f"#{i + 1}", (tv, idx), textcoords="offset points",
                        xytext=(0, 10), ha="center", fontsize=7, color="gray")

    short_labels = [f"{tests[t][0].api_name} - {t}" for t in test_names]
    ax.set_yticks(list(y_pos))
    ax.set_yticklabels(short_labels, fontsize=10)
    ax.set_xlabel("Total Time (seconds)", fontsize=12)
    ax.set_title("Per-Iteration Download Times", fontsize=14, fontweight="bold")
    ax.grid(axis="x", alpha=0.3)
    ax.invert_yaxis()

    _subtitle(fig, host_info)
    plt.tight_layout()
    fig.subplots_adjust(bottom=0.12)
    path = os.path.join(output_dir, "iteration_scatter.png")
    fig.savefig(path, dpi=150)
    plt.close(fig)
    saved.append(path)
    print(f"Iteration scatter chart saved to {path}")

    # =========================================================
    # Chart 3: File size vs time scatter (throughput perspective)
    # Only includes tests with a known transfer size (speed_mbps > 0).
    # Tests like CHIRPS bbox and CDS where the "file size" is not
    # the actual bytes transferred are excluded.
    # =========================================================
    throughput_tests = {t: rs for t, rs in tests.items()
                       if any(r.speed_mbps > 0 for r in rs)}

    fig, ax = plt.subplots(figsize=(8, 6))

    for t, rs in throughput_tests.items():
        color = colors_map.get(t, "#9E9E9E")
        for r in rs:
            size_mb = r.file_size_bytes / 1_000_000
            ax.scatter(size_mb, r.total_time_s, color=color, s=80, edgecolors="white",
                       linewidth=1, zorder=5)
        med_size = statistics.median(r.file_size_bytes for r in rs) / 1_000_000
        med_time = statistics.median(r.total_time_s for r in rs)
        ax.annotate(f"{rs[0].api_name}\n{t}", (med_size, med_time),
                    textcoords="offset points", xytext=(10, 5), fontsize=9,
                    fontweight="bold", color=color)

    # Add reference lines for throughput rates (only if there are throughput results)
    sized_results = [r for r in ok_results if r.file_size_bytes > 0 and r.speed_mbps > 0]
    if not sized_results:
        # No throughput-style results, skip this chart entirely
        plt.close(fig)
    else:
        max_size = max(r.file_size_bytes for r in sized_results) / 1_000_000 * 1.3
        max_time = max(r.total_time_s for r in sized_results) * 1.1
        for rate, label in [(0.1, "0.1 MB/s"), (0.5, "0.5 MB/s"), (1.0, "1 MB/s"), (5.0, "5 MB/s")]:
            x_line = [0, max_size]
            y_line = [0, max_size / rate]
            if y_line[1] > max_time * 2:
                continue
            ax.plot(x_line, y_line, "--", color="gray", alpha=0.3, linewidth=1)
            label_x = min(max_size * 0.8, rate * max_time * 0.8)
            label_y = label_x / rate
            if label_y < max_time:
                ax.text(label_x, label_y, label, fontsize=8, color="gray", alpha=0.6, rotation=0)

        ax.set_xlabel("File Size (MB)", fontsize=12)
        ax.set_ylabel("Total Time (seconds)", fontsize=12)
        ax.set_title("File Size vs Download Time", fontsize=14, fontweight="bold")
        ax.set_xlim(left=0)
        ax.set_ylim(bottom=0)
        ax.grid(alpha=0.2)

        _subtitle(fig, host_info)
        plt.tight_layout()
        fig.subplots_adjust(bottom=0.12)
        path = os.path.join(output_dir, "size_vs_time.png")
        fig.savefig(path, dpi=150)
        plt.close(fig)
        saved.append(path)
        print(f"Size vs time chart saved to {path}")

    # =========================================================
    # Chart 4: Traceroute hop count comparison
    # =========================================================
    if traceroutes:
        fig, ax = plt.subplots(figsize=(8, max(3, len(traceroutes) * 1.2 + 1)))
        tr_names = list(traceroutes.keys())
        tr_hops = [count_hops(traceroutes[n]) for n in tr_names]
        tr_hosts = [API_SERVERS.get(n, "") for n in tr_names]
        tr_labels = [f"{n}\n({h})" for n, h in zip(tr_names, tr_hosts)]
        tr_colors = [colors_map.get(n.lower().replace(" ", "_").split("_")[0] + "_global1",
                     colors_map.get(n.lower(), "#9E9E9E")) for n in tr_names]
        # Use known colors
        tr_color_map = {"WorldPop": "#2196F3", "CHIRPS": "#4CAF50", "CDS": "#FF9800"}
        tr_colors = [tr_color_map.get(n, "#9E9E9E") for n in tr_names]

        bars = ax.barh(tr_labels, tr_hops, color=tr_colors, alpha=0.85, height=0.5)
        for bar, hops in zip(bars, tr_hops):
            ax.text(bar.get_width() + 0.3, bar.get_y() + bar.get_height() / 2,
                    f"{hops} hops", va="center", fontweight="bold", fontsize=10)

        ax.set_xlabel("Number of Hops", fontsize=12)
        ax.set_title("Network Hops to API Servers", fontsize=14, fontweight="bold")
        ax.grid(axis="x", alpha=0.3)

        _subtitle(fig, host_info)
        plt.tight_layout()
        fig.subplots_adjust(bottom=0.1)
        path = os.path.join(output_dir, "traceroute_hops.png")
        fig.savefig(path, dpi=150)
        plt.close(fig)
        saved.append(path)
        print(f"Traceroute chart saved to {path}")

    return saved


def generate_pdf(
    results: list[BenchmarkResult],
    output_dir: str,
    args: argparse.Namespace,
    host_info: dict[str, str],
    traceroutes: dict[str, str],
    plot_paths: list[str],
) -> None:
    """Generate a proper A4 PDF report with embedded plots using matplotlib's PdfPages."""
    from matplotlib.backends.backend_pdf import PdfPages
    import matplotlib.pyplot as plt

    # A4 dimensions in inches (210mm x 297mm)
    A4_W, A4_H = 8.27, 11.69
    MARGIN = 0.08  # relative margin

    os.makedirs(output_dir, exist_ok=True)
    pdf_path = os.path.join(output_dir, "benchmark_report.pdf")

    # Group by test_name
    tests: dict[str, list[BenchmarkResult]] = {}
    for r in results:
        tests.setdefault(r.test_name, []).append(r)

    def new_page() -> tuple[object, object]:
        fig, ax = plt.subplots(figsize=(A4_W, A4_H))
        ax.axis("off")
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        return fig, ax

    with PdfPages(pdf_path) as pdf:

        # === PAGE 1: Title + network info + summary table ===
        fig, ax = new_page()

        # Title
        ax.text(0.5, 0.92, "API Download Speed\nBenchmark Report", transform=ax.transAxes,
                fontsize=24, fontweight="bold", ha="center", va="top", linespacing=1.4)
        ax.text(0.5, 0.84, datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC"),
                transform=ax.transAxes, fontsize=11, ha="center", va="top", color="gray")

        # Horizontal rule
        ax.plot([MARGIN, 1 - MARGIN], [0.82, 0.82], color="#CCCCCC", linewidth=1,
                transform=ax.transAxes, clip_on=False)

        # Network environment
        ax.text(MARGIN, 0.79, "Network Environment", transform=ax.transAxes,
                fontsize=14, fontweight="bold", va="top")

        env_items = [
            ("Hostname", host_info["hostname"]),
            ("Platform", host_info["platform"]),
            ("Public IP", host_info["public_ip"]),
            ("Location", host_info["location"]),
            ("ISP", host_info["isp"]),
            ("Test Region", f"{args.country_code}  (bbox: {args.bbox})"),
            ("Iterations", str(args.iterations)),
        ]
        y = 0.75
        for label, value in env_items:
            ax.text(MARGIN + 0.02, y, f"{label}:", transform=ax.transAxes,
                    fontsize=10, va="top", fontweight="bold", color="#444444")
            ax.text(0.22, y, value, transform=ax.transAxes,
                    fontsize=10, va="top", family="monospace")
            y -= 0.028

        # Horizontal rule
        y -= 0.015
        ax.plot([MARGIN, 1 - MARGIN], [y, y], color="#CCCCCC", linewidth=1,
                transform=ax.transAxes, clip_on=False)
        y -= 0.025

        # Summary table
        ax.text(MARGIN, y, "Results Summary", transform=ax.transAxes,
                fontsize=14, fontweight="bold", va="top")
        y -= 0.035

        col_labels = ["API", "Test", "Size", "Speed (MB/s)", "Time (s)", "Err"]
        table_data = []
        for test_name, test_results in tests.items():
            ok = [r for r in test_results if r.error is None]
            errs = len(test_results) - len(ok)
            if ok:
                api = ok[0].api_name
                median_speed = statistics.median(r.speed_mbps for r in ok)
                mean_total = statistics.mean(r.total_time_s for r in ok)
                size = _fmt_size(ok[0].file_size_bytes) if ok[0].file_size_bytes > 0 else "n/a"
                speed_str = f"{median_speed:.2f}" if median_speed > 0 else "n/a"
                table_data.append([api, test_name, size, speed_str, f"{mean_total:.1f}", str(errs)])
            else:
                api = test_results[0].api_name
                table_data.append([api, test_name, "-", "-", "-", str(errs)])

        if table_data:
            row_height = 0.035
            table_height = row_height * (len(table_data) + 1.5)
            table = ax.table(
                cellText=table_data,
                colLabels=col_labels,
                loc="upper center",
                bbox=[MARGIN, y - table_height, 1 - 2 * MARGIN, table_height],
                colWidths=[0.12, 0.22, 0.14, 0.18, 0.14, 0.08],
            )
            table.auto_set_font_size(False)
            table.set_fontsize(8)
            for key, cell in table.get_celld().items():
                cell.set_edgecolor("#DDDDDD")
                cell.set_text_props(ha="center")
                if key[0] == 0:
                    cell.set_facecolor("#2C5F8A")
                    cell.set_text_props(color="white", fontweight="bold", ha="center")
                elif key[0] % 2 == 0:
                    cell.set_facecolor("#EBF0F7")
                else:
                    cell.set_facecolor("white")
            y -= table_height + 0.03

        pdf.savefig(fig)
        plt.close(fig)

        # === FINDINGS PAGES ===
        findings = _generate_findings(results, host_info, traceroutes)

        def _wrap_text(text: str, max_chars: int = 95) -> list[str]:
            words = text.split()
            lines_out: list[str] = []
            current = ""
            for word in words:
                if len(current) + len(word) + 1 > max_chars:
                    lines_out.append(current)
                    current = "    " + word
                else:
                    current = current + " " + word if current else word
            if current:
                lines_out.append(current)
            return lines_out

        def _parse_md_table(table_lines: list[str]) -> tuple[list[str], list[list[str]]]:
            """Parse markdown table lines into (headers, rows)."""
            headers: list[str] = []
            rows: list[list[str]] = []
            for tl in table_lines:
                cells = [c.strip() for c in tl.strip().strip("|").split("|")]
                if any("---" in c for c in cells):
                    continue
                if not headers:
                    headers = cells
                else:
                    rows.append(cells)
            return headers, rows

        def _render_md_table(table_lines: list[str], current_y: float) -> float:
            """Render a markdown table as a matplotlib table, return new y."""
            nonlocal fig, ax
            headers, rows = _parse_md_table(table_lines)
            if not rows:
                return current_y
            row_h = 0.025
            t_height = row_h * (len(rows) + 1.2)
            if current_y - t_height < 0.05:
                pdf.savefig(fig)
                plt.close(fig)
                fig, ax = new_page()
                current_y = 0.92
            tbl = ax.table(
                cellText=rows,
                colLabels=headers,
                loc="upper center",
                bbox=[MARGIN, current_y - t_height, 1 - 2 * MARGIN, t_height],
            )
            tbl.auto_set_font_size(False)
            tbl.set_fontsize(8)
            tbl.auto_set_column_width(list(range(len(headers))))
            for key, cell in tbl.get_celld().items():
                cell.set_edgecolor("#DDDDDD")
                if key[0] == 0:
                    cell.set_facecolor("#2C5F8A")
                    cell.set_text_props(color="white", fontweight="bold", ha="center")
                elif key[0] % 2 == 0:
                    cell.set_facecolor("#EBF0F7")
                else:
                    cell.set_facecolor("white")
            return current_y - t_height - 0.02

        # Render findings as text pages
        fig, ax = new_page()
        y = 0.92
        i = 0
        while i < len(findings):
            line = findings[i]

            # Collect consecutive table lines and render as a real table
            if line.startswith("|"):
                table_lines = []
                while i < len(findings) and findings[i].startswith("|"):
                    table_lines.append(findings[i])
                    i += 1
                y = _render_md_table(table_lines, y)
                continue

            # Section headers
            if line.startswith("## "):
                if y < 0.3:
                    pdf.savefig(fig)
                    plt.close(fig)
                    fig, ax = new_page()
                    y = 0.92
                ax.text(MARGIN, y, line.lstrip("#").strip(), transform=ax.transAxes,
                        fontsize=16, fontweight="bold", va="top")
                y -= 0.045
            elif line.startswith("### "):
                if y < 0.15:
                    pdf.savefig(fig)
                    plt.close(fig)
                    fig, ax = new_page()
                    y = 0.92
                y -= 0.01
                ax.text(MARGIN, y, line.lstrip("#").strip(), transform=ax.transAxes,
                        fontsize=13, fontweight="bold", va="top", color="#2C5F8A")
                y -= 0.04
            elif line.startswith("**") and line.endswith("**"):
                ax.text(MARGIN, y, line.strip("*"), transform=ax.transAxes,
                        fontsize=10, fontweight="bold", va="top")
                y -= 0.025
            elif line.startswith(("- ", "1.", "2.", "3.", "4.", "5.")):
                for wl in _wrap_text(line):
                    ax.text(MARGIN + 0.02, y, wl, transform=ax.transAxes,
                            fontsize=8.5, va="top")
                    y -= 0.02
            elif line.startswith("*") and line.endswith("*"):
                for wl in _wrap_text(line.strip("*"), max_chars=105):
                    ax.text(MARGIN + 0.02, y, wl, transform=ax.transAxes,
                            fontsize=8, va="top", style="italic", color="gray")
                    y -= 0.018
            elif line.strip():
                for wl in _wrap_text(line.strip()):
                    ax.text(MARGIN + 0.02, y, wl, transform=ax.transAxes,
                            fontsize=8.5, va="top")
                    y -= 0.02

            if y < 0.05:
                pdf.savefig(fig)
                plt.close(fig)
                fig, ax = new_page()
                y = 0.92

            i += 1

        pdf.savefig(fig)
        plt.close(fig)

        # === DETAILED RESULTS PAGE ===
        fig, ax = new_page()
        y = 0.92
        ax.text(MARGIN, y, "Detailed Results", transform=ax.transAxes,
                fontsize=16, fontweight="bold", va="top")
        y -= 0.045

        for test_name, test_results in tests.items():
            api = test_results[0].api_name
            ax.text(MARGIN + 0.02, y, f"{api} - {test_name}", transform=ax.transAxes,
                    fontsize=11, fontweight="bold", va="top", color="#2C5F8A")
            y -= 0.028
            for r in test_results:
                if r.error:
                    line = f"  Iter {r.iteration}: ERROR - {r.error[:60]}"
                else:
                    speed_str = f"{r.speed_mbps:.2f} MB/s" if r.speed_mbps > 0 else "wall-clock only"
                    size_str = _fmt_size(r.file_size_bytes) if r.file_size_bytes > 0 else "n/a"
                    line = (
                        f"  Iter {r.iteration}:  {size_str:>10}  |  "
                        f"total: {r.total_time_s:.2f}s  |  {speed_str}"
                    )
                ax.text(MARGIN + 0.02, y, line, transform=ax.transAxes,
                        fontsize=8, va="top", family="monospace")
                y -= 0.022
                if y < 0.05:
                    pdf.savefig(fig)
                    plt.close(fig)
                    fig, ax = new_page()
                    y = 0.92
            y -= 0.01

        pdf.savefig(fig)
        plt.close(fig)

        # === PLOT PAGES: each chart on its own A4 page, properly scaled ===
        for plot_path in plot_paths:
            if not os.path.exists(plot_path):
                continue
            img = plt.imread(plot_path)
            fig = plt.figure(figsize=(A4_W, A4_H))

            # Calculate image aspect ratio and fit within A4 margins
            img_h, img_w = img.shape[:2]
            aspect = img_w / img_h
            usable_w = 1 - 2 * MARGIN
            usable_h = 0.82  # leave room for top/bottom margins
            if aspect > (usable_w / usable_h):
                # Width-constrained
                plot_w = usable_w
                plot_h = plot_w / aspect
            else:
                # Height-constrained
                plot_h = usable_h
                plot_w = plot_h * aspect

            # Center the image on the page
            left = (1 - plot_w) / 2
            bottom = (1 - plot_h) / 2
            ax = fig.add_axes([left, bottom, plot_w, plot_h])
            ax.imshow(img)
            ax.axis("off")

            pdf.savefig(fig)
            plt.close(fig)

        # === TRACEROUTE PAGE ===
        if traceroutes:
            fig, ax = new_page()
            y = 0.92
            ax.text(0.5, y, "Traceroute Analysis", transform=ax.transAxes,
                    fontsize=18, fontweight="bold", ha="center", va="top")
            y -= 0.06

            for api_name, output in traceroutes.items():
                host = API_SERVERS.get(api_name, "unknown")
                hops = count_hops(output)
                ax.text(MARGIN, y, f"{api_name} ({host}) - {hops} hops",
                        transform=ax.transAxes, fontsize=12, fontweight="bold", va="top",
                        color="#2C5F8A")
                y -= 0.03

                tr_lines = output.strip().split("\n")
                for line in tr_lines[:30]:
                    ax.text(MARGIN + 0.02, y, line[:110], transform=ax.transAxes,
                            fontsize=6.5, va="top", family="monospace")
                    y -= 0.015
                    if y < 0.05:
                        pdf.savefig(fig)
                        plt.close(fig)
                        fig, ax = new_page()
                        y = 0.92

                if len(tr_lines) > 30:
                    ax.text(MARGIN + 0.02, y, f"... ({len(tr_lines) - 30} more lines)",
                            transform=ax.transAxes, fontsize=6.5, va="top",
                            family="monospace", color="gray")
                    y -= 0.015
                y -= 0.02

            pdf.savefig(fig)
            plt.close(fig)

    print(f"PDF report saved to {pdf_path}")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def _parse_date(value: str) -> date_type:
    """Argparse type for YYYY-MM-DD dates with validation."""
    try:
        return date_type.fromisoformat(value)
    except ValueError:
        raise argparse.ArgumentTypeError(f"invalid date: '{value}' (expected YYYY-MM-DD)")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Benchmark download speeds from WorldPop, CHIRPS, and CDS APIs",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--iterations", type=int, default=DEFAULT_ITERATIONS, help="Number of iterations per test (default: 3)")
    parser.add_argument("--output-dir", default=DEFAULT_OUTPUT_DIR, help="Output directory for report and plots (default: output)")
    parser.add_argument("--country-code", default=DEFAULT_COUNTRY_CODE, help="ISO3 country code for WorldPop (default: SLE)")
    parser.add_argument("--bbox", type=float, nargs=4, metavar=("W", "S", "E", "N"), default=None, help="Bounding box override for CHIRPS bbox and CDS tests (default: derived from --country-code)")
    parser.add_argument("--skip-cds", action="store_true", help="Skip CDS ERA5-Land benchmark")
    parser.add_argument("--skip-chirps-full", action="store_true", help="Skip full CHIRPS file download (can be 100+ MB)")
    parser.add_argument("--skip-traceroute", action="store_true", help="Skip traceroute analysis")
    parser.add_argument("--worldpop-year", type=int, default=2020, help="Year for WorldPop test (default: 2020)")
    parser.add_argument("--chirps-date", type=_parse_date, default=date_type(2024, 1, 15), help="Date for CHIRPS test as YYYY-MM-DD (default: 2024-01-15)")
    parser.add_argument("--cds-year", type=int, default=2024, help="Year for CDS test (default: 2024)")
    parser.add_argument("--cds-month", type=int, default=1, help="Month for CDS test (default: 1)")
    args = parser.parse_args()

    # Derive bbox from country code if not explicitly provided
    if args.bbox is None:
        cc = args.country_code.upper()
        if cc not in COUNTRY_BBOXES:
            parser.error(
                f"No built-in bbox for country code '{cc}'. "
                f"Use --bbox W S E N to provide one, or use one of: {', '.join(sorted(COUNTRY_BBOXES))}"
            )
        args.bbox = COUNTRY_BBOXES[cc]
    else:
        args.bbox = tuple(args.bbox)

    return args


def main() -> None:
    # Load .env if available (not required if env vars are set directly)
    try:
        from dotenv import load_dotenv
        load_dotenv()
    except ImportError:
        pass

    args = parse_args()
    chirps_date: date_type = args.chirps_date
    chirps_y, chirps_m, chirps_d = chirps_date.year, chirps_date.month, chirps_date.day

    # Get host info
    print("Detecting network environment ...")
    host_info = get_host_info()

    print("=" * 60)
    print("  API Download Speed Benchmark")
    print("=" * 60)
    print(f"  Host:       {host_info['hostname']}")
    print(f"  Platform:   {host_info['platform']}")
    print(f"  Public IP:  {host_info['public_ip']}")
    print(f"  Location:   {host_info['location']}")
    print(f"  ISP:        {host_info['isp']}")
    print(f"  Country:    {args.country_code}")
    print(f"  BBox:       {args.bbox}")
    print(f"  Iterations: {args.iterations}")
    print("=" * 60)

    # Run traceroutes
    traceroutes: dict[str, str] = {}
    if not args.skip_traceroute:
        print("\nRunning traceroutes (this may take a minute) ...")
        for api_name, host in API_SERVERS.items():
            print(f"  traceroute {host} ...", end=" ", flush=True)
            output = run_traceroute(host)
            traceroutes[api_name] = output
            hops = count_hops(output)
            print(f"{hops} hops")

    all_results: list[BenchmarkResult] = []

    # WorldPop global1
    print("\n[1/5] WorldPop (global1) ...")
    all_results.extend(benchmark_worldpop(args.iterations, args.country_code, args.worldpop_year, "global1"))

    # WorldPop global2
    print("\n[2/5] WorldPop (global2) ...")
    all_results.extend(benchmark_worldpop(args.iterations, args.country_code, args.worldpop_year, "global2"))

    # CHIRPS full
    if args.skip_chirps_full:
        print("\n[3/5] CHIRPS (full) ... SKIPPED (--skip-chirps-full)")
    else:
        print("\n[3/5] CHIRPS (full daily GeoTIFF) ...")
        all_results.extend(benchmark_chirps_full(args.iterations, chirps_y, chirps_m, chirps_d))

    # CHIRPS bbox
    if HAS_RIOXARRAY:
        print("\n[4/5] CHIRPS (bbox clip) ...")
        all_results.extend(benchmark_chirps_bbox(args.iterations, chirps_y, chirps_m, chirps_d, args.bbox))
    else:
        print("\n[4/5] CHIRPS (bbox clip) ... SKIPPED (rioxarray not installed)")

    # CDS
    if args.skip_cds:
        print("\n[5/5] CDS ERA5-Land ... SKIPPED (--skip-cds)")
    elif not HAS_CDS:
        print("\n[5/5] CDS ERA5-Land ... SKIPPED (ecmwf-datastores not installed)")
    else:
        print("\n[5/5] CDS ERA5-Land ...")
        all_results.extend(benchmark_cds(args.iterations, args.bbox, args.cds_year, args.cds_month))

    # Generate outputs
    if all_results:
        print("\n" + "=" * 60)
        print("  Generating report and plots ...")
        print("=" * 60)
        generate_report(all_results, args.output_dir, args, host_info, traceroutes)
        plot_paths = generate_plots(all_results, args.output_dir, host_info, traceroutes)
        generate_pdf(all_results, args.output_dir, args, host_info, traceroutes, plot_paths)
    else:
        print("\nNo results collected. Nothing to report.")


if __name__ == "__main__":
    main()

"""Pydantic models for DHIS2 and earth observation data exchange.

These schemas provide type-safe representations of the data structures used
throughout the workshop — from DHIS2 API responses to download parameters
and pipeline records.
"""

from __future__ import annotations

from enum import StrEnum

from geojson_pydantic.geometries import Geometry
from pydantic import BaseModel, Field
from shapely.geometry import shape

# ---------------------------------------------------------------------------
# Bounding box
# ---------------------------------------------------------------------------


class BBox(BaseModel):
    """Geographic bounding box (west, south, east, north)."""

    west: float
    south: float
    east: float
    north: float

    def as_tuple(self) -> tuple[float, float, float, float]:
        """Return as (west, south, east, north) tuple for dhis2eo download functions."""
        return (self.west, self.south, self.east, self.north)


# ---------------------------------------------------------------------------
# DHIS2 core models
# ---------------------------------------------------------------------------


class OrgUnit(BaseModel):
    """DHIS2 organisation unit with optional geometry."""

    id: str
    name: str
    displayName: str | None = None
    geometry: Geometry | None = None
    level: int | None = None

    def get_bbox(self) -> BBox:
        """Derive bounding box from the org unit's GeoJSON geometry using shapely."""
        if not self.geometry:
            msg = f"Org unit {self.id} ({self.name}) has no geometry"
            raise ValueError(msg)
        geojson = self.geometry.model_dump()
        bounds = shape(geojson).bounds  # (minx, miny, maxx, maxy)
        return BBox(west=bounds[0], south=bounds[1], east=bounds[2], north=bounds[3])


class User(BaseModel):
    """DHIS2 user."""

    id: str
    username: str | None = None
    firstName: str | None = None
    surname: str | None = None
    displayName: str | None = None


class IdRef(BaseModel):
    """Minimal reference to any DHIS2 object (just the UID), used in metadata payloads."""

    id: str


class CategoryOption(BaseModel):
    """DHIS2 category option (e.g. Male, Female)."""

    id: str
    name: str
    shortName: str | None = None


class Category(BaseModel):
    """DHIS2 category — groups category options (e.g. Sex = Male + Female)."""

    id: str
    name: str
    shortName: str | None = None
    dataDimensionType: str = "DISAGGREGATION"
    categoryOptions: list[IdRef] = Field(default_factory=list)


class CategoryCombo(BaseModel):
    """DHIS2 category combination — assigns disaggregation dimensions to data elements."""

    id: str
    name: str
    dataDimensionType: str = "DISAGGREGATION"
    categories: list[IdRef] = Field(default_factory=list)


class DataElement(BaseModel):
    """DHIS2 data element."""

    id: str
    name: str
    shortName: str | None = None
    displayName: str | None = None
    valueType: str = "NUMBER"
    domainType: str = "AGGREGATE"
    aggregationType: str = "SUM"
    categoryCombo: IdRef | None = None


class DataSetElement(BaseModel):
    """Reference to a data element within a data set."""

    dataElement: DataElement


class Sharing(BaseModel):
    """DHIS2 sharing settings."""

    public: str = "rwrw----"


class PeriodType(StrEnum):
    """DHIS2 period types."""

    DAILY = "Daily"
    WEEKLY = "Weekly"
    MONTHLY = "Monthly"
    QUARTERLY = "Quarterly"
    YEARLY = "Yearly"


class DataSet(BaseModel):
    """DHIS2 data set — groups data elements and assigns them to org units."""

    id: str
    name: str
    shortName: str | None = None
    periodType: PeriodType = PeriodType.MONTHLY
    dataSetElements: list[DataSetElement] = Field(default_factory=list)
    organisationUnits: list[IdRef] = Field(default_factory=list)
    sharing: Sharing = Field(default_factory=Sharing)


class MetadataPayload(BaseModel):
    """Payload for the /api/metadata endpoint (create-or-update objects)."""

    categoryOptions: list[CategoryOption] = Field(default_factory=list)
    categories: list[Category] = Field(default_factory=list)
    categoryCombos: list[CategoryCombo] = Field(default_factory=list)
    dataElements: list[DataElement] = Field(default_factory=list)
    dataSets: list[DataSet] = Field(default_factory=list)


# ---------------------------------------------------------------------------
# Analytics
# ---------------------------------------------------------------------------


class AnalyticsHeader(BaseModel):
    """Column header in an analytics response."""

    name: str
    column: str | None = None
    valueType: str | None = None


class AnalyticsResult(BaseModel):
    """Response from the /api/analytics endpoint."""

    headers: list[AnalyticsHeader] = Field(default_factory=list)
    rows: list[list[str]] = Field(default_factory=list)
    height: int | None = None
    width: int | None = None

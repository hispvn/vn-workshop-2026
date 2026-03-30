FROM prefecthq/prefect:3-python3.13

RUN pip install --no-cache-dir python-dotenv

COPY deployments/parallel/flow.py /opt/prefect/flow.py

WORKDIR /opt/prefect
CMD ["python", "flow.py"]

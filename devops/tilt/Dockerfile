# syntax=docker/dockerfile:1.5

ARG PYTHON_VER=${PYTHON_VER:-3.10.10}

FROM python:${PYTHON_VER}-slim-buster

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

COPY . .

ENTRYPOINT ["python", "/app/app.py"]

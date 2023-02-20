# syntax=docker/dockerfile:1
FROM python:3.10.9-slim-buster

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install -r requirements.txt
COPY . .

ENTRYPOINT ["python", "/app/app.py"]

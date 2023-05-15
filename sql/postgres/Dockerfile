# SOURCES
# https://denisbrogg.hashnode.dev/efficient-python-docker-image-from-any-poetry-project
# https://binx.io/2022/06/13/poetry-docker/
# https://github.com/python-poetry/poetry/discussions/1879#discussioncomment-216865

# full semver just for python base image
ARG PYTHON_VERSION=3.11.3

FROM python:${PYTHON_VERSION}-slim-bullseye AS builder

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

# install dependencies
RUN apt -qq update \
    && apt -qq install \
    --no-install-recommends -y \
    curl \
    gcc \
    libpq-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# pip env vars
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV PIP_DEFAULT_TIMEOUT=100

# path
ENV VENV="/opt/venv"
ENV PATH="$VENV/bin:$PATH"

WORKDIR /app
COPY . .

RUN python -m venv $VENV \
    && . "${VENV}/bin/activate" \
    && python -m pip install -r requirements.txt

FROM python:${PYTHON_VERSION}-slim-bullseye AS runner

# setup standard non-root user for use downstream
ENV USER_NAME=appuser
ENV USER_GROUP=appuser
ENV HOME="/home/${USER_NAME}"
ENV HOSTNAME="${HOST:-localhost}"
ENV VENV="/opt/venv"

ENV PATH="${VENV}/bin:${VENV}/lib/python${PYTHON_VERSION}/site-packages:/usr/local/bin:${HOME}/.local/bin:/bin:/usr/bin:/usr/share/doc:$PATH"

# standardise on locale, don't generate .pyc, enable tracebacks on seg faults
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

RUN groupadd ${USER_NAME} \
    && useradd -m ${USER_NAME} -g ${USER_GROUP}

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

# install dependencies
RUN apt -qq update \
    && apt -qq install \
    --no-install-recommends -y \
    curl \
    lsof \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --chown=${USER_NAME} . .
COPY --from=builder --chown=${USER_NAME} "$VENV" "$VENV"

USER ${USER_NAME}

# listening port (not published)
EXPOSE 8000

# postgres env vars
ENV DATABASE_NAME=${POSTGRES_DB:-postgres}
ENV DATABASE_URL=${POSTGRES_HOST:-db}
ENV DATABASE_USER=${POSTGRES_USER:-postgres}
ENV DATABASE_PASSWORD=${POSTGRES_PASSWORD:-mysecretpassword}
ENV DATABASE_PORT=${POSTGRES_PORT:-5432}

ENTRYPOINT ["python", "app.py"]
# CMD ["/bin/bash"]
# CMD ["5000"]
# CMD ["gunicorn", "-c", "gunicorn.conf.py", "main:app"]

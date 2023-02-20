# SOURCES
# https://denisbrogg.hashnode.dev/efficient-python-docker-image-from-any-poetry-project
# https://binx.io/2022/06/13/poetry-docker/
# https://github.com/python-poetry/poetry/discussions/1879#discussioncomment-216865

# full semver just for python base image
ARG PYTHON_VERSION=3.10.9

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

# poetry env vars
ENV POETRY_HOME="/opt/poetry"
ENV POETRY_VERSION=1.3.2
ENV POETRY_VIRTUALENVS_IN_PROJECT=true
ENV POETRY_NO_INTERACTION=1

# path
ENV VENV="/opt/venv"
ENV PATH="$POETRY_HOME/bin:$VENV/bin:$PATH"

WORKDIR /app
COPY . .

RUN python -m venv $VENV \
    && . "${VENV}/bin/activate" \
    && python -m pip install "poetry==${POETRY_VERSION}" \
    && poetry install --no-ansi --no-root --without dev

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

# workers per core
# https://github.com/tiangolo/uvicorn-gunicorn-fastapi-docker/blob/master/README.md#web_concurrency
ENV WEB_CONCURRENCY=2

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

# TODO: debug `find` calls that break on missing dirs
# COPY ./harden /usr/sbin/harden
# RUN /usr/sbin/harden

USER ${USER_NAME}

# listening port (not published)
EXPOSE 3000

# ENTRYPOINT ["python", "main.py"]
ENTRYPOINT ["/bin/sh", "startup.sh"]
# CMD ["5000"]
# CMD ["gunicorn", "-c", "gunicorn.conf.py", "main:app"]
# CMD ["/bin/bash"]

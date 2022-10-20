# SOURCES
# https://github.com/alexdmoss/distroless-python
# https://gitlab.com/n.ragav/python-images/-/tree/master/distroless

# full semver just for python base image
ARG PYTHON_VERSION=3.10.8

# several optimisations in python-slim images already, benefit from these
FROM python:${PYTHON_VERSION}-slim-bullseye AS builder-image

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

# install dependencies
RUN apt -qq update \
    && apt -qq install \
    --no-install-recommends -y \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    curl \
    gcc \
    libbz2-dev \
    libffi7 \
    libffi-dev \
    liblzma-dev \
    libncurses-dev \
    libpq-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libxslt-dev \
    libyaml-dev \
    locales \
    lzma \
    sqlite3 \
    unixodbc-dev \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# TODO: debug heroku var interpolation (intermediate containers per ENV??)
# setup standard non-root user for use downstream
ENV USERNAME=appuser
ENV USER_GROUP=${USERNAME}
ENV HOME=/home/${USERNAME}

RUN groupadd ${USERNAME}
RUN useradd -m ${USERNAME} -g ${USERNAME}

# setup user environment
ENV PATH="$HOME/.local/bin:$PATH"

WORKDIR /home/${USERNAME}
USER ${USERNAME}

# poetry for use elsewhere as builder image
RUN pip install --user --upgrade pip \
    && pip install --user --no-cache-dir --upgrade virtualenv poetry

COPY --chown=${USERNAME} pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.in-project true \
    && poetry config virtualenvs.options.always-copy true \
    && poetry install

# # QA
# CMD ["/bin/bash"]

# build from distroless C or cc:debug, because lots of Python depends on C
FROM gcr.io/distroless/cc AS distroless

# arch: x86_64-linux-gnu / aarch64-linux-gnu
ARG CHIPSET_ARCH=${CHIPSET_ARCH:-x86_64-linux-gnu}

# required by lots of packages - e.g. six, numpy, asgi, wsgi, gunicorn
# libz.so.1, libexpat.so.1, libbz2.so, libffi.so.7
COPY --from=builder-image /etc/ld.so.cache /etc/

# TODO: curl-specific libs (copying whole /lib and /usr/lib adds ~50MB to image)
# libcurl.so.4, libnghttp2.so.14, libidn2.so.0, librtmp.so.1, libssh2.so.1, libpsl.so.5
COPY --from=builder-image /lib/${CHIPSET_ARCH}/ /lib/${CHIPSET_ARCH}/
COPY --from=builder-image /usr/lib/${CHIPSET_ARCH}/ /lib/${CHIPSET_ARCH}/

# non-root user setup
ARG USERNAME=appuser
ARG PYTHON_VERSION=3.10
ENV HOME=/home/${USERNAME}
ENV VENV="${HOME}/.venv"

# import useful bins from busybox image
COPY --from=busybox:latest \
    /bin/cat \
    /bin/cut \
    /bin/date  \
    /bin/find \
    /bin/ls \
    /bin/rm \
    /bin/sed \
    /bin/sh \
    /bin/uname \
    /bin/vi \
    /bin/which \
    /bin/
COPY --from=busybox:uclibc /bin/env /usr/bin/env
COPY --from=builder-image /usr/bin/curl /bin/curl

# setup standard non-root user for use downstream
ENV USERNAME=appuser
ENV USER_GROUP=${USERNAME}
ENV HOME=/home/${USERNAME}

RUN echo "${USERNAME}:x:1000:${USERNAME}" >> /etc/group
RUN echo "${USERNAME}:x:1001:" >> /etc/group
RUN echo "${USERNAME}:x:1000:1001::${HOME}:" >> /etc/passwd

# copy app and virtual environment
COPY --chown=${USERNAME} . /app
COPY --from=builder-image --chown=${USERNAME} "$VENV" "$VENV"
COPY --from=builder-image /usr/local/lib/ /usr/local/lib/
COPY --from=builder-image /usr/local/bin/python /usr/local/bin/python

ENV PATH="/usr/local/bin:${HOME}/.local/bin:/bin:/usr/bin:${VENV}/bin:${VENV}/lib/python${PYTHON_VERSION}/site-packages:/usr/share/doc:$PATH"

# remove dev bins (need sh to run `startup.sh`)
RUN rm /bin/cat /bin/find /bin/ls /bin/rm /bin/vi /bin/which

# # QA
# CMD ["/bin/sh"]

FROM distroless AS runner-image

ARG PYTHON_VERSION=3.10
ARG USERNAME=appuser
ENV HOME=/home/${USERNAME}
ENV VENV="${HOME}/.venv"

ENV PATH="/usr/local/bin:${HOME}/.local/bin:/bin:/usr/bin:${VENV}/bin:${VENV}/lib/python${PYTHON_VERSION}/site-packages:/usr/share/doc:$PATH"

# standardise on locale, don't generate .pyc, enable tracebacks on seg faults
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

# workers per core (https://github.com/tiangolo/uvicorn-gunicorn-fastapi-docker/blob/master/README.md#web_concurrency)
ENV WEB_CONCURRENCY=1

COPY --from=busybox:uclibc /bin/chown /bin/chown
COPY --from=busybox:uclibc /bin/rm /bin/rm

RUN chown -R ${USERNAME}:${USERNAME} /app \
    && chown -R ${USERNAME}:${USERNAME} ${VENV} \
    && rm /bin/chown /bin/rm

WORKDIR /app

USER ${USERNAME}

# ENTRYPOINT ["python", "main.py"]
# CMD ["gunicorn", "-c", "config/gunicorn.conf.py", "main:app"]
# CMD ["/bin/sh", "startup.sh"]
CMD ["/bin/sh"]

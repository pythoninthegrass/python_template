# SOURCES
# https://github.com/alexdmoss/distroless-python
# https://gitlab.com/n.ragav/python-images/-/tree/master/distroless

# full semver just for python base image
ARG PYTHON_VERSION=3.10.7

# several optimisations in python-slim images already, benefit from these
FROM python:${PYTHON_VERSION}-slim-bullseye AS builder-image

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

# setup standard non-root user for use downstream
ARG USERNAME="appuser"
ARG USER_GROUP=${USERNAME}
ARG HOME="/home/${USERNAME}"

RUN groupadd ${USER_GROUP}
RUN useradd -m ${USERNAME} -g ${USER_GROUP}

# setup user environment with good python practices
USER ${USERNAME}
WORKDIR ${HOME}
ENV PATH="$HOME/.local/bin:$PATH"

# Set locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# poetry for use elsewhere as builder image
RUN pip install --upgrade pip \
    && pip install --no-cache-dir --upgrade virtualenv poetry

COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.in-project true \
    && poetry install

# build from distroless C or cc:debug, because lots of Python depends on C
FROM gcr.io/distroless/cc AS distroless

# # arch: x86_64-linux-gnu / aarch64-linux-gnu
# ARG CHIPSET_ARCH=aarch64-linux-gnu

# # required by lots of packages - e.g. six, numpy, wsgi
# COPY --from=builder-image /lib/${CHIPSET_ARCH}/libz.so.1 /lib/${CHIPSET_ARCH}/

# non-root user setup
ARG USERNAME="appuser"
ARG PYTHON_VERSION=3.10
ENV HOME="/home/${USERNAME}"

# import useful bins from busybox image
COPY --from=busybox:uclibc /bin/ls /bin/ls
COPY --from=busybox:uclibc /bin/rm /bin/rm
COPY --from=busybox:uclibc /bin/sh /bin/sh
COPY --from=busybox:uclibc /bin/find /bin/find
COPY --from=busybox:uclibc /bin/which /bin/which

ENV VENV="/opt/venv"
COPY --chown=${USERNAME} . /app
COPY --from=builder-image --chown=${USERNAME} "${HOME}/.venv" "$VENV"
COPY --from=builder-image /usr/local/lib/ /usr/local/lib/
COPY --from=builder-image /usr/local/bin/python /usr/local/bin/python
COPY --from=builder-image /etc/ld.so.cache /etc/ld.so.cache

ENV PATH="/usr/local/bin:${HOME}/.local/bin:/bin:/usr/bin:${VENV}/bin:${VENV}/lib/python${PYTHON_VERSION}/site-packages:$PATH"

RUN echo "${USERNAME}:x:1000:${USERNAME}" >> /etc/group
RUN echo "${USERNAME}:x:1001:" >> /etc/group
RUN echo "${USERNAME}:x:1000:1001::/home/${USERNAME}:" >> /etc/passwd

# standardise on locale, don't generate .pyc, enable tracebacks on seg faults
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

# remove dev bins (need sh to run `startup.sh`)
RUN rm /bin/find /bin/ls /bin/rm /bin/which

FROM distroless AS runner-image

ARG PYTHON_VERSION=3.10
ARG USERNAME=appuser
ENV HOME="/home/${USERNAME}"
ENV VENV="/opt/venv"

ENV PATH="/usr/local/bin:${HOME}/.local/bin:/bin:/usr/bin:${VENV}/bin:${VENV}/lib/python${PYTHON_VERSION}/site-packages:$PATH"

# keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# workers per core (https://github.com/tiangolo/uvicorn-gunicorn-fastapi-docker/blob/master/README.md#web_concurrency)
ENV WEB_CONCURRENCY=1

WORKDIR /app

USER ${USERNAME}

# ENTRYPOINT ["python", "main.py"]
# CMD ["gunicorn", "-c", "config/gunicorn.conf.py", "main:app"]
# CMD ["/bin/sh", "startup.sh"]
CMD ["/bin/sh"]

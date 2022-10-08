# SOURCE: https://github.com/alexdmoss/distroless-python

# several optimisations in python-slim images already, benefit from these
FROM python:3.10.7-slim-bullseye AS builder-image

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

# setup standard non-root user for use downstream
ARG USERNAME="appuser"
ARG USER_GROUP=${USERNAME}

RUN groupadd ${USER_GROUP}
RUN useradd -m ${USERNAME} -g ${USER_GROUP}

USER ${USERNAME}
ENV HOME="/home/${USERNAME}"

ENV PATH="$HOME/.local/bin:$PATH"

# setup user environment with good python practices
USER ${USERNAME}
WORKDIR /home/${USERNAME}

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

# # this carries more risk than installing it fully, but makes the image a lot smaller
# COPY --from=builder-image /usr/local/lib/ /usr/local/lib/
# COPY --from=builder-image /usr/local/bin/python /usr/local/bin/python
# COPY --from=builder-image /etc/ld.so.cache /etc/ld.so.cache

# # required by lots of packages - e.g. six, numpy, wsgi
# COPY --from=builder-image /lib/${CHIPSET_ARCH}/libz.so.1 /lib/${CHIPSET_ARCH}/

# non-root user setup
ARG USERNAME="appuser"
ARG ${PYTHON_VERSION:-3.10}
ENV HOME="/home/${USERNAME}"

COPY --from=builder-image /bin/echo /bin/echo
COPY --from=builder-image /bin/rm /bin/rm
COPY --from=builder-image /bin/sh /bin/sh

RUN echo "${USERNAME}:x:1000:${USERNAME}" >> /etc/group
RUN echo "${USERNAME}:x:1001:" >> /etc/group
RUN echo "${USERNAME}:x:1000:1001::/home/${USERNAME}:" >> /etc/passwd

ENV VENV="/opt/venv"
COPY . /app
COPY --from=builder-image "${HOME}/.venv" "$VENV"

ENV PATH="/app/.venv/bin:/app/.venv/lib/python${PYTHON_VERSION}/site-packages:$PATH"

# TODO: QA runner-image before removing shell
# RUN rm /bin/sh /bin/echo /bin/rm

# default to running as non-root, uid=1000
ARG USERNAME="appuser"
USER ${USERNAME}

ARG PYTHON_VERSION=3.10
ENV HOME="/home/${USERNAME}"
ENV VENV="/opt/venv"
ENV PATH="$HOME/.local/bin:${VENV}/bin:${VENV}/lib/python${PYTHON_VERSION}/site-packages"

# TODO: not finding python
# quick validation that python still works whilst we have a shell
RUN python --version

# standardise on locale, don't generate .pyc, enable tracebacks on seg faults
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

# ENTRYPOINT ["/usr/local/bin/python"]

FROM distroless AS runner-image

ARG ${PYTHON_VERSION:-3.10}
ARG USERNAME=appuser
ENV HOME="/home/${USERNAME}"

COPY . /app
COPY --from=distroless "${HOME}/.venv" "${HOME}/.venv"

ENV PATH="$HOME/.local/bin:${HOME}/.venv/lib/python${PYTHON_VERSION}/site-packages"

# keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# workers per core (https://github.com/tiangolo/uvicorn-gunicorn-fastapi-docker/blob/master/README.md#web_concurrency)
ENV WEB_CONCURRENCY=1

WORKDIR /app

# ENTRYPOINT ["python", "main.py"]
# CMD ["gunicorn", "-c", "config/gunicorn.conf.py", "main:app"]
# CMD ["/bin/sh", "startup.sh"]
CMD ["/bin/sh"]

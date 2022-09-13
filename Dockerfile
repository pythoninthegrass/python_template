# using ubuntu LTS version
FROM ubuntu:22.04 AS builder-image

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update \
    && apt-get -qq install \
    --no-install-recommends -y \
    aptitude \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    curl \
    git \
    locales \
    libbz2-dev \
    libffi-dev \
    libncurses-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libxslt-dev \
    libyaml-dev \
    python3 \
    python3-dev \
    python3-pip \
    sqlite3 \
    unixodbc-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ARG USERNAME=appuser
ENV HOME="/home/${USERNAME}"
ENV PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

RUN useradd --create-home $USERNAME

# install asdf then python latest
RUN bash -c "git clone --depth 1 https://github.com/asdf-vm/asdf.git $HOME/.asdf \
    && echo '. $HOME/.asdf/asdf.sh' >> $HOME/.bashrc  \
    && echo '. $HOME/.asdf/asdf.sh' >> $HOME/.profile"
RUN asdf plugin-add python \
    && asdf install python 3.10.7 \
    && asdf global python 3.10.7

# TODO: test poetry via asdf
ENV POETRY_HOME="$HOME/.poetry"
RUN curl -sSL https://install.python-poetry.org | python3.10 -
ENV PATH "${POETRY_HOME}/bin:$PATH"

WORKDIR $$HOME/app
COPY pyproject.toml poetry.lock ./
RUN python3.10 -m venv /opt/venv

# Install pip requirements
RUN . /opt/venv/bin/activate && poetry install

# TODO: dive + docker-slim
FROM ubuntu:22.04 AS runner-image

ARG USERNAME=appuser
ENV HOME="/home/${USERNAME}"
ENV VIRTUAL_ENV="/opt/venv"
ENV PATH="${VIRTUAL_ENV}/bin:$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

RUN useradd --create-home $USERNAME \
    && mkdir -p ${HOME}/app

COPY --chown=${USERNAME}:${USERNAME} . $HOME/app
COPY --from=builder-image --chown=${USERNAME}:${USERNAME} /opt/venv /opt/venv
COPY --from=builder-image --chown=${USERNAME}:${USERNAME} $HOME/.asdf $HOME/.asdf

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update \
    && apt-get -qq install \
    --no-install-recommends -y \
    ca-certificates \
    curl \
    git \
    libsqlite3-dev \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# activate virtual environment
RUN python -m venv $VIRTUAL_ENV

USER appuser

WORKDIR $HOME/app

# ENTRYPOINT ["python", "main.py"]
# CMD ["gunicorn", "-c", "config/gunicorn.conf.py", "main:app"]
CMD ["/bin/bash", "startup.sh"]
# CMD ["/bin/bash"]

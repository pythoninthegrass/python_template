FROM jupyter/minimal-notebook:latest

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

USER jovyan

COPY . $HOME/work

WORKDIR $HOME/work

RUN conda install \
    xarray \
    netCDF4 \
    bottleneck \
    numpy \
    pandas \
    matplotlib \
    jupyterlab

# ENTRYPOINT ["python", "main.py"]
CMD ["/bin/bash", "startup.sh"]
# CMD ["/bin/bash"]

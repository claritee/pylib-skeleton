# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/scipy-notebook:82b978b3ceeb

LABEL maintainer="Daniel Kovacs <dkovacs@ebay.com>"

# USER root

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
RUN bash -c "source activate python2 && pip install -r /tmp/requirements.txt"

FROM jupyter/datascience-notebook

USER root
RUN apt-get update
RUN apt-get install -y zlib1g-dev libxslt1-dev libffi-dev libssl-dev

USER jovyan
RUN pip2 install ga4gh

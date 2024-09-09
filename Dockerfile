FROM python:3.12

# aptパッケージインストールとロケール設定
# install packages by apt and set locales
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install sudo locales git && \
    apt-get clean && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF_8

ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8
ENV TZ JST-9

# update pip
RUN python -m pip install --upgrade pip && \
    python -m pip install --upgrade setuptools
# install pytorch, pytorch-lightning, pytorch-forecasting
RUN python -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu && \
    python -m pip install lightning && \
    python -m pip install pytorch-forecasting
# install other python packages
COPY requirements.txt /tmp/
RUN python -m pip install -r /tmp/requirements.txt && \
    python -m pip cache purge

# make user and add sudo group
ARG DOCKER_UID
ARG DOCKER_USER
ARG DOCKER_PASSWORD
RUN useradd -m --uid ${DOCKER_UID} --groups sudo ${DOCKER_USER} \
  && echo ${DOCKER_USER}:${DOCKER_PASSWORD} | chpasswd

# change user
USER ${DOCKER_USER}
ENV HOME /home/${DOCKER_USER}

# set working dir.
WORKDIR /home/${DOCKER_USER}

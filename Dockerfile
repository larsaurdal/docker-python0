FROM continuumio/anaconda3:latest

RUN apt-get update && apt-get install -y build-essential && \
    cd /usr/local/src && \
    # https://github.com/tensorflow/tensorflow/issues/64#issuecomment-155270240
    # Why does this work, when `pip install tensorflow` fails? It is a mystery
    wget https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.9.0-cp35-cp35m-linux_x86_64.whl && \
    pip install tensorflow-0.9.0-cp35-cp35m-linux_x86_64.whl


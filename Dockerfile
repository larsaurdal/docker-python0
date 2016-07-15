FROM continuumio/anaconda3:latest

RUN apt-get update && apt-get install -y build-essential && \
    export TF_BINARY_URL=https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.9.0-cp35-cp35m-linux_x86_64.whl && \
    pip install --upgrade $TF_BINARY_URL


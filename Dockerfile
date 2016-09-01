FROM continuumio/anaconda3:latest

RUN apt-get update && apt-get install -y build-essential && \
    cd /usr/local/src && \
    # https://github.com/tensorflow/tensorflow/issues/64#issuecomment-155270240
    # Why does this work, when `pip install tensorflow` fails? It is a mystery
    wget https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.10.0rc0-cp35-cp35m-linux_x86_64.whl && \
    pip install tensorflow-0.10.0rc0-cp35-cp35m-linux_x86_64.whl  && \
    # Vowpal Rabbit
    apt-get install -y libboost-program-options-dev zlib1g-dev libboost-python-dev && \
    cd /usr/lib/x86_64-linux-gnu/ && rm -f libboost_python.a && rm -f libboost_python.so && \ 
    ln -sf libboost_python-py34.so libboost_python.so && ln -sf libboost_python-py34.a libboost_python.a && \
    pip install vowpalwabbit && \
    # Clean up install cruft
    rm tensorflow-0.10.0rc0-cp35-cp35m-linux_x86_64.whl && \
    rm -rf /root/.cache/pip/* && \
    apt-get autoremove -y && \
    apt-get clean


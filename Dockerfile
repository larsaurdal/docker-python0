FROM continuumio/anaconda3:latest

RUN apt-get update && apt-get install -y build-essential && \
    # Add JDK8 to allow Bazel (required for TensorFlow)
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list &&     echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list &&     apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 C857C906 2B90D010 && \
    apt-get update && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    # Docker build permissions necessitate building bazel from source (which in turn
    # requires JDK8 not JDK7).
    cd /usr/local/src && \
    git clone https://github.com/bazelbuild/bazel.git && \
    apt-get install -y unzip swig pkg-config zip zlib1g-dev && \
    cd bazel && ./compile.sh && \
    mv /usr/local/src/bazel/output/bazel /usr/local/bin && \
    cd /usr/local/src &&  git clone --recurse-submodules https://github.com/tensorflow/tensorflow &&  cd tensorflow && \
    (echo /opt/conda/bin/python; echo N;) | ./configure

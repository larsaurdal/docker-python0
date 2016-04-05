FROM continuumio/anaconda3:latest

    # g++4.8 (needed for MXNet) is not currently available via the default apt-get
    # channels, so we add the Ubuntu repository (which requires python-software-properties
    # so we can call `add-apt-repository`. There's also some mucking about with GPG keys
    # required.
RUN apt-get install -y build-essential python-software-properties && \
    add-apt-repository "deb http://archive.ubuntu.com/ubuntu trusty main" && \
    apt-get install debian-archive-keyring && apt-key update && apt-get update && \
    apt-get install --force-yes -y ubuntu-keyring && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5 3B4FE6ACC0B21F32 && \
    mv /var/lib/apt/lists /tmp && mkdir -p /var/lib/apt/lists/partial && \
    apt-get clean && apt-get update && apt-get install -y g++-4.8 gfortran-4.8 && \
    # Make `g++` etc now default to 4.8, so that everything builds and links in beautiful synchrony
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 100 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 100 && \
    update-alternatives --install /usr/bin/cpp cpp-bin /usr/bin/cpp-4.8 100 && \
    update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-4.8 100 && \
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

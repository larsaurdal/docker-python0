FROM continuumio/anaconda3:latest

    # g++4.8 (needed for MXNet) is not currently available via the default apt-get
    # channels, so we add the Ubuntu repository (which requires python-software-properties
    # so we can call `add-apt-repository`. There's also some mucking about with GPG keys
    # required.
RUN apt-get install -y python-software-properties && \
    add-apt-repository "deb http://archive.ubuntu.com/ubuntu trusty main" && \
    apt-get install debian-archive-keyring && apt-key update && apt-get update && \
    apt-get install --force-yes -y ubuntu-keyring && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5 3B4FE6ACC0B21F32 && \
    mv /var/lib/apt/lists /tmp && mkdir -p /var/lib/apt/lists/partial && \
    apt-get clean && apt-get update && apt-get install -y g++-4.8 gfortran-4.8 && \
    ln -s /usr/bin/gcc-4.8 /usr/bin/gcc && \
    ln -s /usr/bin/g++-4.8 /usr/bin/g++ && \
    ln -s /usr/bin/gfortran-4.8 /usr/bin/gfortran &&\
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
    (echo /opt/conda/bin/python; echo N;) | ./configure && \
    mkdir -p /usr/local/src/tfbuild && \
    # For the *_strategy options see https://github.com/bazelbuild/bazel/issues/698#issuecomment-164041244
    TEST_TMPDIR=/usr/local/src/tfbuild bazel build --verbose_failures --genrule_strategy=standalone --spawn_strategy=standalone -c opt //tensorflow/tools/pip_package:build_pip_package && \
    bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg && \
    cd /tmp/tensorflow_pkg && pip install `find . -name "*whl"`


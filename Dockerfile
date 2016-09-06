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
    # The apt-get version of imagemagick is out of date and has compatibility issues, so we build from source
    apt-get -y install dbus fontconfig fontconfig-config fonts-dejavu-core fonts-droid ghostscript gsfonts hicolor-icon-theme \
  libavahi-client3 libavahi-common-data libavahi-common3 libcairo2 libcap-ng0 libcroco3 \
  libcups2 libcupsfilters1 libcupsimage2 libdatrie1 libdbus-1-3 libdjvulibre-text libdjvulibre21 libfftw3-double3 libfontconfig1 \
  libfreetype6 libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgomp1 libgraphite2-3 libgs9 libgs9-common libharfbuzz0b libijs-0.35 \
  libilmbase6 libjasper1 libjbig0 libjbig2dec0 libjpeg62-turbo liblcms2-2 liblqr-1-0 libltdl7 libmagickcore-6.q16-2 \
  libmagickcore-6.q16-2-extra libmagickwand-6.q16-2 libnetpbm10 libopenexr6 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 \
  libpaper-utils libpaper1 libpixman-1-0 libpng12-0 librsvg2-2 librsvg2-common libthai-data libthai0 libtiff5 libwmf0.2-7 \
  libxcb-render0 libxcb-shm0 netpbm poppler-data && \
    wget http://www.imagemagick.org/download/ImageMagick-7.0.3-0.tar.gz && \
    tar xzf ImageMagick-7.0.3-0.tar.gz && cd ImageMagick-7.0.3-0 && ./configure && \
    make -j $(nproc) && make install && \
    # clean up ImageMagick source files
    cd ../ && rm -rf ImageMagick-7.0.3* && \
    apt-get -y install libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev && \
    apt-get -y install libtbb2 libtbb-dev libjpeg-dev libtiff-dev libjasper-dev && \
    apt-get -y install cmake && \
    cd /usr/local/src && git clone --depth 1 https://github.com/Itseez/opencv.git && \
    cd opencv && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D WITH_FFMPEG=OFF -D WITH_V4L=ON -D WITH_QT=OFF -D WITH_OPENGL=ON -D PYTHON3_LIBRARY=/opt/conda/lib/libpython3.5m.so -D PYTHON3_INCLUDE_DIR=/opt/conda/include/python3.5m/ -D PYTHON_LIBRARY=/opt/conda/lib/libpython3.5m.so -D PYTHON_INCLUDE_DIR=/opt/conda/include/python3.5m/ -D BUILD_PNG=TRUE .. && \
    make -j $(nproc) && make install && \
    echo "/usr/local/lib/python3.5/site-packages" > /etc/ld.so.conf.d/opencv.conf && ldconfig && \
    cp /usr/local/lib/python3.5/site-packages/cv2.cpython-35m-x86_64-linux-gnu.so /opt/conda/lib/python3.5/site-packages/ && \
    # Clean up install cruft
    rm -rf /usr/local/src/opencv && \
    rm /usr/local/src/tensorflow-0.10.0rc0-cp35-cp35m-linux_x86_64.whl && \
    rm -rf /root/.cache/pip/* && \
    apt-get autoremove -y && apt-get clean


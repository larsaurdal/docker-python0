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
    apt-get clean && apt-get update && apt-get install -y g++-4.8 && \
    ln -s /usr/bin/gcc-4.8 /usr/bin/gcc
    
    # using python 3.4 instead of 3.5 because tensorflow's install breaks on 3.5
RUN conda install anaconda python=3.4 -y && \
    # TensorFlow wants bleeding-edge versions of numpy, setuptools and protobuf which
    # clash with the conda-based installs of numpy and setuptools. So we first remove
    # the existing installs and then replace them with the pip-based ones, so that
    # other numpy-based packages will link correctly.
    conda remove -y numpy && conda remove -y setuptools && \
    # In building numpy from source, it's hard to persuade it to use gcc, so here's a patch
    ln -s /usr/bin/gcc /usr/local/bin/cc && \
    pip install --upgrade setuptools && \
    pip install --upgrade protobuf && pip install --upgrade numpy && \
    conda install statsmodels seaborn python-dateutil nltk spacy dask -y -q && \
    pip install pytagcloud pyyaml ggplot theano joblib husl geopy ml_metrics mne pyshp gensim && \
    apt-get update && apt-get install -y git && apt-get install -y build-essential && \
    apt-get install -y libfreetype6-dev && \
    apt-get install -y libglib2.0-0 libxext6 libsm6 libxrender1 libfontconfig1 --fix-missing && \
    # Latest sklearn && \
    pip install --upgrade cython && \
    cd /usr/local/src && git clone https://github.com/scikit-learn/scikit-learn.git && \
    cd scikit-learn && python setup.py build && python setup.py install && \
    # textblob
    pip install textblob && \
    #word cloud
    pip install git+git://github.com/amueller/word_cloud.git && \
    #igraph
    pip install python-igraph && \
    #xgboost
    cd /usr/local/src && mkdir xgboost && cd xgboost && \
    git clone --recursive https://github.com/dmlc/xgboost.git && cd xgboost && \
    make && cd python-package && python setup.py install && \
    #lasagne
    cd /usr/local/src && mkdir Lasagne && cd Lasagne && \
    git clone https://github.com/Lasagne/Lasagne.git && cd Lasagne && \
    pip install -r requirements.txt && python setup.py install && \
    #keras
    cd /usr/local/src && mkdir keras && cd keras && \
    git clone https://github.com/fchollet/keras.git && \
    cd keras && python setup.py install && \
    #neon
    cd /usr/local/src && \
    git clone https://github.com/NervanaSystems/neon.git && \
    cd neon && pip install -e . && \
    #nolearn
    cd /usr/local/src && mkdir nolearn && cd nolearn && \
    git clone https://github.com/dnouri/nolearn.git && cd nolearn && \
    echo "x" > README.rst && echo "x" > CHANGES.rst && \
    python setup.py install && \
    # put theano compiledir inside /tmp (it needs to be in writable dir)
    printf "[global]\nbase_compiledir = /tmp/.theano\n" > /.theanorc && \
    cd /usr/local/src &&  git clone https://github.com/pybrain/pybrain && \
    cd pybrain && python setup.py install && \
    # Base ATLAS plus tSNE
    apt-get install -y libatlas-base-dev && \
    # NOTE: we provide the tsne package, but sklearn.manifold.TSNE now does the same
    # job
    cd /usr/local/src && git clone https://github.com/danielfrg/tsne.git && \
    cd tsne && python setup.py install && \
    cd /usr/local/src && git clone https://github.com/ztane/python-Levenshtein && \
    cd python-Levenshtein && python setup.py install && \
    cd /usr/local/src && git clone https://github.com/arogozhnikov/hep_ml.git && \
    cd hep_ml && pip install .  && \
    # chainer
    pip install chainer && \
    # NLTK Project datasets
    mkdir -p /usr/share/nltk_data && \
    # NLTK Downloader no longer continues smoothly after an error, so we explicitly list
    # the corpuses that work
    python -m nltk.downloader -d /usr/share/nltk_data abc alpino \
    averaged_perceptron_tagger basque_grammars biocreative_ppi bllip_wsj_no_aux \
book_grammars brown brown_tei cess_cat cess_esp chat80 city_database cmudict \
comparative_sentences comtrans conll2000 conll2002 conll2007 crubadan dependency_treebank \
europarl_raw floresta framenet_v15 gazetteers genesis gutenberg hmm_treebank_pos_tagger \
ieer inaugural indian jeita kimmo knbc large_grammars lin_thesaurus mac_morpho machado \
masc_tagged maxent_ne_chunker maxent_treebank_pos_tagger moses_sample movie_reviews \
mte_teip5 names nps_chat omw opinion_lexicon panlex_swadesh paradigms \
pil pl196x ppattach problem_reports product_reviews_1 product_reviews_2 propbank \
pros_cons ptb punkt qc reuters rslp rte sample_grammars semcor senseval sentence_polarity \
sentiwordnet shakespeare sinica_treebank smultron snowball_data spanish_grammars \
state_union stopwords subjectivity swadesh switchboard tagsets timit toolbox treebank \
twitter_samples udhr2 udhr unicode_samples universal_tagset universal_treebanks_v20 \
verbnet webtext word2vec_sample wordnet wordnet_ic words ycoe && \
    # Stop-words
    pip install stop-words

    # Prepare for OpenCV 3
RUN apt-get update && \
    # The apt-get version of imagemagick has gone mad, and wants to remove sysvinit.
    apt-get -y build-dep imagemagick && \
    wget http://www.imagemagick.org/download/ImageMagick-6.9.3-7.tar.gz && \
    tar xzf ImageMagick-6.9.3-7.tar.gz && cd ImageMagick-6.9.3-7 && ./configure && \
    make && make install && \
    apt-get -y install libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev && \
    apt-get -y install libtbb2 libtbb-dev libjpeg-dev libtiff-dev libjasper-dev && \
    # apt-get gives you cmake 2.8, which fails to find Py3.4's libraries and headers. The current
    # version is cmake 3.2, which does.
    cd /usr/local/src && git clone https://github.com/Kitware/CMake.git && \
    # --system-curl needed for OpenCV's IPP download, see https://stackoverflow.com/questions/29816529/unsupported-protocol-while-downlod-tar-gz-package/32370027#32370027
    cd CMake && ./bootstrap --system-curl && make && make install && \
    cd /usr/local/src && git clone https://github.com/Itseez/opencv.git

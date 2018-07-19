FROM nimbix/xilinx-ml-suite-base:latest

# JARVICE doesn't support straight Debian containers, so install Anaconda 2
# into this Ubuntu one rather than use FROM continuumio/anaconda above
WORKDIR /tmp
ENV PATH=/opt/anaconda2/bin:${PATH}
RUN curl -O https://repo.anaconda.com/archive/Anaconda2-5.1.0-Linux-x86_64.sh && bash ./Anaconda2-5.1.0-Linux-x86_64.sh -b -p /opt/anaconda2 && rm -f Anaconda2-5.1.0-Linux-x86_64.sh && conda update -n base conda && conda clean -y --all

# helper in case someone runs sudo conda
COPY conda /usr/bin/conda
RUN ln -s /opt/anaconda2/etc/profile.d/conda.sh /etc/profile.d/conda.sh

# deploy the Anaconda EULA so that JARVICE prompts the end user to accept it,
# since we accepted it in batch above
RUN mkdir -p /etc/NAE && cp -f /opt/anaconda2/LICENSE.txt /etc/NAE/license.txt

# Create the ml-suite Anaconda Virtual Environment...
# see: https://github.com/Xilinx/ml-suite/blob/v1.0-ea/docs/tutorials/start-anaconda.md
RUN conda create -y --name ml-suite python=2.7 jupyter caffe pydot pydot-ng graphviz -c conda-forge && conda clean -y --all

# clone ml-suite from Xilinx to /usr/src, then link it into $HOME in skep
WORKDIR /usr/src
ENV XILINX_ML_SUITE_BRANCH master
ENV XILINX_ML_SUITE_CLONE_TIMESTAMP "Wed Jul 18 15:49:55 UTC 2018"
RUN git clone -b ${XILINX_ML_SUITE_BRANCH} https://github.com/Xilinx/ml-suite.git && make -C /usr/src/ml-suite/apps/yolo/nms && make && cd /usr/src && chown -R nimbix:nimbix ml-suite
RUN ln -s /usr/src/ml-suite /etc/skel/ml-suite
WORKDIR /data

# link in the models - in the future this may not be necessary, but note they
# are provided by the FROM image above
RUN ln -s /usr/src/models /usr/src/ml-suite/models

# Fix up - temporarily link in anaconda2 so we don't have to modify the script
RUN ln -s /opt/anaconda2 ~/anaconda2 && bash /etc/skel/ml-suite/fix_caffe_opencv_symlink.sh && rm -f ~/anaconda2

# motd and AppDef, URL override, and launcher for notebooks
COPY motd /etc/motd
COPY AppDef.json /etc/NAE/AppDef.json
COPY url.txt /etc/NAE/url.txt
COPY ml-notebooks /usr/local/bin/ml-notebooks
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate


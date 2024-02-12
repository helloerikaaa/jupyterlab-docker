# Use Ubuntu 22.04 as base image
FROM ubuntu:22.04

# Install OS packages 
RUN apt update
RUN apt upgrade -y
RUN apt install git curl vim build-essential gcc-9 g++-9 -y

# Install Python 3 (Version 3.9 is the default on Ubuntu 22.04)
RUN apt install -y python3-dev python3-pip

# Install Node.js and npm (dependencies for Jupyterlab extensions)
RUN apt install -y nodejs npm

# Install and configure Jupyterlab
RUN mkdir -p /opt/jupyterlab/
RUN pip3 install jupyterlab jupyter ipywidgets
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
RUN jupyter nbextension enable --py widgetsnbextension
RUN jupyter serverextension enable --py jupyterlab

# Configure Jupyterlab Kernel for Python 2 & 3
RUN pip3 install ipykernel
RUN python3 -m ipykernel install

# Set blank password on notebook. Comment out this to require password on startup
RUN echo "c.NotebookApp.token = u''" >> ~/.jupyter/jupyter_notebook_config.py

# Set working directory
WORKDIR /opt/jupyterlab

############################
# Install Default Packages #
############################

RUN pip3 install pandas numpy scipy matplotlib scikit-learn seaborn tqdm torch torchvision torchaudio 

############################
# Install CUDA             #
############################
RUN apt install ubuntu-drivers-common
RUN apt install nvidia-driver-525
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
RUN dpkg -i cuda-keyring_1.1-1_all.deb
RUN apt-get update
RUN apt-get -y install cuda-toolkit-12-3
RUN echo "PATH=/usr/local/cuda/bin${PATH:+:${PATH}}" >> ~/.bashrc
RUN echo "LD_LIBRARY_PATH=/usr/local/cuda-12.2/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" >> ~/.bashrc
RUN source ~/.bashrc

##########################
# Launch Notebook Server #
##########################

# Expose lab server port and run
EXPOSE 9999
CMD jupyter lab --ip=0.0.0.0 --port=9999 --no-browser --notebook-dir=/opt/jupyterlab/ --allow-root --NotebookApp.token=
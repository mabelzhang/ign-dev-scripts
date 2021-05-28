# Install dependencies of Gazebo 7, but not Gazebo 7 itself, so that it can
# be built from source inside the container for development.

# Adapted from subt Gazebo 9 (from binaries) Dockerfile
#   https://bitbucket.org/osrf/subt/src/gazebo9/docker/subt/Dockerfile

# Base on Kinetic Dockerfile with NVIDIA
FROM ros_kinetic_deb_nvidia

RUN export DEBIAN_FRONTEND=noninteractive \
 && sudo apt-get update \
 && sudo -E apt-get install -y \
    tzdata \
 && sudo ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
 && sudo dpkg-reconfigure --frontend noninteractive tzdata \
 && sudo apt-get clean

RUN sudo apt-get install -y \
    pkg-config \
    ccache \
    python-rosinstall \
    python-rosinstall-generator \
    python-wstool \
 && sudo apt-get clean

RUN rosdep update

# Clone all the gazebo models so that you don't download them every time
# docker is run
# RUN mkdir -p /home/$USERNAME/.gazebo && git clone https://github.com/osrf/gazebo_models /home/$USERNAME/.gazebo/models

# Instructions specific to a setup to build Gazebo from source

# Remove binary installation of Gazebo-related libraries
# http://gazebosim.org/tutorials?tut=install_from_source&cat=install
RUN sudo apt-get remove -y '.*gazebo.*' '.*sdformat.*' '.*ignition-.*'

RUN sudo /bin/sh -c 'wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -' \
 && sudo /bin/sh -c 'apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654'

RUN sudo apt-get update && sudo apt-get install -y \
    libzmq3-dev protobuf-compiler
    #libzmq-dev libzmq5 libzmq3-dev protobuf-compiler

# Dependencies for installing Gazebo from source
RUN sudo apt-get install -y libccd-dev libbullet-dev

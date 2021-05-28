# Install dependencies of Gazebo 7, but not Gazebo 7 itself, so that it can
# be built from source inside the container for development.

# Adapted from subt Gazebo 9 (from binaries) Dockerfile
#   https://bitbucket.org/osrf/subt/src/gazebo9/docker/subt/Dockerfile

# Installs from scratch
# NVIDIA for Gazebo GUI
FROM nvidia/opengl:1.1-glvnd-devel-ubuntu16.04

RUN apt-get update \
 && apt-get install -y \
        build-essential \
        cmake \
        cppcheck \
        gdb \
        git \
        libbluetooth-dev \
        libcwiid-dev \
        libgoogle-glog-dev \
        libspnav-dev \
        libusb-dev \
        lsb-release \
        mercurial \
        python3-dbg \
        python3-empy \
        python3-numpy \
        python3-pip \
        python3-venv \
        software-properties-common \
        sudo \
        vim \
        wget \
 && apt-get clean


# Add a user with the same user_id as the user outside the container
# Requires a docker build argument `user_id`
ARG user_id
ENV USERNAME developer
RUN useradd -U --uid ${user_id} -ms /bin/bash $USERNAME \
 && echo "$USERNAME:$USERNAME" | chpasswd \
 && adduser $USERNAME sudo \
 && echo "$USERNAME ALL=NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME

# Commands below run as the developer user
USER $USERNAME

# Make a couple folders for organizing docker volumes
RUN mkdir ~/workspaces ~/other

# When running a container start in the developer's home folder
WORKDIR /home/$USERNAME


RUN export DEBIAN_FRONTEND=noninteractive \
 && sudo apt-get update \
 && sudo -E apt-get install -y \
    tzdata \
 && sudo ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
 && sudo dpkg-reconfigure --frontend noninteractive tzdata \
 && sudo apt-get clean

# ROS 1 Kinetic
#RUN sudo /bin/sh -c 'echo "deb [trusted=yes] http://packages.ros.org/ros/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros-latest.list' \
# && sudo /bin/sh -c 'echo "deb [trusted=yes] http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' \
# && sudo /bin/sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-prerelease `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-prerelease.list' \
# && sudo /bin/sh -c 'wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -' \
# && sudo /bin/sh -c 'apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' \
# && sudo apt-get update \
# && sudo apt-get install -y \
#    pkg-config \
#    ccache
#    python-catkin-tools \
#    python-rosinstall \
#    ros-kinetic-desktop-full \
#    python-rosdep \
#    python-rosinstall-generator \
#    python-wstool \
# && sudo apt-get clean

# Gazebo 7 dependencies
RUN sudo /bin/sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'

RUN wget https://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add - \
 && sudo apt-get update

RUN wget https://raw.githubusercontent.com/ignition-tooling/release-tools/master/jenkins-scripts/lib/dependencies_archive.sh -O /tmp/dependencies.sh \
 && GAZEBO_MAJOR_VERSION=7 . /tmp/dependencies.sh \
 && sudo apt-get update \
 && echo $BASE_DEPENDENCIES $GAZEBO_BASE_DEPENDENCIES | tr -d '\\' | xargs sudo apt-get -y install

#RUN sudo rosdep init
#RUN rosdep update

# Clone all the gazebo models so that you don't download them every time
# docker is run
# RUN mkdir -p /home/$USERNAME/.gazebo && git clone https://github.com/osrf/gazebo_models /home/$USERNAME/.gazebo/models

# Instructions specific to a setup to build Gazebo from source

# Remove binary installation of Gazebo-related libraries
# http://gazebosim.org/tutorials?tut=install_from_source&cat=install
RUN sudo apt-get remove -y '.*gazebo.*' '.*sdformat.*' '.*ignition-.*'

# Dependencies for installing Gazebo from source
RUN sudo apt-get update && sudo apt-get install -y \
    libzmq3-dev protobuf-compiler
    #libzmq-dev libzmq5

# Dependencies for installing Gazebo from source
RUN sudo apt-get install -y libccd-dev libbullet-dev libogre-1.9-dev libqt4-dev ccache

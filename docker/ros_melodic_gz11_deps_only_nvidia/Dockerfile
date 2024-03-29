# Install dependencies of Gazebo 11, but not Gazebo 11 itself, so that it can
# be built from source inside the container for development.

# Adapted from subt Gazebo 9 (from Debian) Dockerfile
#   https://bitbucket.org/osrf/subt/src/gazebo9/docker/subt/Dockerfile

# Ubuntu 18.04 with nvidia-docker2 beta opengl support
FROM nvidia/opengl:1.0-glvnd-devel-ubuntu18.04

# Tools I find useful during development
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
        ruby2.5 \
        ruby2.5-dev \
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

RUN sudo /bin/sh -c 'echo "deb [trusted=yes] http://packages.ros.org/ros/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros-latest.list' \
 && sudo /bin/sh -c 'echo "deb [trusted=yes] http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' \
 && sudo /bin/sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-prerelease `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-prerelease.list' \
 && sudo /bin/sh -c 'wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -' \
 && sudo /bin/sh -c 'apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' \
 && sudo apt-get update \
 && sudo apt-get install -y \
    python-catkin-tools \
    python-rosinstall \
    ros-melodic-desktop-full \
    ros-melodic-joystick-drivers \
    ros-melodic-pointcloud-to-laserscan \
    ros-melodic-robot-localization \
    ros-melodic-spacenav-node \
    ros-melodic-tf2-sensor-msgs \
    ros-melodic-twist-mux \
    ros-melodic-velodyne-simulator \
    python-rosdep \
    python-rosinstall-generator \
    python-wstool \
 && sudo apt-get clean

RUN sudo rosdep init
RUN rosdep update

# Clone all the gazebo models so that you don't download them every time
# docker is run
# RUN mkdir -p /home/$USERNAME/.gazebo && git clone https://github.com/osrf/gazebo_models /home/$USERNAME/.gazebo/models

# Instructions specific to a setup to build Gazebo from source

# Remove Debian installation of Gazebo-related libraries
# http://gazebosim.org/tutorials?tut=install_from_source&cat=install
RUN sudo apt-get remove -y '.*gazebo.*' '.*sdformat.*' '.*ignition-.*'

# Dependencies for installing Gazebo from source
# http://gazebosim.org/tutorials?tut=install_dependencies_from_source
RUN sudo apt-get install -y pkg-config
RUN sudo apt-get install -y libdart6-dev
RUN sudo apt-get install -y ccache python3-colcon-common-extensions

# Optional: Extra dependencies for VRX and VORC
RUN sudo apt-get install -y ros-melodic-joy-teleop ros-melodic-joy \
    ros-melodic-teleop-twist-keyboard ros-melodic-velodyne-simulator \
    ros-melodic-hector-gazebo-plugins
RUN pip3 install oyaml

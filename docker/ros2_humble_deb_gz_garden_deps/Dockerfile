# Install all the dependencies required for building Gazebo from source
#   https://gazebosim.org/docs/garden/install_ubuntu_src
# Gazebo itself is not installed. A directory containing the source code
# can be mounted from the host when run the container, and compiled within
# the container.

# ROS 2 Humble binary install
# http://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html

# Ubuntu with nvidia-docker2 beta opengl support
# https://hub.docker.com/r/nvidia/opengl
# Doesn't exist yet as of 13 Jan 2023
#FROM nvidia/opengl:1.0-glvnd-devel-ubuntu22.04

# Use my home-baked image with NVIDIA for X server, built from
# ../nvidia_opengl_ubuntu22/Dockerfile
FROM nvidia_opengl_ubuntu22:latest

# This avoids keyboard interaction when asked for geographic area
ARG DEBIAN_FRONTEND=noninteractive

# doxygen is removed, flex and bison added, because doxygen in Jammy has
# a bug that generates garbled characters. Doxygen 1.9.2 fixes it, so we
# will build that from source for the time being.
# https://github.com/gazebosim/docs/pull/388
RUN apt-get update \
 && apt-get install -y \
        bison \
        build-essential \
        cmake \
        cppcheck \
        curl \
        #doxygen \
        flex \
        gdb \
        git \
        gnupg2 \
        libbluetooth-dev \
        libcwiid-dev \
        libgoogle-glog-dev \
        libspnav-dev \
        libusb-dev \
        locales \
        lsb-release \
        mercurial \
        python3-dbg \
        python3-empy \
        python3-numpy \
        python3-pip \
        python3-psutil \
        python3-venv \
        software-properties-common \
        sudo \
        tzdata \
        vim \
        wget \
        curl \
 && apt-get clean

# Set Locale for ROS 2
RUN locale-gen en_US en_US.UTF-8 && \
  update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
  export LANG=en_US.UTF-8

# Add ROS 2 apt repository
# This doesn't work, says malformed entry 1 in ros2.list
# Set up keys
#RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
# Set up sources.list
#RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null'
# Set up keys
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
# Set up sources.list
RUN sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'

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

# When running a container start in the developer's home folder
WORKDIR /home/$USERNAME

RUN export DEBIAN_FRONTEND=noninteractive

# Install ROS 2 and Gazebo build tools
# https://colcon.readthedocs.io/en/released/user/installation.html
RUN sudo apt-get update \
 && sudo apt-get install -y \
    python3-vcstool \
    python3-colcon-common-extensions \
    ros-humble-desktop \
 && sudo apt-get clean

# From https://github.com/gazebosim/docs/pull/388
# The version of doxygen in Jammy has a bug that generates garbled characters
# when processing xml comment code blocks in markdown. We build doxygen 1.9.2
# from source here since the problem appears to be fixed in that version.
# Adapted from the Dockerfile in the doxygen repo
RUN git clone https://github.com/doxygen/doxygen.git -b Release_1_9_2 \
 && cd doxygen \
 && mkdir build \
 && cd build \
 && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr .. \
 && make \
 && sudo make install \
 && cd ../..

# Check out Gazebo source, just to get dependency packages below
ENV IGN_WS /home/$USERNAME/gz_ws
RUN mkdir -p ${IGN_WS}/src \
 && cd ${IGN_WS}/src \
 && wget https://raw.githubusercontent.com/gazebo-tooling/gazebodistro/master/collection-garden.yaml \
 && vcs import < collection-garden.yaml

# Install Gazebo dependencies
# This parses Gazebo source tree to find package dependencies
RUN sudo /bin/sh -c 'wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg' \
 && /bin/sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null' \
 && sudo apt-get update \
 && sudo apt-get install -y \
  $(sort -u $(find . -iname 'packages-'`lsb_release -cs`'.apt' -o -iname 'packages.apt' | grep -v '/\.git/') | sed '/gz\|sdf/d' | tr '\n' ' ')

# ign-launch dependency
RUN sudo apt-get install -y libdw-dev

# Remove Gazebo source
RUN rm -r ${IGN_WS}

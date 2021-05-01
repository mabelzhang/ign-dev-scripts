# Install all the dependencies required for building Ignition from source
#   https://ignitionrobotics.org/docs/edifice/install_ubuntu_src
# Ignition itself is not installed. A directory containing the source code
# can be mounted from the host when run the container, and compiled within
# the container.

# Adapted from subt Gazebo 9 Dockerfile
#   https://bitbucket.org/osrf/subt/src/gazebo9/docker/subt/Dockerfile

# Ubuntu with nvidia-docker2 beta opengl support
FROM nvidia/opengl:1.0-glvnd-devel-ubuntu20.04

# This avoids keyboard interaction when asked for geographic area
ARG DEBIAN_FRONTEND=noninteractive

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
        curl \
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

# When running a container start in the developer's home folder
WORKDIR /home/$USERNAME

RUN export DEBIAN_FRONTEND=noninteractive \
 && sudo apt-get update \
 && sudo -E apt-get install -y \
    tzdata \
 && sudo ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
 && sudo dpkg-reconfigure --frontend noninteractive tzdata \
 && sudo apt-get clean

# Install Ignition build tools
# https://colcon.readthedocs.io/en/released/user/installation.html
RUN sudo /bin/sh -c 'echo "deb [arch=amd64,arm64] http://repo.ros2.org/ubuntu/main `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list' \
 && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add - \
 && sudo apt-get update \
 && sudo apt-get install -y python3-vcstool python3-colcon-common-extensions

# Check out Ignition source, just to get dependency packages below
ENV IGN_WS /home/$USERNAME/ign_ws
RUN mkdir -p ${IGN_WS}/src \
 && cd ${IGN_WS}/src \
 && wget https://raw.githubusercontent.com/ignition-tooling/gazebodistro/master/collection-dome.yaml \
 && vcs import < collection-dome.yaml

# Install Ignition dependencies
# This parses Ignition source tree to find package dependencies
RUN sudo /bin/sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' \
 && sudo /bin/sh -c 'wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -' \
 && sudo apt-get update \
 && sudo apt-get install -y \
  $(sort -u $(find . -iname 'packages-'`lsb_release -cs`'.apt' -o -iname 'packages.apt' | grep -v '/\.git/') | sed '/ignition\|sdf/d' | tr '\n' ' ')

# sdformat10 dependencies
RUN sudo apt-get install -y \
    python3-psutil \
    doxygen

# Remove Ignition source
RUN rm -r ${IGN_WS}

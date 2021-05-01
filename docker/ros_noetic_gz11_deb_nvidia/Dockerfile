# Install ROS Noetic and Gazebo 11 from binary packages

# Adapted from subt Gazebo 9 (from Debian) Dockerfile
#   https://bitbucket.org/osrf/subt/src/gazebo9/docker/subt/Dockerfile

# Ubuntu 20.04 with nvidia-docker2 beta opengl support
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

# export lines below don't seem to be working
ARG DEBIAN_FRONTEND=noninteractive

# This avoids keyboard interaction when asked for geographic area
# export lines below don't seem to be working
RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install -y keyboard-configuration

RUN export DEBIAN_FRONTEND=noninteractive \
 && sudo apt-get update \
 && sudo -E apt-get install -y \
    tzdata \
 && sudo ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
 && sudo dpkg-reconfigure --frontend noninteractive tzdata \
 && sudo apt-get clean

RUN export DEBIAN_FRONTEND=noninteractive \
 && sudo /bin/sh -c 'echo "deb [trusted=yes] http://packages.ros.org/ros/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros-latest.list' \
 && sudo /bin/sh -c 'echo "deb [trusted=yes] http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' \
 && sudo /bin/sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-prerelease `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-prerelease.list' \
 && sudo /bin/sh -c 'wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -' \
 && sudo /bin/sh -c 'apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' \
 && sudo apt-get update \
 && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3-catkin-tools \
    python3-rosinstall \
    ros-noetic-desktop-full \
    ros-noetic-joystick-drivers \
    ros-noetic-pointcloud-to-laserscan \
    ros-noetic-robot-localization \
    ros-noetic-spacenav-node \
    ros-noetic-tf2-sensor-msgs \
    ros-noetic-twist-mux \
    ros-noetic-velodyne-simulator \
    python3-rosdep \
    python3-rosinstall-generator \
    python3-wstool \
 && sudo rosdep init \
 && sudo apt-get clean

RUN rosdep update

# Clone all the gazebo models so that you don't download them every time
# docker is run
#RUN mkdir -p /home/$USERNAME/.gazebo && git clone https://github.com/osrf/gazebo_models /home/$USERNAME/.gazebo/models

# Gazebo 11 install from Debian
RUN sudo apt-get update \
  && sudo apt-get install -y libsdformat9* \
  && sudo apt-get install -y libgazebo11*

RUN sudo apt-get install -y ccache python3-colcon-common-extensions

# Optional: Extra dependencies for VRX and VORC
RUN sudo apt-get install -y ros-noetic-joy-teleop ros-noetic-joy \
    ros-noetic-teleop-twist-keyboard ros-noetic-velodyne-simulator \
    ros-noetic-hector-gazebo-plugins
RUN pip3 install oyaml

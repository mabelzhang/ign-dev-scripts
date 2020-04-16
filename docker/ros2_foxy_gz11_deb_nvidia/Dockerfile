# Gazebo 11 from Debian, ROS 2 Foxy from source, on top of NVIDIA on Ubuntu
# 20.04 so can run Gazebo GUI.

# 15 Apr 2020

# Ubuntu 20.04 with NVIDIA built from ../nvidia_opengl_ubuntu20/Dockerfile
FROM nvidia_opengl_ubuntu20:latest


#####
# ROS 2 Foxy. Copied from
# github.com/mabelzhang/ros-dev-scripts/docker/ros2_latest_src/Dockerfile

# Set Locale
RUN apt-get update && apt-get install -y locales && \
  locale-gen en_US en_US.UTF-8 && \
  update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
  export LANG=en_US.UTF-8

# Add ROS 2 apt repository
# setup keys
RUN apt-get update && apt-get install -y curl gnupg2 lsb-release && \
  curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
# setup sources.list
RUN sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'


#####
# From subt_docker

RUN apt-get update \
 && apt-get install -y \
    sudo \
    vim

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

USER root


# Install development tools and ROS tools
# Avoid keyboard interaction
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
  build-essential \
  cmake \
  git \
  python3-colcon-common-extensions \
  python3-flake8 \
  python3-pip \
  python3-pytest-cov \
  python3-rosdep \
  python3-setuptools \
  python3-vcstool \
  wget
# install some pip packages needed for testing
RUN python3 -m pip install -U \
  argcomplete \
  flake8 \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures \
  pytest
# install Fast-RTPS dependencies
RUN apt-get install --no-install-recommends -y \
  libasio-dev \
  libtinyxml2-dev
# install CycloneDDS dependencies
#RUN apt-get install --no-install-recommends -y \
#  libcunit1-dev

# clone source
ENV ROS2_WS /opt/ros2_ws/foxy
RUN mkdir -p ${ROS2_WS}/src
RUN cd ${ROS2_WS} && \
  wget https://raw.githubusercontent.com/ros2/ros2/master/ros2.repos && \
  vcs import src < ros2.repos

# Install dependencies using rosdep
# Use non-root for rosdep
USER $USERNAME
# Set env var again after changing user name
ENV ROS2_WS /opt/ros2_ws/foxy
# Dependency for one of the packages
RUN sudo apt-get install -y libssl-dev
RUN sudo rosdep init && \
  rosdep update && \
  sudo apt-get update && \
  rosdep install --from-paths ${ROS2_WS}/src --ignore-src --rosdistro foxy -y --skip-keys "console_bridge fastcdr fastrtps libopensplice67 libopensplice69 rti-connext-dds-5.3.1 urdfdom_headers"

USER root
ENV ROS2_WS /opt/ros2_ws/foxy

# More DDS implementations
# Not available in Ubuntu 20.04 yet
#RUN apt-get install -y libopensplice69

# build source
# test_rclcpp has compiler error. Temporary skipping
RUN cd ${ROS2_WS} && \
  colcon build \
    --cmake-args \
      -DSECURITY=ON --no-warn-unused-cli \
    --symlink-install \
    --packages-skip test_rclcpp

# argcomplete for ROS 2 command line tools autocomplete
RUN apt-get install -y python3-argcomplete

# Custom packages
RUN apt-get install -y \
    libsdl-image1.2-dev \
    libsdl-dev \
    libboost-dev \
    libyaml-cpp-dev

# Optional: PCL
#RUN apt-get update && apt-get install -y libpcl-dev libpcl-msgs-dev
# Optional: pybind
# Not in Ubuntu 20.04
#RUN apt-get update && apt-get install -y python-pybind11
RUN apt-get update && apt-get install -y python3-argcomplete

# setup bashrc
RUN cp /etc/skel/.bashrc ~/


#####
# Gazebo 11

# Clone all the gazebo models so that you don't download them every time
# docker is run
#RUN mkdir -p /home/$USERNAME/.gazebo && hg clone https://bitbucket.org/osrf/gazebo_models /home/$USERNAME/.gazebo/models

# Install Gazebo 11
# http://gazebosim.org/tutorials?tut=install_ubuntu&cat=install
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -

RUN apt-get update \
  && apt-get install -y libsdformat9* \
  && apt-get install -y libgazebo11*

# This makes container start up in user instead of root
# Commands below run as the developer user
USER $USERNAME

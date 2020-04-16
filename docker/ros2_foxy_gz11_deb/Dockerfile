# Gazebo 11 from Debian, built on top of ROS 2 Foxy from source
# Note that this Dockerfile does not contain X, so Gazebo GUI won't work. It can
# run headless. For Dockerfile with GUI, see ../ros2_foxy_gz11_deb_nvidia.

# 15 Apr 2020

# Image of ROS 2 Foxy from source on Ubuntu 20.04 with NVIDIA built from
# https://github.com/mabelzhang/ros-dev-scripts/blob/master/docker/ros2_latest_src/Dockerfile
FROM ros2_latest_src:latest

# Commands below run as root
USER root

# Install Gazebo 11
# http://gazebosim.org/tutorials?tut=install_ubuntu&cat=install
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -

RUN apt-get update \
  && apt-get install -y libsdformat9* \
  && apt-get install -y libgazebo11*

# This makes container start up in user instead of root
# Commands below run as the developer user
ENV USERNAME developer
USER $USERNAME

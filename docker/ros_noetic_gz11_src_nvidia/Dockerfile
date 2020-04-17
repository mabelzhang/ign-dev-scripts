# Install ROS 1 Noetic from source, with Gazebo 11 from Debian

# 14 Apr 2020

# Adapted from subt Gazebo 9 (from Debian) Dockerfile
#   https://bitbucket.org/osrf/subt/src/gazebo9/docker/subt/Dockerfile

# NVIDIA for Gazebo GUI
FROM nvidia_opengl_ubuntu20

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

# Set up sources.list and keys. This makes python3-catkin-pkg-modules visible
# to apt-get install, needed for rosdep install line below
# Lines from ROS 1 Debian install http://wiki.ros.org/melodic/Installation/Ubuntu
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654


# ROS 1 Noetic from source, adapted from Melodic instructions
# http://wiki.ros.org/melodic/Installation/Source
# Tested in ros-dev-scripts/docker/ros12_latest_src/Dockerfile
RUN apt-get update \
 && apt-get install -y \
        python3-rosdep \
        python3-rosinstall-generator \
        python3-wstool \
        python3-rosinstall \
        build-essential
#RUN apt-get install -y python-catkin-tools
RUN rosdep init


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

RUN sudo rosdep update


USER root

# Resolve dependencies and install ROS 1 Noetic from source
ENV ROS_WS /opt/ros_ws/noetic
RUN mkdir -p $ROS_WS/src
RUN cd $ROS_WS && \
  rosinstall_generator ros_comm --rosdistro noetic --deps --tar > noetic-ros-comm.rosinstall && \
  wstool init -j8 src noetic-ros-comm.rosinstall

# Dependency for rosdep install line below
# Already exists
#RUN apt-get update && apt-get install -y -o Dpkg::Options::="--force-overwrite" python3-catkin-pkg python3-rosdistro python3-rosdep-modules
# TODO: For some reason it can't find this. But if I go into Ubuntu 20.04 Docker container, I can locate it.
#RUN apt-get update && apt-get install -y python3-catkin-pkg-modules

RUN rosdep install --from-paths $ROS_WS/src --ignore-src --rosdistro noetic -y
# Download latest version of catkin_make_isolated with python3 in shebang. Else error when run it
RUN cd $ROS_WS/src/catkin/bin/ && \
  wget https://raw.githubusercontent.com/ros/catkin/noetic-devel/bin/catkin_make_isolated -O catkin_make_isolated
RUN cd $ROS_WS && \
  ${ROS_WS}/src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release


# Clone all the gazebo models so that you don't download them every time
# docker is run
RUN mkdir -p /home/$USERNAME/.gazebo && hg clone https://bitbucket.org/osrf/gazebo_models /home/$USERNAME/.gazebo/models

# Install Gazebo 11
# http://gazebosim.org/tutorials?tut=install_ubuntu&cat=install
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -

RUN apt-get update \
  && apt-get install -y libsdformat9* \
  && apt-get install -y libgazebo11*

USER $USERNAME

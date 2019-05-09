# Install subt and Ignition Gazebo from source

# Adapted from subt Gazebo 9 Dockerfile
#   https://bitbucket.org/osrf/subt/src/default/docker/subt/Dockerfile

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

RUN sudo /bin/sh -c 'echo "deb [trusted=yes] http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
 && sudo /bin/sh -c 'echo "deb [trusted=yes] http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' \
 && sudo /bin/sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-prerelease `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-prerelease.list' \
 && sudo /bin/sh -c 'wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -' \
 && sudo /bin/sh -c 'apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116' \
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
 && sudo rosdep init \
 && sudo apt-get clean

RUN rosdep update

# Clone all the gazebo models so that you don't download them every time
# docker is run
RUN mkdir -p /home/$USERNAME/.gazebo && hg clone https://bitbucket.org/osrf/gazebo_models /home/$USERNAME/.gazebo/models

RUN mkdir -p subt_ws/src \
 && cd subt_ws/src \
 && hg clone https://bitbucket.org/osrf/subt

WORKDIR /home/$USERNAME/subt_ws

# Download and install rotors package
RUN wget https://s3.amazonaws.com/osrf-distributions/subt_robot_examples/releases/subt_robot_examples_latest.tgz
RUN tar xvf subt_robot_examples_latest.tgz

# Build and install subt
RUN /bin/bash -c 'source /opt/ros/melodic/setup.bash && catkin_make install'

# Ignition prerequisites
RUN sudo apt-get -y install \
  curl \
  g++-8 \
  libgflags-dev \
  doxygen \
  ruby-ronn \
  libtinyxml2-dev \
  libtinyxml-dev \
  libeigen3-dev

# Install from binaries
# apt-get -y install libignition-cmake2-dev libignition-common3-dev libignition-math6-eigen3-dev libignition-plugin-dev libignition-physics-dev libignition-rendering-dev libignition-tools-dev libignition-transport6-dev libignition-gui-dev libignition-msgs3-dev libsdformat8-dev

# Clone Ignition Gazebo repos and install from source
RUN sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8 --slave /usr/bin/gcov gcov /usr/bin/gcov-8
RUN mkdir -p /home/$USERNAME/ign

RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/ignitionrobotics/ign-cmake -r ign-cmake2 \
  && cd /home/$USERNAME/ign/ign-cmake \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install

RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/ignitionrobotics/ign-math -r ign-math6 \
  && cd /home/$USERNAME/ign/ign-math \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install

RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/ignitionrobotics/ign-common -r ign-common3 \
  && cd /home/$USERNAME/ign/ign-common \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install

RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/ignitionrobotics/ign-tools -r default \
  && cd /home/$USERNAME/ign/ign-tools \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install

RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/ignitionrobotics/ign-msgs -r default \
  && cd /home/$USERNAME/ign/ign-msgs \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install

RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/ignitionrobotics/ign-transport -r default \
  && cd /home/$USERNAME/ign/ign-transport \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install

RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/osrf/sdformat -r sdf8 \
  && cd /home/$USERNAME/ign/sdformat \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install

RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/ignitionrobotics/ign-plugin -r ign-plugin1 \
  && cd /home/$USERNAME/ign/ign-plugin \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install

# ign-physics DART dependencies
# Compiling with DART will take a while
RUN sudo apt install -y \
    libdart6-dev \
    libdart6-collision-bullet-dev \
    libdart6-utils-dev \
    libdart6-utils-urdf-dev \
    libdart6-collision-ode-dev
RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/ignitionrobotics/ign-physics -r ign-physics1 \
  && cd /home/$USERNAME/ign/ign-physics \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install

RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/ignitionrobotics/ign-rendering -r default \
  && cd /home/$USERNAME/ign/ign-rendering \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install 

RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/ignitionrobotics/ign-sensors -r default \
  && cd /home/$USERNAME/ign/ign-sensors \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install

RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/ignitionrobotics/ign-fuel-tools -r ign-fuel-tools3 \
  && cd /home/$USERNAME/ign/ign-fuel-tools \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install

# ign-gui dependencies
RUN sudo apt install -y \
    qtbase5-dev \
    qtdeclarative5-dev \
    qtquickcontrols2-5-dev \
    qml-module-qtquick2 \
    qml-module-qtquick-controls \
    qml-module-qtquick-controls2 \
    qml-module-qtquick-dialogs \
    qml-module-qtquick-layouts \
    qml-module-qt-labs-folderlistmodel \
    qml-module-qt-labs-settings
RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/ignitionrobotics/ign-gui -r default \
  && cd /home/$USERNAME/ign/ign-gui \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install

RUN cd /home/$USERNAME/ign && hg clone https://bitbucket.org/ignitionrobotics/ign-gazebo -r default \
  && cd /home/$USERNAME/ign/ign-gazebo \
  && mkdir build && cd build && cmake .. && make -j16 && sudo make install

RUN /bin/bash -c 'echo ". /opt/ros/melodic/setup.bash" >> /home/$USERNAME/.bashrc' \
 && /bin/bash -c 'echo ". /usr/share/gazebo/setup.sh" >> /home/$USERNAME/.bashrc' \
 && /bin/bash -c 'echo ". $HOME/subt_ws/install/setup.sh" >> /home/$USERNAME/.bashrc'

# Customize your image here.
# E.g.:
# ENV PATH="/opt/sublime_text:$PATH"

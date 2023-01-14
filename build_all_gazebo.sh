#!/bin/bash

# Mabel Zhang
# 27 Apr 2020
#
# Clone repositories if do not exist locally.
# Update and rebuild Gazebo-classic and its Ignition dependencies
#
# Tested on Ubuntu 18.04 with Docker image ros_melodic_gz11_deps_only_nvidia.
#

THIS_DIR=`pwd`

# Modify distribution to the desired Gazebo Classic version
DISTRO=11
echo -e "$OKCYAN""Distribution: ""$DISTRO""$ENDC"

# Modify paths to where repos are locally
if [[ "$DISTRO" == 9 ]]; then
  ROOT=/home/developer/gazebo9_from_src
  CMAKE_INSTALL_PREFIX=$ROOT/install
  BUILD_TESTING=1
elif [[ "$DISTRO" == 11 ]]; then
  ROOT=/home/developer/gazebo11_from_src
  CMAKE_INSTALL_PREFIX=$ROOT/install
  # ign-math6 test/ FAKE_INSTALL is not building on Ubuntu 18.04
  BUILD_TESTING=0
fi

# Set whether to remove old build directory if found
REMOVE_BUILD_DIR=1


# If ROOT doesn't exist, create it.
if [[ ! -d "$ROOT" ]]; then
  mkdir -p $ROOT
fi

# Usage: $ echo -e "$MAGENTA"abc"$ENDC"abc""
OKCYAN="\e[96m"
BOLD="\e[m"
ENDC="\e[0m"

# Repos are in the order of dependency for compilation
if [[ "$DISTRO" == 9 ]]; then
  # Ref https://stackoverflow.com/questions/8880603/loop-through-an-array-of-strings-in-bash
  declare -a repos=(
    "ign-cmake"
    "ign-math"
    "ign-common"
    "sdformat"
    "ign-msgs"
    "ign-fuel-tools"
    "ign-transport"
    "gazebo"
  )
  # Versions from http://gazebosim.org/tutorials?tut=install_dependencies_from_source
  declare -a branches=(
    "ign-cmake0"
    "ign-math4"
    "ign-common1"
    "sdf6"
    "ign-msgs1"
    "ign-fuel-tools1"
    "ign-transport4"
    "gazebo9"
  )
elif [[ "$DISTRO" == 11 ]]; then
  # Ref https://stackoverflow.com/questions/8880603/loop-through-an-array-of-strings-in-bash
  declare -a repos=(
    "ign-cmake"
    "ign-math"
    "ign-common"
    "ign-tools"
    "sdformat"
    "ign-msgs"
    "ign-fuel-tools"
    "ign-transport"
    "gazebo"
  )
  # Versions from http://gazebosim.org/tutorials?tut=install_dependencies_from_source
  declare -a branches=(
    "ign-cmake2"
    "ign-math6"
    "ign-common3"
    "ign-tools1"
    "sdf9"
    "ign-msgs5"
    "ign-fuel-tools4"
    "ign-transport8"
    "gazebo11"
  )
fi

for i in "${!repos[@]}"
do
  repo="${repos[$i]}"
  branch="${branches[$i]}"

  echo -e "$OKCYAN""$repo""$ENDC"

  # If fresh checkout
  if [[ ! -d "$ROOT/$repo" ]]; then
    cd $ROOT
    if [[ "$repo" == sdformat ]]; then
      git clone https://github.com/osrf/sdformat
    elif [[ "$repo" == gazebo ]]; then
      git clone https://github.com/osrf/gazebo
    else
      git clone https://github.com/ignitionrobotics/$repo
    fi
    cd $ROOT/$repo
  # If repo already exist locally
  else
    cd $ROOT/$repo
    git pull
  fi

  git checkout $branch
  echo -e "$OKCYAN""branch: "`git symbolic-ref --short HEAD`"$ENDC"

  #read -p 'Verify branch above is correct (n to abort, anything else to continue): ' uinput
  #if [ "$uinput" == "n" ] || [ "$uinput" == "N" ]; then
  #  break
  #fi

  if [[ $REMOVE_BUILD_DIR == 1 ]]; then
    echo -e "$OKCYAN""Removing build directory""$ENDC"
    sudo rm -rf $ROOT/$repo/build
  fi

  if [[ ! -d "$ROOT/$repo/build" ]]; then
    mkdir $ROOT/$repo/build
  fi
  cd $ROOT/$repo/build

  # If no custom install path specified
  if [[ -z "$CMAKE_INSTALL_PREFIX" ]]; then
    cmake -DBUILD_TESTING="$BUILD_TESTING" ..
  else
    cmake -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" -DBUILD_TESTING="$BUILD_TESTING" ..
  fi

  make -j16
  sudo make install
done

cd $THIS_DIR

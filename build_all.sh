#!/bin/bash

# Mabel Zhang
# 24 Apr 2019
#
# Clone repositories if do not exist locally.
# Update and rebuild all Ignition repositories
#

THIS_DIR=`pwd`

DISTRO=blueprint

# Path on local machine where repos are located
if [[ "$DISTRO" == blueprint ]]; then
  ROOT=/data/ws/sim/ign
elif [[ "$DISTRO" == dome ]]; then
  ROOT=/data/ws/sim/ign_dome
fi

# If ROOT doesn't exist, create it.
if [[ ! -d "$ROOT" ]]; then
  mkdir -p $ROOT
fi

# Usage: $ echo -e "$MAGENTA"abc"$ENDC"abc""
OKCYAN="\e[96m"
BOLD="\e[m"
ENDC="\e[0m"

# Ref https://stackoverflow.com/questions/8880603/loop-through-an-array-of-strings-in-bash
declare -a repos=(
  "ign-cmake"
  "ign-math"
  "ign-common"
  "ign-tools"
  "ign-msgs"
  "ign-transport"
  "sdformat"
  "ign-plugin"
  "ign-physics"
  "ign-rendering"
  "ign-sensors"
  "ign-fuel-tools"
  "ign-gui"
  "ign-gazebo"
  "ign-launch")

# Repos are in the order of dependency for compilation
if [[ "$DISTRO" == blueprint ]]; then
  # Branches from https://bitbucket.org/osrf/gazebodistro/src/default/collection-blueprint.yaml
  declare -a branches=(
    "ign-cmake2"
    "ign-math6"
    "ign-common3"
    "ign-tools0"
    "ign-msgs4"
    "ign-transport7"
    "sdf8"
    "ign-plugin1"
    "ign-physics1"
    "ign-rendering2"
    "ign-sensors2"
    "ign-fuel-tools3"
    "ign-gui2"
    "ign-gazebo2"
    "ign-launch1"
  )
elif [[ "$DISTRO" == dome ]]; then
  # Branches from https://bitbucket.org/osrf/gazebodistro/src/default/collection-dome.yaml
  declare -a branches=(
    "ign-cmake2"
    "ign-math6"
    "ign-common3"
    "ign-tools1"
    "ign-msgs5"
    "ign-transport8"
    "sdf9"
    "ign-plugin1"
    "ign-physics2"
    "default"
    "default"
    "ign-fuel-tools4"
    "default"
    "default"
    "ign-launch1"
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
      hg clone https://bitbucket.org/osrf/sdformat
    else
      hg clone https://bitbucket.org/ignitionrobotics/$repo
    fi
    cd $ROOT/$repo
  # If repo already exist locally
  else
    cd $ROOT/$repo
    hg pull
  fi

  hg update $branch
  echo -e "$OKCYAN""branch: "`hg branch`"$ENDC"

  if [[ ! -d "$ROOT/$repo/build" ]]; then
    mkdir $ROOT/$repo/build
  fi
  cd $ROOT/$repo/build
  cmake ..
  make -j16
  sudo make install
done

cd $THIS_DIR

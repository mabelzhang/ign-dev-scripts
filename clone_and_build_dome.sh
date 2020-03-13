#!/bin/bash

# Mabel Zhang
# 12 Mar 2020
#
# Clone repositories if do not exist locally.
# Update and rebuild all Ignition repositories.
#

THIS_DIR=`pwd`

# Path on local machine where repos are located
ROOT=/data/ws/sim/ign_dome
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

  mkdir $ROOT/$repo/build
  cd $ROOT/$repo/build
  cmake ..
  make -j16
  sudo make install
done

cd $THIS_DIR

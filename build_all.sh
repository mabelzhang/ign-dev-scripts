#!/bin/bash

# Mabel Zhang
# 24 Apr 2019
#
# Update and rebuild all Ignition repositories
#

THIS_DIR=`pwd`

# Path on local machine where repos are located
ROOT=/data/ws/sim/ign

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

for i in "${!repos[@]}"
do
  repo="${repos[$i]}"
  branch="${branches[$i]}"

  echo -e "$OKCYAN""$repo""$ENDC"
  echo -e "$OKCYAN""branch: "`hg branch`"$ENDC"
  cd $ROOT/$repo/build
  hg pull
  hg update $branch
  make -j16
  sudo make install
done

cd $THIS_DIR

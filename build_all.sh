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
  "ign-gazebo")

for i in "${repos[@]}"
do
  echo -e "$OKCYAN""$i""$ENDC"
  cd $ROOT/$i/build
  echo -e "$OKCYAN""branch: "`hg branch`"$ENDC"
  hg pull
  hg update
  make -j16
  sudo make install
done

cd $THIS_DIR

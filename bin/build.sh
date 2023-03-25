#!/bin/bash

# --------------------------------------------
#            Build Configuration
EntryPoint="src/first.c"
OutputName="output"


# --------------------------------------------
#            Arguments
MODE=$1
PLATFORM=$2
ARCH=$3
PACKAGE=$4

if [ "${MODE}" == "" ] | [ "${PLATFORM}" == "" ]
then
  echo
  echo Build Command Syntax:
  echo "  $0 mode platform arch package(optional)"
  echo
  echo "Mode Options:"
  echo "  debug"
  echo "  release"
  echo
  echo "Platform Options:"
  echo "  win32"
  echo "  osx"
  echo
  echo "Arch Options: (architecture)"
  echo "  x64 (valid with Platform win32 and osx) (default)"
  echo "  arm64 (only valid for Platform osx)"
  echo 
  echo "Package:"
  echo "  enter the prefix of the package name. "
  echo "  the package will be named <prefix>_YYYY_MM_DD_<platform>"
  echo "  ie. 0b00001_2022_01_15"

  exit
fi

if [ "${ARCH}" == "" ]
then
  ARCH="x64"
fi

# --------------------------------------------
#            Utilities

pushdir () {
  command pushd "$@" > /dev/null
}

popdir () {
  command popd "$@" > /dev/null
}

# --------------------------------------------
#         Getting Project Path
#
# Project is stored in PROJECT_PATH

SCRIPT_REL_DIR=$(dirname "${BASH_SOURCE[0]}")
pushdir "${SCRIPT_REL_DIR}/.."
PROJECT_PATH=$(pwd)
popdir

# --------------------------------------------
#         Resource Collection

SHADER_COMPILER_WIN="C:\drive\apps\sokol-shdc\sokol-shdc.exe"
SHADER_COMPILER_OSX="/Users/ps/apps/sokol-shdc/sokol-shdc"

# --------------------------------------------
#         Outputs By Platform

if [ "${PLATFORM}" == "win32" ]
then
  CompilerOutputExt=".o"
  LinkerOutputExe=".exe"

  PlatformSuffix="win"
  ArchSuffix="x86_64"

elif [ "${PLATFORM}" == "osx" ]
then
  CompilerOutputExt=""
  LinkerOutputExt=""

  PlatformSuffix="osx"
  if [ "${ARCH}" == "arm64" ]
  then
    ArchSuffix="arm64"
  elif [ "${ARCH}" == "x64" ]
  then
    ArchSuffix="x86_64"
  else
    echo "ERROR: Unrecognized Arch: ${ARCH}"
    exit 0
  fi

else
  echo "Unknown Platform: ${PLATFORM}"
  exit 0

fi

BuildPath="${PROJECT_PATH}/run_tree/${PLATFORM}/${ARCH}/${MODE}"
if [ ! -d "$BuildPath" ]; then
  mkdir -p $BuildPath
fi

CompilerOutput="$BuildPath/$OutputName$CompilerOutputExt"
FinalOutput="$BuildPath/$OutputName$LinkerOutputExe"

echo "Final Output: $FinalOutput"

# --------------------------------------------
#         Compiler Flags

CompilerFlags=""

# Release Mode Flags
if [ "${MODE}" == "debug" ]; then
  CompilerFlags+=" -O0 -g -DDEBUG=1 -fsanitize=address"
elif [ "${MODE}" == "release" ]; then
  CompilerFlags+=" -O3"
fi

# Platform Flags
if [ "${PLATFORM}" == "win32" ]; then
  CompilerFlags+=" -c"
elif [ "${PLATFORM}" == "osx" ]; then
  CompilerFlags+=" -ObjC"
fi

# Arch Flags
if [ "${ARCH}" == "x64" ]; then
  CompilerFlags+=" -arch x86_64"
elif [ "${ARCH}" == "arm64" ]; then
  CompilerFlags+=" -arch arm64"
fi

# --------------------------------------------
#         Linker Flags

LinkerFlags=""

# Release Mode Flags
if [ "${MODE}" == "debug" ]; then
  LinkerFlags+=""
elif [ "${MODE}" == "release" ]; then
  LinkerFlags+=""
fi

# Platform Flags
if [ "${PLATFORM}" == "win32" ]; then
  LinkerFlags+=" -NOLOGO -debug -incremental:no"
elif [ "${PLATFORM}" == "osx" ]; then
  LinkerFlags+=""
fi

# --------------------------------------------
#         Linker Libraries

LinkerLibs=""

if [ "${PLATFORM}" == "win32" ]; then
  LinkerLibs+="Ws2_32.lib opengl32.lib user32.lib gdi32.lib msvcrt.lib msvcprt.lib"
elif [ "${PLATFORM}" == "osx" ]; then
  LinkerLibs+="-framework OpenGL -framework Cocoa -framework AudioToolbox"
fi

# --------------------------------------------
#         Compile and Link

echo "COMPILING..."
if [ $PLATFORM == "win32" ]
then
  clang "${PROJECT_PATH}/${EntryPoint}" $CompilerFlags -o "$BuildPath/$CompilerOutput"
  echo "LINKING..."
  link $LinkerFlags $CompilerOutput $LinkerLibs

elif [ $PLATFORM == "osx" ]
then
  clang -o $FinalOutput $CompilerFlags "${PROJECT_PATH}/${EntryPoint}" $LinkerLibs
fi
echo "COMPLETE..."
echo
#!/bin/bash

# Run this with MSYS2 MINGW64 (https://www.msys2.org/)

# Ensure the system is up to date
pacman -Syu --noconfirm

# Install necessary development tools
pacman -S --noconfirm base-devel git pkg-config mingw-w64-x86_64-cmake mingw-w64-x86_64-lua mingw-w64-x86_64-toolchain mingw-w64-x86_64-opencv

# Create list of installed packages for debugging
pacman -Q > docker/installed_packages.txt

# Clean any previous build files if they exist
rm -rf build

cmake -B build -S . -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)

cd build && ../scripts/copy_dlls.sh

FROM ubuntu:22.04

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    liblua5.4-dev \
    pkg-config

# Copy local files into the container
COPY ./ /inkpath

# Switch to local files directory
WORKDIR /inkpath
# Clean build files if copied
RUN rm -rf build

# Create list of installed packages for debugging
RUN dpkg-query -W -f='${Package},${Version}\n' > installed_packages.txt

# Build inkpath
RUN cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DUSE_EXTERNAL_OPENCV_STATIC=ON && \
    cmake --build build -j$(nproc)

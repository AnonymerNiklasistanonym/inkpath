# Docker

Build `inkpath` using `docker`.

## Linux (Ubuntu)

This docker image builds `inkpath` for Linux.
It is based on the same Ubuntu version as the GitHub Actions runner `ubuntu-latest`.

```sh
# Change docker build context to the root of the repository
cd ..
# Build docker image
docker build -f ./docker/Dockerfile -t my_docker_image .
# Create temporary container and copy files to local machine
docker create --name temp_container my_docker_image
docker cp temp_container:/inkpath/build/ImageTranscription ./docker/
docker cp temp_container:/inkpath/installed_packages.txt ./docker/installed_packages.txt
docker rm temp_container
# Remove docker image
docker rmi my_docker_image
```

## MSYS2 (Windows)

To build the project you can also install [MSYS2](https://www.msys2.org/).
MSYS2 is available on the GitHub Actions runner `windows-latest` using [`msys2/setup-msys2`](https://github.com/msys2/setup-msys2).

```sh
# 1. Start the MSYS2 MINGW64 Terminal
# 2. Navigate to this repository
cd /c/Users/..../inkpath
# 3. Run the existing script
./docker/msys2.sh
```

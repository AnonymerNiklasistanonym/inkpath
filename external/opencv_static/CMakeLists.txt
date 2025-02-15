cmake_minimum_required(VERSION 3.16)
project(ExternalOpenCVStatic)

include(ExternalProject)

option(DISABLE_WEBP_EXTERNAL_OPENCV "Disable OpenCV library 3rd party dependency for WEBP (from subdirectory)" OFF)
if(DISABLE_WEBP_EXTERNAL_OPENCV)
    # Crashes on some CPUs because of SSE3 problems
    list(APPEND CUSTOM_CMAKE_OPENCV_ARGS -DWITH_WEBP=OFF)
endif()

# Set where to download and build OpenCV
set(OPENCV_INSTALL_DIR "${CMAKE_BINARY_DIR}/opencv_static_install")
# Set the URL to clone OpenCV from GitHub
set(OPENCV_TAG "4.11.0")
set(OPENCV_URL "https://github.com/opencv/opencv.git")

# Expose OpenCV_DIR so the main project can determine if it was already built (and thus if FindPackage can be used)
set(OpenCV_DIR "${OPENCV_INSTALL_DIR}/lib/cmake/opencv4" PARENT_SCOPE)

# Clone and build OpenCV
ExternalProject_Add(
    ${PROJECT_NAME}
    PREFIX ${CMAKE_BINARY_DIR}/opencv_static
    GIT_REPOSITORY ${OPENCV_URL}
    GIT_TAG ${OPENCV_TAG}
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${OPENCV_INSTALL_DIR}
        -DBUILD_SHARED_LIBS=OFF
        -DCMAKE_BUILD_TYPE=Release
        -DOPENCV_GENERATE_PKGCONFIG=ON
        # Disable tests, docs, ...
        -DBUILD_TESTS=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_PERF_TESTS=OFF
        # Disable unnecessary functionality
        -DWITH_FFMPEG=OFF
        -DWITH_GSTREAMER=OFF
        -DWITH_GTK=OFF
        -DWITH_OPENEXR=OFF
        -DWITH_QT=OFF
        -DBUILD_opencv_java=OFF
        -DBUILD_opencv_python3=OFF
        # Disable apparently unnecessary modules for faster build times
        # (Comment the following part if this results in errors around missing files/libraries)
        -DBUILD_opencv_highgui=OFF
        -DBUILD_opencv_ml=OFF
        -DBUILD_opencv_objdetect=OFF
        -DBUILD_opencv_stitching=OFF
        -DBUILD_opencv_video=OFF
        -DBUILD_opencv_videoio=OFF
        # Custom arguments
        ${CUSTOM_CMAKE_OPENCV_ARGS}
    # Declare expected output files that will be generated after the external project is built
    BUILD_BYPRODUCTS "${OpenCV_DIR}/OpenCVConfig.cmake"
)

add_custom_command(
    TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -S ${CMAKE_SOURCE_DIR} -B ${CMAKE_BINARY_DIR}
    COMMENT "Re-running CMake to configure OpenCV"
)

# CMake minimum version
cmake_minimum_required(VERSION 3.0)
set(CMAKE_MACOSX_RPATH 1)
# project info
project(store
  VERSION 0.0.1
  LANGUAGES CXX C ASM)

# include header
include_directories(${CMAKE_CURRENT_LIST_DIR}/include)
include_directories(${CMAKE_CURRENT_LIST_DIR}/src)
# generate target
add_subdirectory(src)

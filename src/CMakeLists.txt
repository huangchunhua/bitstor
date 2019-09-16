cmake_minimum_required (VERSION 3.0)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fPIC")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -fPIC")
# add_definitions("-Wall -g -Werror")

add_subdirectory(glog)
add_subdirectory(rocksdb)
#add_subdirectory(grpc)
LINK_DIRECTORIES(rocksdb)
# Include generated *.pb.h files
set(ROCKSDB_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/rocksdb/include)
include_directories("${ROCKSDB_INCLUDE_DIR}"
"${CMAKE_CURRENT_BINARY_DIR}")

# Building server
add_executable(store
        bitstor.cc
)

# Link lib
target_link_libraries(store 
        glog
        rocksdb
)
        
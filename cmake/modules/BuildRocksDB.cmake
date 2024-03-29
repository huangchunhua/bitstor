function(build_rocksdb)
  set(rocksdb_CMAKE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE=ON)
  list(APPEND rocksdb_CMAKE_ARGS -DWITH_GFLAGS=OFF)

  if(ALLOCATOR STREQUAL "jemalloc")
    list(APPEND rocksdb_CMAKE_ARGS -DWITH_JEMALLOC=ON)
    list(APPEND rocksdb_INTERFACE_LINK_LIBRARIES JeMalloc::JeMalloc)
  endif()

  if (WITH_CCACHE AND CCACHE_FOUND)
    list(APPEND rocksdb_CMAKE_ARGS -DCMAKE_CXX_COMPILER_LAUNCHER=ccache)
  endif()
  list(APPEND rocksdb_CMAKE_ARGS -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER})

  list(APPEND rocksdb_CMAKE_ARGS -DWITH_SNAPPY=${SNAPPY_FOUND})
  if(SNAPPY_FOUND)
    list(APPEND rocksdb_INTERFACE_LINK_LIBRARIES snappy::snappy)
  endif()
  # libsnappy is a C++ library, we need to force rocksdb to link against
  # libsnappy statically.
  if(SNAPPY_FOUND AND WITH_STATIC_LIBSTDCXX)
    list(APPEND rocksdb_CMAKE_ARGS -DWITH_SNAPPY_STATIC_LIB=ON)
  endif()

  list(APPEND rocksdb_CMAKE_ARGS -DWITH_LZ4=${LZ4_FOUND})
  if(LZ4_FOUND)
    list(APPEND rocksdb_INTERFACE_LINK_LIBRARIES LZ4::LZ4)
  endif()

  list(APPEND rocksdb_CMAKE_ARGS -DWITH_ZLIB=${ZLIB_FOUND})
  if(ZLIB_FOUND)
    list(APPEND rocksdb_INTERFACE_LINK_LIBRARIES ZLIB::ZLIB)
  endif()

  list(APPEND rocksdb_CMAKE_ARGS -DPORTABLE=ON)
  list(APPEND rocksdb_CMAKE_ARGS -DCMAKE_AR=${CMAKE_AR})
  list(APPEND rocksdb_CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})
  list(APPEND rocksdb_CMAKE_ARGS -DFAIL_ON_WARNINGS=OFF)
  list(APPEND rocksdb_CMAKE_ARGS -DUSE_RTTI=1)
  list(APPEND rocksdb_CMAKE_ARGS -G${CMAKE_GENERATOR})

  include(CheckCXXCompilerFlag)
  check_cxx_compiler_flag("-Wno-deprecated-copy" HAS_WARNING_DEPRECATED_COPY)
  if(HAS_WARNING_DEPRECATED_COPY)
    set(rocksdb_CXX_FLAGS -Wno-deprecated-copy)
  endif()
  check_cxx_compiler_flag("-Wno-pessimizing-move" HAS_WARNING_PESSIMIZING_MOVE)
  if(HAS_WARNING_PESSIMIZING_MOVE)
    set(rocksdb_CXX_FLAGS "${rocksdb_CXX_FLAGS} -Wno-pessimizing-move")
  endif()
  if(rocksdb_CXX_FLAGS)
    list(APPEND rocksdb_CMAKE_ARGS -DCMAKE_CXX_FLAGS='${rocksdb_CXX_FLAGS}')
  endif()
  # we use an external project and copy the sources to bin directory to ensure
  # that object files are built outside of the source tree.
  include(ExternalProject)
  set(rocksdb_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/rocksdb")
  set(rocksdb_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/rocksdb")
  set(rocksdb_LIBRARY "${rocksdb_BINARY_DIR}/librocksdb.a")
  ExternalProject_Add(rocksdb_ext
    SOURCE_DIR "${rocksdb_SOURCE_DIR}"
    CMAKE_ARGS ${rocksdb_CMAKE_ARGS}
    BINARY_DIR "${rocksdb_BINARY_DIR}"
    BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --target rocksdb
    BUILD_ALWAYS TRUE
    BUILD_BYPRODUCTS "${rocksdb_LIBRARY}"
    INSTALL_COMMAND "true")

  add_library(RocksDB::RocksDB STATIC IMPORTED)
  add_dependencies(RocksDB::RocksDB rocksdb_ext)
  set(rocksdb_INCLUDE_DIR "${rocksdb_SOURCE_DIR}/include")
  foreach(ver "MAJOR" "MINOR" "PATCH")
    file(STRINGS "${rocksdb_INCLUDE_DIR}/rocksdb/version.h" ROCKSDB_VER_${ver}_LINE
      REGEX "^#define[ \t]+ROCKSDB_${ver}[ \t]+[0-9]+$")
    string(REGEX REPLACE "^#define[ \t]+ROCKSDB_${ver}[ \t]+([0-9]+)$"
      "\\1" ROCKSDB_VERSION_${ver} "${ROCKSDB_VER_${ver}_LINE}")
    unset(ROCKDB_VER_${ver}_LINE)
  endforeach()
  set(rocksdb_VERSION_STRING
    "${ROCKSDB_VERSION_MAJOR}.${ROCKSDB_VERSION_MINOR}.${ROCKSDB_VERSION_PATCH}")
  set_target_properties(RocksDB::RocksDB PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${rocksdb_INCLUDE_DIR}"
    INTERFACE_LINK_LIBRARIES "${rocksdb_INTERFACE_LINK_LIBRARIES}"
    IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
    IMPORTED_LOCATION "${rocksdb_LIBRARY}"
    VERSION "${rocksdb_VERSION_STRING}")
endfunction()

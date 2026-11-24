# Lift the llguidance artifacts cargo produced to the root of the profile directory.
# ref: https://github.com/rust-lang/cargo/pull/17354

cmake_minimum_required(VERSION 3.14)

set(LLGUIDANCE_TARGET_DIR  "" CACHE STRING "cargo target directory to search")
set(LLGUIDANCE_PROFILE_DIR "" CACHE STRING "directory the artifacts are lifted to")
set(LLGUIDANCE_LIB_NAME    "" CACHE STRING "static library file name cargo produces")

if(NOT IS_DIRECTORY "${LLGUIDANCE_TARGET_DIR}")
    message(FATAL_ERROR "llguidance: no cargo output in ${LLGUIDANCE_TARGET_DIR}")
endif()

foreach(artifact "llguidance.h" "${LLGUIDANCE_LIB_NAME}")
    set(destination "${LLGUIDANCE_PROFILE_DIR}/${artifact}")

    if(EXISTS "${destination}")
        continue()
    endif()

    file(GLOB_RECURSE produced LIST_DIRECTORIES FALSE "${LLGUIDANCE_PROFILE_DIR}/${artifact}")
    list(LENGTH produced count)

    if(count EQUAL 0)
        file(GLOB_RECURSE produced LIST_DIRECTORIES FALSE "${LLGUIDANCE_TARGET_DIR}/${artifact}")
        list(LENGTH produced count)
    endif()

    if(count EQUAL 0)
        message(FATAL_ERROR "llguidance: cargo produced no ${artifact} under ${LLGUIDANCE_TARGET_DIR}")
    endif()

    list(SORT produced)

    list(GET produced 0 source)
    message(STATUS "llguidance: cargo placed ${artifact} in ${source}, lifting it")

    file(COPY "${source}" DESTINATION "${LLGUIDANCE_PROFILE_DIR}")
endforeach()

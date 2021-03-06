cmake_minimum_required(VERSION 2.8)

project( firesight )

SET(PROJECT_VERSION_MAJOR 0)
SET(PROJECT_VERSION_MINOR 14)
set(PROJECT_VERSION_PATCH 6)
set(PROJECT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH})

OPTION(BUILD_LGPL2_1 "Build modules with LGPL2.1 license" ON)

IF(WIN32)
  MESSAGE(STATUS "Detecting WINDOWS build")
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}")
  # By default, do not warn when built on machines using only VS Express:
  IF(NOT DEFINED CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS)
    SET(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS ON)
  ENDIF()
  SET(JANSSON_DIR "${CMAKE_SOURCE_DIR}/jansson/mingw" CACHE STRING "Jansson directory") 
  SET(JANSSON_INCLUDE_DIRS "${JANSSON_DIR}/include")
  SET(JANSSON_LIB "${JANSSON_DIR}/lib/libjansson.dll.a")
  SET(JANSSON_DLL "${JANSSON_DIR}/bin/libjansson.dll")
  MESSAGE(STATUS "JANSSON_DLL:${JANSSON_DLL}")
  MESSAGE(STATUS "JANSSON_LIB:${JANSSON_LIB}")
  SET(FIRESIGHT_LIB "_firesight.lib")
  SET(FIRESIGHT_DLL "_firesight.dll")
  SET(ZBAR_DIR "C:/ZBar/" CACHE STRING "ZBAR_DIRECTORY")
  SET(ZBAR_DLL "${ZBAR_DIR}/BIN/libzbar-0.dll" CACHE STRING "ZBAR_DLL")
  SET(ZBAR_LIB "${ZBAR_DIR}/lib/libzbar.dll.a" CACHE STRING "ZBAR_LIB")
  SET(ZBAR_LIBRARIES "${ZBAR_LIB}")
  SET(ZBAR_INCLUDE_DIR "${ZBAR_DIR}/include" CACHE STRING "ZBAR_INCLUDE_DIR")
ELSE(WIN32)
  MESSAGE(STATUS "Detecting LINUX build")
  SET(JANSSON_INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/jannson/src")
  SET(JANSSON_LIB "libjansson.so")
  SET(FIRESIGHT_LIB "lib_firesight.so")
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -g -Wno-format-extra-args")
  SET(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG} -g")
ENDIF(WIN32)

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
    "${CMAKE_SOURCE_DIR}/cmake/Modules/")

SET(COMPILE_DEFINITIONS -Werror)
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_FILE_OFFSET_BITS=64")

get_property(dirs DIRECTORY . PROPERTY INCLUDE_DIRECTORIES)
message("INCLUDE_DIRECTORIES:${dirs}")

SET(BUILD_TARGET_DIR "${CMAKE_CURRENT_SOURCE_DIR}/target" CACHE STRING "Put all binary output in target")
SET(LIBRARY_OUTPUT_PATH "${BUILD_TARGET_DIR}")
SET(EXECUTABLE_OUTPUT_PATH "${BUILD_TARGET_DIR}")
SET(RUNTIME_OUTPUT_NAME firesight)
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

include_directories( ${PROJECT_SOURCE_DIR} ${BUILD_TARGET_DIR} ${JANSSON_INCLUDE_DIRS} )
IF(WIN32)
	include_directories( ${ZBAR_INCLUDE_DIR} )
ELSE(WIN32)
	include_directories( /usr/local/include )
	include_directories( /usr/include )
ENDIF(WIN32)

include (InstallRequiredSystemLibraries)
SET(CPACK_RESOURCE_FILE_LICENSE  
     "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
SET(CPACK_PACKAGE_GENERATED_WARNING "GENERATED FILE!!! DO NOT CHANGE!!!")
SET(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
SET(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
include (CPack)

get_property(dirs DIRECTORY . PROPERTY INCLUDE_DIRECTORIES)
message("INCLUDE_DIRECTORIES:")
foreach(dir ${dirs})
  message(STATUS "  dir='${dir}'")
endforeach()

configure_file (
  "${PROJECT_SOURCE_DIR}/version.h.in"
  "${BUILD_TARGET_DIR}/version.h"
  )

find_package( OpenCV REQUIRED )
if (OpenCV_LIBS) 
  MESSAGE(STATUS "OpenCV_LIBS:${OpenCV_LIBS}")
else(OpenCV_LIBS)
  MESSAGE(STATUS "OpenCV_LIBS:${OpenCV_LIBS}")
  MESSAGE("find_package(OpenCV) failed => OpenCV_LIBS is not defined")
endif(OpenCV_LIBS)

message("CMAKE_PREFIX_PATH:${CMAKE_PREFIX_PATH}")

IF(WIN32)
	link_directories( ${BUILD_TARGET_DIR} )
ELSE(WIN32)
	link_directories( ${BUILD_TARGET_DIR} /usr/lib /usr/local/lib )
ENDIF(WIN32)

set(FIRESIGHT_LIB_FILES
  bgSub.cpp
  calcOffset.cpp
  calcHist.cpp
  calibrate.cpp
  dft.cpp 
  FireLog.cpp 
  generated_code.cpp
  HoleRecognizer.cpp 
  HoughCircle.cpp
  jo_util.cpp 
  MatchedRegion.cpp 
  MatUtil.cpp
  Model.cpp 
  morph.cpp
  MSER.cpp 
  normalize.cpp
  Pipeline.cpp 
  Pt2Res_RANSAC.cpp
  proto.cpp 
  warpRing.cpp
  )

# conditinally included sources with LGPL 2.1 license
if(BUILD_LGPL2_1)
    find_package( ZBar0 REQUIRED )

    set(FIRESIGHT_LIB_FILES ${FIRESIGHT_LIB_FILES}
      ZbarQrDecode.cpp
    )
endif(BUILD_LGPL2_1)

MESSAGE(STATUS "FireSight Lib Files:${FIRESIGHT_LIB_FILES}")


###############################################################################
# lib_firesight Library
###############################################################################
add_library(_firesight SHARED ${FIRESIGHT_LIB_FILES})
target_link_libraries(_firesight ${JANSSON_LIB} ${OpenCV_LIBS} )
set_target_properties(_firesight PROPERTIES 
    VERSION ${PROJECT_VERSION_STRING} 
    SOVERSION ${PROJECT_VERSION_MAJOR}
    )
if(BUILD_LGPL2_1)
    target_link_libraries(_firesight ${ZBAR_LIBRARIES})
    set_target_properties(_firesight PROPERTIES COMPILE_FLAGS -DLGPL2_1)
endif(BUILD_LGPL2_1)
if(WIN32)
  add_custom_command(TARGET _firesight PRE_LINK
    COMMAND ${CMAKE_COMMAND} -E copy_if_different  
        "${JANSSON_LIB}"      
        "${BUILD_TARGET_DIR}" 
    COMMAND ${CMAKE_COMMAND} -E copy_if_different  
        "${JANSSON_DLL}"      
        "${BUILD_TARGET_DIR}" 
    )
endif(WIN32)
  
###############################################################################
# GenCode Executable (code generator for ring mat)
###############################################################################
add_executable(gencode gencode.cpp)

###############################################################################
# FireSight Executable
###############################################################################

add_executable(firesight FireSight.cpp)
add_dependencies(firesight _firesight)
target_link_libraries(firesight ${JANSSON_LIB} ${FIRESIGHT_LIB} ${OpenCV_LIBS})
if(BUILD_LGPL2_1)
    target_link_libraries(firesight ${ZBAR_LIB})
    set_target_properties(firesight PROPERTIES COMPILE_FLAGS -DLGPL2_1)
endif(BUILD_LGPL2_1)
#if(WIN32)
#  add_custom_command(TARGET firesight POST_BUILD    
#    COMMAND ${CMAKE_COMMAND} -E copy_if_different  
#        "${PROJECT_SOURCE_DIR}/target/Debug/firesight.exe"      
#        "${PROJECT_SOURCE_DIR}/target/firesight.exe" 
#        )
#endif(WIN32)

###############################################################################
# FireSight Tests
###############################################################################
add_executable(testAll 
  test/test_calibrate.cpp
  test/test_warpAffine.cpp 
  test/test_warpRing.cpp 
  test/test_regionKeypoint.cpp 
  test/test_matMaxima.cpp 
  test/test_jo_util.cpp
  test/test.cpp)

add_dependencies(testAll _firesight)
target_link_libraries(testAll ${JANSSON_LIB} ${FIRESIGHT_LIB} ${OpenCV_LIBS})
if(BUILD_LGPL2_1)
    target_link_libraries(testAll ${ZBAR_LIB})
    set_target_properties(testAll PROPERTIES COMPILE_FLAGS -DLGPL2_1)
endif(BUILD_LGPL2_1)
#if(WIN32)
#  add_custom_command(TARGET testAll POST_BUILD    
#    COMMAND ${CMAKE_COMMAND} -E copy_if_different  
#        "${PROJECT_SOURCE_DIR}/target/Debug/testAll.exe"      
#        "${PROJECT_SOURCE_DIR}/target/testAll.exe" 
#        )
#endif(WIN32)
#
# Installation preparation.
#

#Copy ZBar Windows DLL over to target dir
if(BUILD_LGPL2_1)
if(WIN32)
  add_custom_command(TARGET firesight POST_BUILD    
    COMMAND ${CMAKE_COMMAND} -E copy_if_different  
        "${ZBAR_DLL}"      
        "${BUILD_TARGET_DIR}" 
    COMMAND ${CMAKE_COMMAND} -E copy_if_different  
        "${ZBAR_LIB}"      
        "${BUILD_TARGET_DIR}" 
        )

endif(WIN32)
endif(BUILD_LGPL2_1)


# Allow the user to override installation directories.
set(FIRESIGHT_INSTALL_LIB_DIR       lib CACHE PATH "Installation directory for libraries")
set(FIRESIGHT_INSTALL_BIN_DIR       bin CACHE PATH "Installation directory for executables")
set(FIRESIGHT_INSTALL_INCLUDE_DIR   include CACHE PATH "Installation directory for header files")


INSTALL(TARGETS _firesight DESTINATION ${FIRESIGHT_INSTALL_LIB_DIR})
INSTALL(TARGETS firesight DESTINATION ${FIRESIGHT_INSTALL_BIN_DIR})
INSTALL(FILES FireLog.h FireSight.hpp DESTINATION ${FIRESIGHT_INSTALL_INCLUDE_DIR})


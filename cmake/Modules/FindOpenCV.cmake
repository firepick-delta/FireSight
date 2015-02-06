# Written by Armin van der Togt
#  OpenCV_FOUND - System has OpenCV
#  OpenCV_INCLUDE_DIRS - The OpenCV include directories
#  OpenCV_LIBRARIES - The libraries needed to use OpenCV
#  OpenCV_VERSION - The version of the OpenCV library

FIND_PATH(OpenCV_INCLUDE_DIRS "opencv2/opencv.hpp" PATHS "${OpenCV_DIR}" PATH_SUFFIXES "install/include" DOC "")

#Find OpenCV version by looking at core/version.hpp
find_path(VERSION_FILE_DIR "version.hpp" PATHS "${OpenCV_INCLUDE_DIRS}" PATH_SUFFIXES "opencv" "opencv2" "opencv2/core/" DOC "")
if(NOT EXISTS ${VERSION_FILE_DIR})
	find_path(VERSION_FILE_DIR "cvver.h" PATHS "${OpenCV_DIR}" PATH_SUFFIXES "opencv" DOC "")
	if(NOT EXISTS ${VERSION_FILE_DIR})
		message(FATAL_ERROR "OpenCV version file not found")
	else(NOT EXISTS ${VERSION_FILE_DIR})
		set(VERSION_FILE ${VERSION_FILE_DIR}/cvver.h)  
	endif(NOT EXISTS ${VERSION_FILE_DIR})
	else(NOT EXISTS ${VERSION_FILE_DIR})
	set(VERSION_FILE ${VERSION_FILE_DIR}/version.hpp)
endif(NOT EXISTS ${VERSION_FILE_DIR})

file(STRINGS ${VERSION_FILE} OpenCV_VERSIONS_TMP REGEX "^#define CV_VERSION_[A-Z]+[ \t]+[0-9]+$")
string(REGEX REPLACE ".*define CV_VERSION_EPOCH[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_EPOCH ${OpenCV_VERSIONS_TMP})
string(REGEX REPLACE ".*define CV_VERSION_MAJOR[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_MAJOR ${OpenCV_VERSIONS_TMP})
string(REGEX REPLACE ".*define CV_VERSION_MINOR[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_MINOR ${OpenCV_VERSIONS_TMP})
string(REGEX REPLACE ".*define CV_VERSION_REVISION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_REVISION ${OpenCV_VERSIONS_TMP})
set(OpenCV_VERSION ${OpenCV_VERSION_EPOCH}.${OpenCV_VERSION_MAJOR}.${OpenCV_VERSION_MINOR} CACHE STRING "" FORCE)

if(WIN32)
	set(CVLIB_SUFFIX "${OpenCV_VERSION_EPOCH}${OpenCV_VERSION_MAJOR}${OpenCV_VERSION_MINOR}")
endif(WIN32)

FIND_LIBRARY (OPENCV_CORE_LIB opencv_core${CVLIB_SUFFIX} PATH_SUFFIXES "bin")
MESSAGE(STATUS "Found OpenCV version: ${OpenCV_VERSION}" )

get_filename_component(OPENCV_DIRPATH ${OPENCV_CORE_LIB} DIRECTORY)

IF (CMAKE_SHARED_LIBRARY_PREFIX)
	file(GLOB OpenCV_LIBS "${OPENCV_DIRPATH}/${CMAKE_SHARED_LIBRARY_PREFIX}opencv*${CMAKE_SHARED_LIBRARY_SUFFIX}")
ELSE (CMAKE_SHARED_LIBRARY_PREFIX)
	file(GLOB OpenCV_LIBS "${OPENCV_DIRPATH}/${CMAKE_STATIC_LIBRARY_PREFIX}opencv*${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF (CMAKE_SHARED_LIBRARY_PREFIX)

SET(OpenCV_LIBRARIES ${OpenCV_LIBS})

if (OpenCV_LIBS AND OpenCV_INCLUDE_DIRS)
	SET(OpenCV_FOUND 1)
else  (OpenCV_LIBS AND OpenCV_INCLUDE_DIRS)
	SET(OpenCV_FOUND 0)
endif  (OpenCV_LIBS AND OpenCV_INCLUDE_DIRS)


#Here comes original FindOpenCV code. Should not be needed anymore
#if (NOT OpenCV_FOUND)
#IF(WIN32)
#	FIND_PATH( OPENCV2_PATH build/include/opencv2/opencv.hpp
#		${OPENCV_HOME}
#		$ENV{OPENCV_HOME}
#		C:/OpenCV2.4/
#		D:/OpenCV2.4/
#		C:/OpenCV/
#		D:/OpenCV/
#	)
#	
#	if( OPENCV2_PATH )
#		MESSAGE( STATUS "Looking for OpenCV2.4 or greater - found")
#		MESSAGE( STATUS "OpenCVV2_PATH:${OPENCV2_PATH}" )
#		SET ( OPENCV2_FOUND 1 )
#		
#		# test for 64 or 32 bit
#		UNSET(BUILD_DIR CACHE)
#		if( CMAKE_SIZEOF_VOID_P EQUAL 8)
#			SET( BUILD_DIR ${OPENCV2_PATH}/install/x64 CACHE STRING "OpenCV library ")
#			MESSAGE("Using OpenCV 64-bit libraries")
#		else( CMAKE_SIZEOF_VOID_P EQUAL 8)
#			SET( BUILD_DIR ${OPENCV2_PATH}/install/x86 CACHE STRING "OpenCV library")
#			MESSAGE(STATUS "Using OpenCV 32-bit libraries")
#		endif( CMAKE_SIZEOF_VOID_P EQUAL 8)
#		
#		# MINGW 
#		# NOTE: OpenCV does not offer pre-compiled binaries for MinGW any more, but it can be built using CMAKE and MinGW.
#		# This assumes OpenCV was built to ${OPENCV2_PATH} which should be specified when running 'CMAKE' / 'make' / 'make install'.
#		if(MINGW)
#			UNSET(OPENCV2_LIB_PATH CACHE)
#			SET(OPENCV2_LIB_PATH ${BUILD_DIR}/mingw/staticlib/ CACHE PATH "OpenCV library path")
#			file(GLOB OPENCV2_LIBS "${OPENCV2_LIB_PATH}/lib*.a")
#			#SET(OPENCV2_LIB_PATH ${BUILD_DIR}/mingw/lib/ CACHE PATH "OpenCV library path")
#			#file(GLOB OPENCV2_LIBS "${OPENCV2_LIB_PATH}/*[0-9][0-9][0-9].dll.a")
#			UNSET(OpenCV_LIBS CACHE)
#			MESSAGE(STATUS "MinGW libraries OPENCV2_LIB_PATH:${OPENCV2_LIB_PATH}")
#			SET(OpenCV_LIBS "${OPENCV2_LIBS}" CACHE STRING "OpenCV library files")
#			# Set the includes
#			SET(OPENCV2_INCLUDE_PATH ${OPENCV2_PATH}/install/include/opencv2 ${OPENCV2_PATH}/install/include)
#		endif(MINGW)
#		
#		# Visual Studio 10
#		if(MSVC10)
#			UNSET(OPENCV2_LIB_PATH CACHE)
#			SET(OPENCV2_LIB_PATH ${BUILD_DIR}/vc10/lib/ CACHE PATH "OpenCV library path")
#			file(GLOB OPENCV2_RELEASE_LIBS "${OPENCV2_LIB_PATH}/*[0-9][0-9][0-9].lib")
#			file(GLOB OPENCV2_DEBUG_LIBS "${OPENCV2_LIB_PATH}/*[0-9][0-9][0-9]d.lib")
#			UNSET(OpenCV_LIBS CACHE)
#			if(BUILD_RELEASE_OPTION)
#				MESSAGE(STATUS "MSVC10 Release libraries OPENCV2_LIB_PATH:${OPENCV2_LIB_PATH}")
#				SET(OpenCV_LIBS "${OPENCV2_RELEASE_LIBS}" CACHE STRING "OpenCV library files")
#			else(BUILD_RELEASE_OPTION)
#				MESSAGE(STATUS "MSVC10 Debug libraries OPENCV2_LIB_PATH:${OPENCV2_LIB_PATH}")
#				SET(OpenCV_LIBS "${OPENCV2_DEBUG_LIBS}" CACHE STRING "OpenCV library files")
#			endif(BUILD_RELEASE_OPTION)
#			# Set the includes
#			SET(OPENCV2_INCLUDE_PATH ${OPENCV2_PATH}/build/include/opencv2 ${OPENCV2_PATH}/build/include)
#		endif(MSVC10)
#				
#		# Visual Studio 12
#		if(MSVC12)
#			UNSET(OPENCV2_LIB_PATH CACHE)
#			SET(OPENCV2_LIB_PATH ${BUILD_DIR}/vc12/lib/ CACHE PATH "OpenCV library path")
#			file(GLOB OPENCV2_RELEASE_LIBS "${OPENCV2_LIB_PATH}/*[0-9][0-9][0-9].lib")
#			file(GLOB OPENCV2_DEBUG_LIBS "${OPENCV2_LIB_PATH}/*[0-9][0-9][0-9]d.lib")
#			UNSET(OpenCV_LIBS CACHE)
#			if(BUILD_RELEASE_OPTION)
#				MESSAGE(STATUS "MSVC12 Release libraries OPENCV2_LIB_PATH:${OPENCV2_LIB_PATH}")
#				SET(OpenCV_LIBS "${OPENCV2_RELEASE_LIBS}" CACHE STRING "OpenCV library files")
#			else(BUILD_RELEASE_OPTION)
#				MESSAGE(STATUS "MSVC12 Debug libraries OPENCV2_LIB_PATH:${OPENCV2_LIB_PATH}")
#				SET(OpenCV_LIBS "${OPENCV2_DEBUG_LIBS}" CACHE STRING "OpenCV library files")
#			endif(BUILD_RELEASE_OPTION)
#			# Set the includes
#			SET(OPENCV2_INCLUDE_PATH ${OPENCV2_PATH}/build/include/opencv2 ${OPENCV2_PATH}/build/include)
#		endif(MSVC12)
#
#
#	else( OPENCV2_PATH )
#		message( STATUS "Looking for OpenCV2.4 or greater  - not found" )
#		SET ( OPENCV2_FOUND 0 )
#	endif( OPENCV2_PATH )
#
#ELSE(WIN32) # Linux
#	FIND_PATH( OPENCV2_INCLUDE_PATH opencv.hpp
#	# installation selected by user
#	$ENV{OPENCV_HOME}/include
#	# system placed in /usr/local/include
#	/usr/local/include/opencv2
#	# system placed in /usr/include
#	/usr/include/opencv2
#	)
#	
#	if( OPENCV2_INCLUDE_PATH )
#		MESSAGE( STATUS "Looking for OpenCV2.4 or greater - found")
#		MESSAGE( STATUS "OpenCV2.4 include path: ${OPENCV2_INCLUDE_PATH}" )
#		SET ( OPENCV2_FOUND 1 )
#	else( OPENCV2_INCLUDE_PATH )
#		message( STATUS "Looking for OpenCV2.4 or greater  - not found" )
#		SET ( OPENCV2_FOUND 0 )
#	endif( OPENCV2_INCLUDE_PATH )
#	
#ENDIF(WIN32)
#
#endif (NOT OpenCV_FOUND)
#
#
#IF(OPENCV2_FOUND)
#		INCLUDE_DIRECTORIES( ${OPENCV2_INCLUDE_PATH})
#ENDIF(OPENCV2_FOUND)



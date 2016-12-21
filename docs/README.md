
## Arguments for `cmake -P arcbuild.cmake`

```cmake
_BUILD          # MUST BE "ON"
TYPE            # type of target library, "static" or "shared", "shared" by default
PLATFORM        # target platform, e.g. android, ios, vs2015, etc.
ARCH            # target architectures, e.g. armv7-a, "armv7;armv7s;arm64", etc.
ROOT            # root directory of SDK or empty. e.g. "E:\NDK\android-ndk-r11b", default is empty.
BUILD_TYPE      # build configure in "Debug|Release|MinSizeRel|RelWithDebInfo", default is "Release"
API_VERSION     # SDK API version, e.g. android-9, default is empty.
MAKE_PROGRAM    # path of "make" program, usually is searched automatically.
TOOLCHAIN_FILE  # toolchain file for CMake, usually is set automatically.
VERBOSE         # level of debug output, 0 for quiet mode, 1 for normal, 2 for verbose makefile, default is 1.

C_FLAGS         # compile flags for C compiler.
CXX_FLAGS       # compile flags for C++ compiler.
LINK_FLAGS      # linker flags.

CUSTOMER        # SDK customer, add "_FOR_<CUSTOMER>" in package name.
SUFFIX          # add this suffix to package name.

# Following arguments are unstable.
SDK             # reserved
STL             # reserved
```


## Arguments for `arcbuild_define_arcsoft_sdk()`

This `CMake` function define ArcSoft SDK information which is used by build system when calling `cmake -P arcbuild.cmake`.

```cmake
if(ARCBUILD) # defined when calling "cmake -P arcbuild.cmake"
  arcbuild_define_arcsoft_sdk(
    arcsoft_xxx             # SDK name
    LIBRARY arcsoft_xxx     # SDK main library
    INCS inc/*.h            # SDK headers
    VERSION_FILE src/version.c # SDK version file
    SAMPLE_CODE samplecodes/samplecode.c # SDK sample code
    RELEASE_NOTES releasenotes.txt # SDK release notes
    DOCS doc/*.pdf          # SDK docs
  )
endif()
```
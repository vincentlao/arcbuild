include(${ARCBUILD_DIR}/core.cmake)


function(arcbuild_get_platform_code var_name)
  set(code "00" "[unknow_arch]")
  if(ANDROID OR ARCBUILD_PLATFORM STREQUAL "android")
    set(code "120" "android")
  elseif(IOS OR ARCBUILD_PLATFORM MATCHES "^ios")
    if(SDK_API_VERSION VERSION_GREATER "8")
      set(code "167" "ios8")
    elseif(SDK_API_VERSION VERSION_GREATER "7")
      set(code "166" "ios7")
    elseif(SDK_API_VERSION VERSION_GREATER "6")
      set(code "164" "ios6")
    elseif(SDK_API_VERSION VERSION_GREATER "5")
      set(code "163" "ios5")
    else()
      set(code "163" "ios")
    endif()
  elseif(TIZEN OR ARCBUILD_PLATFORM STREQUAL "tizen")
    set(code "107" "tizen")
  elseif(COACH OR ARCBUILD_PLATFORM STREQUAL "coach")
    set(code "124" "coach")
  elseif(UNIX OR ARCBUILD_PLATFORM STREQUAL "linux")
    set(code "124" "linux")
  elseif(MSVC)
    if(MSVC14) # vs2015
      set(code "41" "vs2015")
    elseif(MSVC12) # vs2013
      set(code "39" "vs2013")
    elseif(MSVC11) # vs2012
      set(code "37" "vs2012")
    elseif(MSVC10) # vs2010
      set(code "38" "vs2010")
    elseif(MSVC90) # vs2008
      set(code "36" "vs2008")
    elseif(MSVC80) # vs2005
      set(code "31" "vs2005")
    elseif(MSVC60) # vc6
      set(code "30" "vc6")
    endif()
    # list(INSERT code 1 "windows")
  endif()
  set(${var_name} ${code} PARENT_SCOPE)
endfunction()


function(arcbuild_get_arch_code var_name)
  set(code "00" "[unkown_platform]")
  if(SDK_ARCH)
    if(SDK_ARCH MATCHES "armv8")
      set(code "23")
    elseif(SDK_ARCH MATCHES "armv8-a")
      set(code "23")
    elseif(SDK_ARCH MATCHES "arm64")
      set(code "23")
    elseif(SDK_ARCH MATCHES "armv7")
      set(code "21")
    elseif("armv7-a" STREQUAL SDK_ARCH)
      set(code "21")
    elseif("arm" STREQUAL SDK_ARCH)
      set(code "10")
    elseif("x64" STREQUAL SDK_ARCH)
      set(code "02")
    elseif("x86" STREQUAL SDK_ARCH)
      set(code "00")
    endif()
    set(code ${code} ${SDK_ARCH})
  else()
    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
      set(code "00" "x86")
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
      set(code "02" "x64")
    endif()
  endif()
  set(${var_name} ${code} PARENT_SCOPE)
endfunction()


function(arcbuild_get_platform_number var_name)
  arcbuild_get_platform_code(platform_code)
  arcbuild_get_arch_code(arch_code)
  list(GET platform_code 0 platform_code)
  list(GET arch_code 0 arch_code)
  set(${var_name} "${platform_code}${arch_code}" PARENT_SCOPE)
endfunction()


function(arcbuild_get_full_version var_name v_major v_minor v_build)
  arcbuild_get_platform_number(v_platorm)
  set(${var_name} "${v_major}.${v_minor}.${v_platorm}.${v_build}" PARENT_SCOPE)
endfunction()


function(split_version var_name version)
  string(REPLACE "." ";" var_name ${version})
endfunction()


function(arcbuild_get_build_type var_name name)
  get_target_property(build_type ${name} TYPE)
  if(build_type STREQUAL "STATIC_LIBRARY")
    set(build_type "static")
  elseif(build_type STREQUAL "SHARED_LIBRARY")
    set(build_type "shared")
  else()
    arcbuild_error("Unknown build type of target \"${name}\": ${build_type}!")
  endif()
  set(${var_name} ${build_type} PARENT_SCOPE)
endfunction()


function(arcbuild_get_abi_name var_name)
  arcbuild_get_platform_code(platform)
  arcbuild_get_arch_code(arch)
  list(REMOVE_AT platform 0)
  list(REMOVE_AT arch 0)
  if(platform STREQUAL "android")
    if(arch STREQUAL "arm")
      set(abi_name "armeabi")
    elseif(arch STREQUAL "armv7-a")
      set(abi_name "armeabi-v7a")
    elseif(arch STREQUAL "arm64")
      set(abi_name "arm64-v8a")
    endif()
  else()
    join(abi_name "_" ${platform} ${arch})
  endif()
  set(${var_name} ${abi_name} PARENT_SCOPE)
endfunction()


function(arcbuild_get_package_name_parts var_name name version build_type)
  arcbuild_get_platform_code(platform)
  arcbuild_get_arch_code(arch)
  list(REMOVE_AT platform 0)
  list(REMOVE_AT arch 0)
  string(TIMESTAMP current_date "%m%d%Y")
  set(parts ${name} ${version} ${platform} ${arch} ${build_type} ${current_date})
  set(${var_name} ${parts} PARENT_SCOPE)
endfunction()


function(arcbuild_get_package_name var_name sdk_name version build_type)
  arcbuild_get_package_name_parts(package_name_parts ${sdk_name} ${version} ${build_type})
  join(package_name "_" ${package_name_parts})
  string(TOUPPER "${package_name}" package_name)
  set(${var_name} ${package_name} PARENT_SCOPE)

  if(ARCBUILD_CUSTOMER)
    list(INSERT package_name_parts 4 "FOR" ${ARCBUILD_CUSTOMER})
  endif()
  join(full_package_name "_" ${package_name_parts})
  if(ARCBUILD_SUFFIX)
    set(full_package_name "${full_package_name}${ARCBUILD_SUFFIX}")
  endif()
  string(TOUPPER "${full_package_name}" full_package_name)
  arcbuild_echo("Package name: ${package_name}")
  arcbuild_echo("Full Package name: ${full_package_name}")
endfunction()


function(arcbuild_get_full_package_name var_name sdk_name version build_type)
  arcbuild_get_package_name_parts(package_name_parts ${sdk_name} ${version} ${build_type})
  if(ARCBUILD_CUSTOMER)
    list(INSERT package_name_parts 4 "FOR" ${ARCBUILD_CUSTOMER})
  endif()
  join(full_package_name "_" ${package_name_parts})
  if(ARCBUILD_SUFFIX)
    set(full_package_name "${full_package_name}${ARCBUILD_SUFFIX}")
  endif()
  string(TOUPPER "${full_package_name}" full_package_name)
  set(${var_name} ${full_package_name} PARENT_SCOPE)
endfunction()


function(arcbuild_update_version_file name path version)
  arcbuild_echo("Read version file: ${path}")
  file(READ ${path} content)
  string(TIMESTAMP current_date "%m/%d/%Y")
  string(TIMESTAMP current_year "%Y")
  string(REPLACE "." ";" version_numbers ${version})
  list(GET version_numbers 0 v_major)
  list(GET version_numbers 1 v_minor)
  list(GET version_numbers 3 v_build)
  string(REGEX REPLACE "(#define VERSION_MAJOR[ \t]+)([0-9]+)" "\\1${v_major}" content "${content}")
  string(REGEX REPLACE "(#define VERSION_MINOR[ \t]+)([0-9]+)" "\\1${v_minor}" content "${content}")
  string(REGEX REPLACE "(#define VERSION_BUILD[ \t]+)([0-9]+)" "\\1${v_build}" content "${content}")
  string(REGEX REPLACE "(#define VERSION_DATE[^0-9/]+)([0-9/]+)" "\\1${current_date}" content "${content}")
  string(REGEX REPLACE "(#define VERSION_VERSION[^0-9.]+)([0-9.]+)" "\\1${version}" content "${content}")
  string(REGEX REPLACE "(#define VERSION_COPYRIGHT.+)([1-2][0-9][0-9][0-9])" "\\1${current_year}" content "${content}")
  get_target_property(sources ${name} SOURCES)
  get_filename_component(base_name ${path} NAME)
  get_filename_component(full_path ${path} REALPATH)
  set(new_path "${PROJECT_BINARY_DIR}/generated_${base_name}")
  list(REMOVE_ITEM sources ${full_path})
  arcbuild_echo("Generate version file: ${new_path}")
  file(WRITE ${new_path} "${content}")
  list(APPEND sources ${new_path})
  set_target_properties(${name} PROPERTIES SOURCES "${sources}")
endfunction()

function(arcbuild_get_compile_flags var_name name)
  string(TOUPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE)
  set(flags "${CMAKE_C_FLAGS} ${CMAKE_CXX_FLAGS} ${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}} ${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}}")
  get_target_property(custom_flags ${name} COMPILE_FLAGS)
  if(custom_flags)
    set(flags "${flags} ${custom_flags}")
  endif()

  # Remove paths
  string(REGEX REPLACE "[^ \t]*\"[^\"]+\"" "" flags "${flags}")

  # Filter some flags
  set(flitered_flags)
  foreach(flag ${flags})
  endforeach()
  string(STRIP ${flags} flags)

  # Remove duplicates flags
  string(REGEX REPLACE "[ \t]+" ";" flags "${flags}")
  list(REMOVE_DUPLICATES flags)
  join(flags " " "${flags}")

  set(${var_name} ${flags} PARENT_SCOPE)
endfunction()

function(arcbuild_update_releasenotes name new_path path version)
  arcbuild_get_compile_flags(flags ${name})
  arcbuild_echo("Compile flags: ${flags}")
  string(TIMESTAMP current_date "%Y/%m/%d")
  arcbuild_get_platform_code(platform)
  arcbuild_get_arch_code(arch)
  list(REMOVE_AT platform 0)
  list(REMOVE_AT arch 0)
  join(platform "_" ${platform})
  join(arch "_" ${arch})
  file(READ ${path} content)
  string(REGEX REPLACE "(Publish date:[ \r\n]+)[^\r\n]+" "\\1${current_date}" content "${content}")
  string(REGEX REPLACE "(Version:[ \r\n]+)[^\r\n]+" "\\1${version}" content "${content}")
  string(REGEX REPLACE "(Supported platforms:[ \r\n]+)[^\r\n]+" "\\1${platform}_${arch}" content "${content}")
  string(REGEX REPLACE "(Compile Option:[ \r\n]+)[^\r\n]+" "\\1${flags}" content "${content}")
  file(WRITE ${new_path} "${content}")
endfunction()

function(arcbuild_get_version_from_release_notes path vv_major vv_minor vv_build)
  file(READ "${path}" content)
  string(REGEX MATCH "Change logs:[ \r\n]+[0-9.]+" version "${content}")
  string(REGEX MATCH "[0-9.]+" version "${version}")
  string(REPLACE "." ";" version "${version}")
  list(LENGTH version len)
  if(len EQUAL 4)
    list(GET version 0 v_major)
    list(GET version 1 v_minor)
    list(GET version 3 v_build)
  elseif(len EQUAL 3)
    list(GET version 0 v_major)
    list(GET version 1 v_minor)
    list(GET version 2 v_build)
  elseif(len EQUAL 2)
    list(GET version 0 v_major)
    list(GET version 1 v_minor)
    set(v_build 0)
  elseif(len EQUAL 1)
    list(GET version 0 v_major)
    set(v_minor 0)
    set(v_build 0)
  endif()
  set(${vv_major} ${v_major} PARENT_SCOPE)
  set(${vv_minor} ${v_minor} PARENT_SCOPE)
  set(${vv_build} ${v_build} PARENT_SCOPE)
endfunction()


function(arcbuild_get_version_from_version_file path vv_major vv_minor vv_build)
  file(READ "${path}" content)
  string(REGEX MATCH "#define VERSION_VERSION[^\r\n]+" version "${content}")
  string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+" version "${version}")
  string(REPLACE "." ";" version "${version}")
  list(GET version 0 v_major)
  list(GET version 1 v_minor)
  list(GET version 3 v_build)
  set(${vv_major} ${v_major} PARENT_SCOPE)
  set(${vv_minor} ${v_minor} PARENT_SCOPE)
  set(${vv_build} ${v_build} PARENT_SCOPE)
endfunction()


function(arcbuild_has_mpbase_dependency var_name name)
  get_target_property(all_depends ${name} LINK_LIBRARIES)
  foreach(depend ${all_depends})
    if(depend MATCHES "(mpbase|mpbase.a|mpbase.lib)$")
      set(has_depend 1)
      break()
    endif()
  endforeach()
  if(has_depend)
    set(${var_name} ${has_depend} PARENT_SCOPE)
  endif()
endfunction()


function(arcbuild_define_arcsoft_sdk sdk_name)
  # Parse arguments
  set(args_option_args)
  set(args_single_value_args LIBRARY VERSION_FILE RELEASE_NOTES)
  set(args_multiple_values_args INCS DOCS SAMPLE_CODE)
  cmake_parse_arguments(A
    "${args_option_args}" # options
    "${args_single_value_args}" # single value
    "${args_multiple_values_args}" # multiple values
    ${ARGN}
  )

  file(GLOB A_INCS ${A_INCS})

  if(NOT A_LIBRARY)
    set(A_LIBRARY ${sdk_name})
  endif()

  # Combine more dependencies into one target
  set(name ${A_LIBRARY})
  arcbuild_combine_target(${name})

  if(A_SAMPLE_CODE)
    if(TARGET "${A_SAMPLE_CODE}")
      get_target_property(A_SAMPLE_CODE_SOURCES ${A_SAMPLE_CODE} SOURCES)
    else()
      file(GLOB A_SAMPLE_CODE_SOURCES ${A_SAMPLE_CODE})
      set(A_SAMPLE_CODE samplecode)
      if(NOT TARGET ${A_SAMPLE_CODE})
        arcbuild_echo("Creating samplecode project")
        add_executable(${A_SAMPLE_CODE} ${A_SAMPLE_CODE_SOURCES})
        target_link_libraries(${A_SAMPLE_CODE} ${name})
      endif()
    endif()
  endif()
  arcbuild_echo("Define ArcSoft SDK: ${sdk_name}")
  arcbuild_echo("- Target library: ${A_LIBRARY}")
  arcbuild_echo("- Include headers: ${A_INCS}")
  arcbuild_echo("- Version file: ${A_VERSION_FILE}")
  arcbuild_echo("- Sample code: ${A_SAMPLE_CODE_SOURCES}")
  arcbuild_echo("- Relasenotes: ${A_RELEASE_NOTES}")
  arcbuild_echo("- Docs: ${A_DOCS}")

  # Get version
  if(A_RELEASE_NOTES)
    arcbuild_get_version_from_release_notes(${A_RELEASE_NOTES} v_major v_minor v_build)
  elseif(A_VERSION_FILE)
    arcbuild_get_version_from_version_file(${A_VERSION_FILE} v_major v_minor v_build)
  endif()
  arcbuild_get_full_version(version ${v_major} ${v_minor} ${v_build})

  # Update version file
  if(A_VERSION_FILE)
    arcbuild_update_version_file(${name} ${A_VERSION_FILE} ${version})
  endif()

  # Package name
  arcbuild_get_build_type(build_type ${name})
  arcbuild_get_package_name(package_name ${sdk_name} ${version} ${build_type})
  arcbuild_get_full_package_name(full_package_name ${sdk_name} ${version} ${build_type})
  arcbuild_echo("Package name: ${package_name}")
  arcbuild_echo("Full Package name: ${full_package_name}")

  # ABI name
  arcbuild_get_abi_name(abi_name)
  arcbuild_echo("ABI name: ${abi_name}")

  # Install targets
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Install path prefix" FORCE)

  arcbuild_has_mpbase_dependency(HAS_MPBASE ${name})
  if(HAS_MPBASE AND MPBASE)
    arcbuild_echo("Has mpbase dependency")
    set(prefix "${package_name}/")
    get_target_property(MPBASE_INCLUDE_DIR mpbase INTERFACE_INCLUDE_DIRECTORIES)
    get_target_property(MPBASE_LIBRARY mpbase LOCATION)
    install(DIRECTORY "${MPBASE_INCLUDE_DIR}" DESTINATION "PLATFORM")
    install(FILES "${MPBASE_LIBRARY}" DESTINATION "PLATFORM/lib")
    install(FILES "${MPBASE}/releasenotes.txt" DESTINATION "PLATFORM")
  endif()

  # file(REMOVE_RECURSE "${CMAKE_INSTALL_PREFIX}")
  install(FILES ${A_INCS} DESTINATION "${prefix}inc")
  install(TARGETS ${A_LIBRARY} DESTINATION "${prefix}lib/${abi_name}")
  if(A_SAMPLE_CODE)
    # install(FILES $<TARGET_PROPERTY:${A_SAMPLE_CODE},SOURCES> DESTINATION "${prefix}samplecode")
    install(FILES ${A_SAMPLE_CODE_SOURCES} DESTINATION "${prefix}samplecode")
  endif()
  if(A_DOCS)
    file(GLOB A_DOCS ${A_DOCS})
    install(FILES ${A_DOCS} DESTINATION "${prefix}doc")
  endif()

  # Install prebuilt libraries
  arcbuild_install_prebuilt_libraries(${name} "${prefix}lib/${abi_name}")

  # Update releasenotes
  if(A_RELEASE_NOTES)
    get_filename_component(rlsnote_base_name "${A_RELEASE_NOTES}" NAME)
    set(NEW_RELEASE_NOTES_PATH "${PROJECT_BINARY_DIR}/${rlsnote_base_name}")
    arcbuild_update_releasenotes(${name} ${NEW_RELEASE_NOTES_PATH} ${A_RELEASE_NOTES} ${version})
    install(FILES ${NEW_RELEASE_NOTES_PATH} DESTINATION "${prefix}.")

    # Update file list in releasenotes
    set(PACKAGE_NAME ${prefix})
    set(RELEASE_NOTES "${rlsnote_base_name}")
    set(install_script "${PROJECT_BINARY_DIR}/update_file_list.cmake")
    set(ARCBUILD_UPDATE_FILE_LIST ON)
    configure_file("${ARCBUILD_DIR}/update_file_list.cmake" ${install_script} @ONLY)
    install(SCRIPT "${install_script}")
    # debug
    # include(${ARCBUILD_DIR}/update_file_list.cmake)
    # arcbuild_update_file_list("${CMAKE_INSTALL_PREFIX}/${package_name}" "${RELEASE_NOTES_PATH}")
  endif()

  # CPack settings
  set(CPACK_PACKAGE_FILE_NAME ${full_package_name})
  set(CPACK_GENERATOR ZIP)
  include(CPack)
endfunction()

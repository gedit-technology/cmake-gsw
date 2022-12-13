# "Gsw" as in "G swilmet" or "G software", as a namespace.


macro (GswInitBasic)
  find_package (PkgConfig REQUIRED)
  include (GNUInstallDirs)
  set (CMAKE_EXPORT_COMPILE_COMMANDS TRUE)
endmacro ()

# Try to mimic the AX_COMPILER_FLAGS Autotools macro.
#
# For the rationale (having such a long list of flags instead of just relying on
# -Wall and -Wextra) see the GCC manpage for the -Wall option:
#
# """
# Note that some warning flags are not implied by -Wall. Some of them warn about
# constructions that users generally do not consider questionable, but which
# occasionally you might wish to check for; others warn about constructions that
# are necessary or hard to avoid in some cases, and there is no simple way to
# modify the code to suppress the warning. Some of them are enabled by -Wextra
# but many of them must be enabled individually.
# """
function (GswCompilerFlags target_name)
  target_compile_options ("${target_name}" PRIVATE
    "-Wall"
    "-Wextra"
    "-fno-strict-aliasing"
    "-Wundef"
    "-Wwrite-strings"
    "-Wpointer-arith"
    "-Wmissing-declarations"
    "-Wredundant-decls"
    "-Wno-unused-parameter"
    "-Wno-missing-field-initializers"
    "-Wformat=2"
    "-Wcast-align"
    "-Wformat-nonliteral"
    "-Wformat-security"
    "-Wsign-compare"
    "-Wstrict-aliasing"
    "-Wshadow"
    "-Winline"
    "-Wpacked"
    "-Wmissing-format-attribute"
    "-Wmissing-noreturn"
    "-Winit-self"
    "-Wredundant-decls"
    "-Wmissing-include-dirs"
    "-Wunused-but-set-variable"
    "-Warray-bounds"
    "-Wreturn-type"
    "-Wswitch-enum"
    "-Wswitch-default"
    "-Wduplicated-cond"
    "-Wduplicated-branches"
    "-Wlogical-op"
    "-Wrestrict"
    "-Wnull-dereference"
    "-Wdouble-promotion"
    "-Wnested-externs"
    "-Wmissing-prototypes"
    "-Wstrict-prototypes"
    "-Wdeclaration-after-statement"
    "-Wimplicit-function-declaration"
    "-Wold-style-definition"
    "-Wjump-misses-init"
  )
endfunction ()

function (GswApplyPkgConfigDepsToTarget target_name pkg_dep)
  target_include_directories ("${target_name}" PRIVATE ${${pkg_dep}_INCLUDE_DIRS})
  target_compile_options ("${target_name}" PRIVATE ${${pkg_dep}_CFLAGS_OTHER})
  target_link_libraries ("${target_name}" ${${pkg_dep}_LDFLAGS})
endfunction ()

function (GswAddExecutable executable_name sources pkg_dep)
  add_executable ("${executable_name}" ${sources})

  GswApplyPkgConfigDepsToTarget ("${executable_name}" "${pkg_dep}")
  GswCompilerFlags ("${executable_name}")

  install (TARGETS "${executable_name}"
    DESTINATION "${CMAKE_INSTALL_BINDIR}")
endfunction ()

function (GswAddLibrary library_name sources pkg_dep)
  add_library ("${library_name}" SHARED ${sources})

  GswApplyPkgConfigDepsToTarget ("${library_name}" "${pkg_dep}")
  GswCompilerFlags ("${library_name}")

  install (TARGETS "${library_name}"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}")
endfunction ()

function (GswDefineGLogDomain target_name)
  target_compile_definitions ("${target_name}"
    PRIVATE "-DG_LOG_DOMAIN=\"${PROJECT_NAME}\"")
endfunction ()

function (GswLibraryEnsureSingleHeaderExternalInclude library_name)
  target_compile_definitions ("${library_name}"
    PRIVATE "-D${GSW_LIB_NAME_UPPERCASE}_COMPILATION")
endfunction ()

# Useful for printing a configuration summary.
function (GswYesOrNo condition result)
  if (${condition})
    set (${result} yes PARENT_SCOPE)
  else ()
    set (${result} no PARENT_SCOPE)
  endif ()
endfunction ()

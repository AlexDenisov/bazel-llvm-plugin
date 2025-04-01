# buildifier: disable=module-docstring

load("@//:bazel/utils.bzl", "dylib_extension", "llvm_path")
load("@available_llvm_versions//:llvm_versions.bzl", "AVAILABLE_LLVM_VERSIONS")
load("@bazel_skylib//lib:modules.bzl", "modules")
load("@bazel_tools//tools/build_defs/repo:local.bzl", "new_local_repository")

LLVM_BUILD_FILE = """
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")
load("@rules_cc//cc:defs.bzl", "cc_import", "cc_library")

cc_import(
    name = "llvm_private",
    hdrs = glob([
        "include/llvm/**/*.h",
        "include/llvm-c/**/*.h",
        "include/llvm/**/*.def",
        "include/llvm/**/*.inc",
    ]),
    shared_library = "lib/{LIBLLVM_DYLIB}",
)

cc_library(
    name = "libllvm",
    includes = ["include"],
    visibility = ["//visibility:public"],
    deps = [":llvm_private"],
)

native_binary(
    name = "clang",
    src = "bin/clang",
    out = "clang",
    visibility = ["//visibility:public"],
)
native_binary(
    name = "FileCheck",
    src = "bin/FileCheck",
    out = "FileCheck",
    visibility = ["//visibility:public"],
)
"""

def _empty_repo_impl(repository_ctx):
    repository_ctx.file(
        "BUILD",
        content = "",
    )

empty_repo = repository_rule(
    local = True,
    implementation = _empty_repo_impl,
)

def _find_llvm_dylib(ctx, path):
    libdir = path + "/lib"
    dylib = "libLLVM." + dylib_extension(ctx)
    for f in ctx.path(libdir).readdir():
        if f.basename.startswith(dylib):
            return f.basename
    return None

def _llvm_repos_extension(module_ctx):
    """Module extension to dynamically declare local LLVM repositories."""
    for mod in module_ctx.modules:
        for data in mod.tags.configure:
            for version in data.versions:
                llvm_repo_name = "llvm_" + version
                if version not in AVAILABLE_LLVM_VERSIONS:
                    empty_repo(name = llvm_repo_name)
                    continue

                path = llvm_path(module_ctx, version)
                llvm_dylib = _find_llvm_dylib(module_ctx, path)
                new_local_repository(
                    name = llvm_repo_name,
                    path = path,
                    build_file_content = LLVM_BUILD_FILE.format(
                        LIBLLVM_DYLIB = llvm_dylib,
                    ),
                )

    return modules.use_all_repos(module_ctx)

llvm_repos = module_extension(
    implementation = _llvm_repos_extension,
    tag_classes = {"configure": tag_class(attrs = {"versions": attr.string_list()})},
)

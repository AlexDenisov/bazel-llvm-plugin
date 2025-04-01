load("@available_llvm_versions//:llvm_versions.bzl", "AVAILABLE_LLVM_VERSIONS")
load("@rules_cc//cc:defs.bzl", "cc_binary")

[
    cc_binary(
        name = "llvm_plugin_%s" % llvm_version,
        srcs = [
            "plugin.cpp",
        ],
        linkshared = True,
        visibility = ["//visibility:public"],
        deps = [
            "@llvm_%s//:libllvm" % llvm_version,
        ],
    )
    for llvm_version in AVAILABLE_LLVM_VERSIONS
]

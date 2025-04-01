load("@available_llvm_versions//:llvm_versions.bzl", "AVAILABLE_LLVM_VERSIONS")
load("@bazel_itertools//lib:itertools.bzl", "itertools")
load("@pypi//:requirements.bzl", "requirement")
load("@rules_python//python:defs.bzl", "py_test")

[
    py_test(
        name = "%s_%s_test" % (test, llvm_version),
        srcs = ["lit_runner.py"],
        args = [
            "-v",
            test,
        ],
        data = [
            requirement("lit"),
            ":lit.cfg.py",
            "@llvm_%s//:clang" % llvm_version,
            "@llvm_%s//:FileCheck" % llvm_version,
            "//src:llvm_plugin_%s" % llvm_version,
            test,
        ],
        env = {
            "LLVM_VERSION_MAJOR": llvm_version,
        },
        main = "lit_runner.py",
        deps = [
            requirement("lit"),
            "@rules_python//python/runfiles",
        ],
    )
    for (test, llvm_version) in itertools.product(
        glob(["*.c"]),
        AVAILABLE_LLVM_VERSIONS,
    )
]

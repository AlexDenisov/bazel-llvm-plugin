# buildifier: disable=module-docstring

load("@//:bazel/utils.bzl", "llvm_path")

def _is_supported(repository_ctx, version):
    return repository_ctx.path(llvm_path(repository_ctx, version)).exists

def _llvm_versions_repo_impl(repository_ctx):
    available_versions = []
    for version in repository_ctx.attr.versions:
        if _is_supported(repository_ctx, version):
            available_versions.append(version)
    if len(available_versions) == 0:
        fail("Could not find any supported LLVM versions installed")
    repository_ctx.file(
        "llvm_versions.bzl",
        content = "AVAILABLE_LLVM_VERSIONS = " + str(available_versions),
    )
    repository_ctx.file(
        "BUILD",
        content = "",
    )

available_llvm_versions_repo = repository_rule(
    local = True,
    implementation = _llvm_versions_repo_impl,
    attrs = {
        "versions": attr.string_list(),
    },
)

def _available_llvm_versions_impl(module_ctx):
    versions = []
    for mod in module_ctx.modules:
        for data in mod.tags.detect_available:
            for version in data.versions:
                versions.append(version)
    available_llvm_versions_repo(name = "available_llvm_versions", versions = versions)

available_llvm_versions = module_extension(
    implementation = _available_llvm_versions_impl,
    tag_classes = {
        "detect_available": tag_class(attrs = {"versions": attr.string_list(allow_empty = False)}),
    },
)

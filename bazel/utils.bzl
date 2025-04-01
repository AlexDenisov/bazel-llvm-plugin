# buildifier: disable=module-docstring

def _is_macos(ctx):
    return ctx.os.name.find("mac") != -1

def llvm_path(ctx, version):
    if _is_macos(ctx):
        return "/opt/homebrew/opt/llvm@" + version
    return "/usr/lib/llvm-" + version

def dylib_extension(ctx):
    if _is_macos(ctx):
        return "dylib"
    return "so"

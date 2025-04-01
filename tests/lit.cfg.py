import platform
import re
import os
import lit.formats

from python.runfiles import Runfiles

r = Runfiles.Create()

config = globals()["config"]
config.name = "Integration tests"
config.test_format = lit.formats.ShTest("0")

llvm_major_version = os.environ.get("LLVM_VERSION_MAJOR", None)
assert llvm_major_version

ext = "so"

if platform.system() == "Darwin":
    ext = "dylib"

clang = r.Rlocation(f"llvm_{llvm_major_version}/clang")
filecheck = r.Rlocation(f"llvm_{llvm_major_version}/FileCheck")
plugin = r.Rlocation(f"_main/src/libllvm_plugin_{llvm_major_version}.{ext}")

config.substitutions.append(("clang", clang))
config.substitutions.append(("%llvm_plugin", plugin))
config.substitutions.append(("FileCheck", filecheck))

config.suffixes = [".c"]

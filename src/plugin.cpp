#include <llvm/IR/Module.h>
#include <llvm/Passes/PassBuilder.h>
#include <llvm/Passes/PassPlugin.h>
#include <llvm/Support/raw_ostream.h>

namespace
{

  class HelloPlugin : public llvm::PassInfoMixin<HelloPlugin>
  {
  public:
    llvm::PreservedAnalyses run(llvm::Module &module, llvm::ModuleAnalysisManager &mam)
    {
      for (auto &function : module)
      {
        llvm::outs() << "Found function: " << function.getName() << "\n";
      }
      return llvm::PreservedAnalyses::none();
    }
  };

  extern "C" __attribute__((visibility("default"))) LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
  llvmGetPassPluginInfo()
  {
    return {LLVM_PLUGIN_API_VERSION,
            "llvm-plugin",
            LLVM_VERSION_STRING,
            [](llvm::PassBuilder &PB)
            {
              PB.registerPipelineStartEPCallback([](llvm::ModulePassManager &modulePassManager,
                                                    llvm::OptimizationLevel optimizationLevel)
                                                 { modulePassManager.addPass(HelloPlugin()); });
            }};
  }

} // namespace

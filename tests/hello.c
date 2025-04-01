// RUN: clang -c %s -fpass-plugin=%llvm_plugin | FileCheck %s

extern int printf(const char *, ...);

void hello()
{
  printf("Hello, world\n");
}

// CHECK: Found function: hello
// CHECK: Found function: printf

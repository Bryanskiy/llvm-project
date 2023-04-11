//===-- GArchTargetInfo.cpp - GArch Target Implementation -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "GArch.h"
#include "llvm/IR/Module.h"
#include "llvm/MC/TargetRegistry.h"
using namespace llvm;

Target llvm::TheGArchTarget;

extern "C" void LLVMInitializeGArchTargetInfo() {
  RegisterTarget<Triple::garch,
                 /*HasJIT=*/false>
      X(TheGArchTarget, "GArch", "GArch (32-bit simulator arch)", "GArch");
}

//===-- GArch.h - Top-level interface for Sim representation ----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in
// the LLVM GArch back-end.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_GArch_GArch_H
#define LLVM_LIB_TARGET_GArch_GArch_H

#include "MCTargetDesc/GArchMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
  class GArchTargetMachine;
  class FunctionPass;

} // end namespace llvm;

#endif
//===-- GArchMCTargetDesc.h - GArch Target Descriptions ---------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides GArch specific target descriptions.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_GArch_MCTARGETDESC_GArchMCTARGETDESC_H
#define LLVM_LIB_TARGET_GArch_MCTARGETDESC_GArchMCTARGETDESC_H

#include "llvm/Support/DataTypes.h"

#include <memory>

namespace llvm {
class Target;
class Triple;

extern Target TheGArchTarget;

} // End llvm namespace

// Defines symbolic names for GArch registers.  This defines a mapping from
// register name to register number.
#define GET_REGINFO_ENUM
#include "GArchGenRegisterInfo.inc"

// Defines symbolic names for the GArch instructions.
#define GET_INSTRINFO_ENUM
#include "GArchGenInstrInfo.inc"

#endif

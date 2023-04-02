#ifndef LLVM_LIB_TARGET_sim_MCTARGETDESC_simMCTARGETDESC_H
#define LLVM_LIB_TARGET_sim_MCTARGETDESC_simMCTARGETDESC_H

#include "llvm/Support/DataTypes.h"

#include <memory>

namespace llvm {
class Target;
class Triple;

extern Target ThesimTarget;

} // End llvm namespace

// Defines symbolic names for sim registers.  This defines a mapping from
// register name to register number.
#define GET_REGINFO_ENUM
#include "simGenRegisterInfo.inc"

// Defines symbolic names for the sim instructions.
#define GET_INSTRINFO_ENUM
#include "simGenInstrInfo.inc"

#endif

#include "llvm/MC/MCRegister.h"
#include "simInfo.h"

#define GET_REGINFO_ENUM
#include "simGenRegisterInfo.inc"

namespace llvm {

namespace simABI {

// To avoid the BP value clobbered by a function call, we need to choose a
// callee saved register to save the value. RV32E only has X8 and X9 as callee
// saved registers and X8 will be used as fp. So we choose X9 as bp.
MCRegister getBPReg() { return sim::X9; }

// Returns the register holding shadow call stack pointer.
MCRegister getSCSPReg() { return sim::X18; }

} // end namespace simABI

} // end namespace llvm
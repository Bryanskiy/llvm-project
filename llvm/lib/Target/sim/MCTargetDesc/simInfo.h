#ifndef LLVM_LIB_TARGET_sim_MCTARGETDESC_simINFO_H
#define LLVM_LIB_TARGET_sim_MCTARGETDESC_simINFO_H

#include "llvm/MC/MCInstrDesc.h"

namespace llvm {

namespace simII {
enum {
  InstFormatPseudo = 0,
  InstFormatR = 1,
  InstFormatR4 = 2,
  InstFormatI = 3,
  InstFormatS = 4,
  InstFormatB = 5,
  InstFormatU = 6,
  InstFormatJ = 7,
};

// RISC-V Specific Machine Operand Flags
enum {
  MO_None = 0,
  MO_CALL = 1,
  MO_PLT = 2,
  MO_LO = 3,
  MO_HI = 4,
  MO_PCREL_LO = 5,
  MO_PCREL_HI = 6,
  MO_GOT_HI = 7,
  MO_TPREL_LO = 8,
  MO_TPREL_HI = 9,
  MO_TPREL_ADD = 10,
  MO_TLS_GOT_HI = 11,
  MO_TLS_GD_HI = 12,

  // Used to differentiate between target-specific "direct" flags and "bitmask"
  // flags. A machine operand can only have one "direct" flag, but can have
  // multiple "bitmask" flags.
  MO_DIRECT_FLAG_MASK = 15
};
} // end namespace simII

namespace simCC {
enum CondCode {
  COND_EQ,
  COND_NE,
  COND_LT,
  COND_GE,
  COND_LTU,
  COND_GEU,
  COND_INVALID
};

CondCode getOppositeBranchCondition(CondCode);

enum BRCondCode {
  BREQ = 0x0,
};
} // end namespace simCC

namespace simOp {
enum OperandType : unsigned {
  OPERAND_FIRST_RISCV_IMM = MCOI::OPERAND_FIRST_TARGET,
  OPERAND_UIMM2 = OPERAND_FIRST_RISCV_IMM,
  OPERAND_UIMM3,
  OPERAND_UIMM4,
  OPERAND_UIMM5,
  OPERAND_UIMM7,
  OPERAND_UIMM12,
  OPERAND_SIMM12,
  OPERAND_SIMM12_LSB00000,
  OPERAND_UIMM20,
  OPERAND_UIMMLOG2XLEN,
  OPERAND_RVKRNUM,
  OPERAND_LAST_RISCV_IMM = OPERAND_RVKRNUM,
  // Operand is either a register or uimm5, this is used by V extension pseudo
  // instructions to represent a value that be passed as AVL to either vsetvli
  // or vsetivli.
  OPERAND_AVL,
};
} // namespace simOp

namespace simABI {

enum ABI {
  ABI_ILP32,
  ABI_Unknown
};

// Returns the register used to hold the stack pointer after realignment.
MCRegister getBPReg();

// Returns the register holding shadow call stack pointer.
MCRegister getSCSPReg();
} // end namespace simABI

} // end namespace llvm

#endif

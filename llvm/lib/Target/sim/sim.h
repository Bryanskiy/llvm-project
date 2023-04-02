#ifndef LLVM_LIB_TARGET_sim_sim_H
#define LLVM_LIB_TARGET_sim_sim_H

#include "MCTargetDesc/simMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class simTargetMachine;
class FunctionPass;
class simSubtarget;
class AsmPrinter;
class InstructionSelector;
class MCInst;
class MCOperand;
class MachineInstr;
class MachineOperand;
class PassRegistry;

bool lowersimMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                    AsmPrinter &AP);
bool LowersimMachineOperandToMCOperand(const MachineOperand &MO,
                                         MCOperand &MCOp, const AsmPrinter &AP);

FunctionPass *createsimISelDag(simTargetMachine &TM,
                                CodeGenOpt::Level OptLevel);


namespace sim {
enum {
  GP = sim::R0,
  RA = sim::R1,
  SP = sim::R2,
  FP = sim::R3,
  BP = sim::R4,
};
} // namespace sim

} // namespace llvm

#endif

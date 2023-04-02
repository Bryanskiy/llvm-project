#ifndef LLVM_LIB_TARGET_sim_MCTARGETDESC_simMCASMINFO_H
#define LLVM_LIB_TARGET_sim_MCTARGETDESC_simMCASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {

class Triple;

class simMCAsmInfo : public MCAsmInfoELF {
  void anchor() override;

public:
  explicit simMCAsmInfo(const Triple &TT);
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_sim_MCTARGETDESC_simMCASMINFO_H

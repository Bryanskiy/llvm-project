#ifndef LLVM_LIB_TARGET_sim_simTARGETSTREAMER_H
#define LLVM_LIB_TARGET_sim_simTARGETSTREAMER_H

#include "llvm/MC/MCStreamer.h"

namespace llvm {

class simTargetStreamer : public MCTargetStreamer {
public:
  simTargetStreamer(MCStreamer &S);
  ~simTargetStreamer() override;
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_sim_simTARGETSTREAMER_H
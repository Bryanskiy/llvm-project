//===----------------------------------------------------------------------===//
// This is the top level entry point for the sim target.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Target-independent interfaces
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// sim Subtarget features
//===----------------------------------------------------------------------===//

//def FeatureDummy
//    : SubtargetFeature<"dummy", "Dummy", "true",
//                       "Dummy feature">;

//===----------------------------------------------------------------------===//
// Target-dependent interfaces
//===----------------------------------------------------------------------===//

include "simRegisterInfo.td"

//===----------------------------------------------------------------------===//
// Calling Conv, Instruction Descriptions
//===----------------------------------------------------------------------===//

include "simCallingConv.td"

include "simInstrInfo.td"
def simInstrInfo : InstrInfo;

//===----------------------------------------------------------------------===//
// sim processors supported.
//===----------------------------------------------------------------------===//

class Proc<string Name, list<SubtargetFeature> Features>
 : Processor<Name, NoItineraries, Features>;

def : Proc<"generic", []>;
//def : Proc<"dummy-st", []>;

// Will generate simGenAsmWrite.inc included by simInstPrinter.cpp, contents
//  as follows,
// void simInstPrinter::printInstruction(const MCInst *MI, raw_ostream &O) {...}
// const char *simInstPrinter::getRegisterName(unsigned RegNo) {...}
def sim : Target {
  let InstructionSet = simInstrInfo;
}

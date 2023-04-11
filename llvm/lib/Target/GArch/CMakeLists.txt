add_llvm_component_group(GArch)

set(LLVM_TARGET_DEFINITIONS GArch.td)

# Generate SimGenRegisterInfo.inc and SimGenInstrInfo.inc which included by
#  your hand code C++ files.
# SimGenRegisterInfo.inc came from SimRegisterInfo.td, GArchGenInstrInfo.inc
#  came from GArchInstrInfo.td.
tablegen(LLVM GArchGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM GArchGenInstrInfo.inc -gen-instr-info)

# GArchCommonTableGen must be defined
add_public_tablegen_target(GArchCommonTableGen)

# GArchCodeGen should match with LLVMBuild.txt GArchCodeGen
add_llvm_target(GArchCodeGen
  GArchTargetMachine.cpp

  LINK_COMPONENTS
  Analysis
  AsmPrinter
  CodeGen
  Core
  MC
  GArchDesc
  GArchInfo
  SelectionDAG
  Support
  Target
  GlobalISel

  ADD_TO_COMPONENT
  GArch
  )

add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
  
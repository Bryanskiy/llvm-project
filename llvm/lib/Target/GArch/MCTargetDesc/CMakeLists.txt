add_llvm_component_library(LLVMGArchDesc
  GArchMCTargetDesc.cpp

  LINK_COMPONENTS
  MC
  GArchInfo
  Support

  ADD_TO_COMPONENT
  GArch
  )

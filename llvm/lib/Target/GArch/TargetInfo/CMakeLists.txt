add_llvm_component_library(LLVMGArchInfo
  GArchTargetInfo.cpp

  LINK_COMPONENTS
  Support

  ADD_TO_COMPONENT
  GArch
  )

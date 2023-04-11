//===-- RISCVInstrInfo.td - Target Description for RISCV ---*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the RISC-V instructions in TableGen format.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// RISC-V specific DAG Nodes.
//===----------------------------------------------------------------------===//

// Target-independent type requirements, but with target-specific formats.
def SDT_CallSeqStart : SDCallSeqStart<[SDTCisVT<0, i32>,
                                       SDTCisVT<1, i32>]>;
def SDT_CallSeqEnd   : SDCallSeqEnd<[SDTCisVT<0, i32>,
                                     SDTCisVT<1, i32>]>;

// Target-dependent type requirements.
def SDT_RISCVCall     : SDTypeProfile<0, -1, [SDTCisVT<0, XLenVT>]>;
def SDT_RISCVSelectCC : SDTypeProfile<1, 5, [SDTCisSameAs<1, 2>,
                                             SDTCisVT<3, OtherVT>,
                                             SDTCisSameAs<0, 4>,
                                             SDTCisSameAs<4, 5>]>;
def SDT_RISCVBrCC : SDTypeProfile<0, 4, [SDTCisSameAs<0, 1>,
                                         SDTCisVT<2, OtherVT>,
                                         SDTCisVT<3, OtherVT>]>;
def SDT_RISCVReadCSR  : SDTypeProfile<1, 1, [SDTCisInt<0>, SDTCisInt<1>]>;
def SDT_RISCVWriteCSR : SDTypeProfile<0, 2, [SDTCisInt<0>, SDTCisInt<1>]>;
def SDT_RISCVSwapCSR  : SDTypeProfile<1, 2, [SDTCisInt<0>, SDTCisInt<1>,
                                             SDTCisInt<2>]>;
def SDT_RISCVReadCycleWide : SDTypeProfile<2, 0, [SDTCisVT<0, i32>,
                                                  SDTCisVT<1, i32>]>;
def SDT_RISCVIntUnaryOpW : SDTypeProfile<1, 1, [
  SDTCisSameAs<0, 1>, SDTCisVT<0, i64>
]>;
def SDT_RISCVIntBinOpW : SDTypeProfile<1, 2, [
  SDTCisSameAs<0, 1>, SDTCisSameAs<0, 2>, SDTCisVT<0, i64>
]>;
def SDT_RISCVIntShiftDOpW : SDTypeProfile<1, 3, [
  SDTCisSameAs<0, 1>, SDTCisSameAs<0, 2>, SDTCisVT<0, i64>, SDTCisVT<3, i64>
]>;

// Target-independent nodes, but with target-specific formats.
def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_CallSeqStart,
                           [SDNPHasChain, SDNPOutGlue]>;
def callseq_end   : SDNode<"ISD::CALLSEQ_END", SDT_CallSeqEnd,
                           [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

// Target-dependent nodes.
def riscv_call      : SDNode<"RISCVISD::CALL", SDT_RISCVCall,
                             [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                              SDNPVariadic]>;
def riscv_ret_flag  : SDNode<"RISCVISD::RET_FLAG", SDTNone,
                             [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;
def riscv_uret_flag : SDNode<"RISCVISD::URET_FLAG", SDTNone,
                             [SDNPHasChain, SDNPOptInGlue]>;
def riscv_sret_flag : SDNode<"RISCVISD::SRET_FLAG", SDTNone,
                             [SDNPHasChain, SDNPOptInGlue]>;
def riscv_mret_flag : SDNode<"RISCVISD::MRET_FLAG", SDTNone,
                             [SDNPHasChain, SDNPOptInGlue]>;
def riscv_selectcc  : SDNode<"RISCVISD::SELECT_CC", SDT_RISCVSelectCC>;
def riscv_brcc      : SDNode<"RISCVISD::BR_CC", SDT_RISCVBrCC,
                             [SDNPHasChain]>;
def riscv_tail      : SDNode<"RISCVISD::TAIL", SDT_RISCVCall,
                             [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                              SDNPVariadic]>;
def riscv_sllw      : SDNode<"RISCVISD::SLLW", SDT_RISCVIntBinOpW>;
def riscv_sraw      : SDNode<"RISCVISD::SRAW", SDT_RISCVIntBinOpW>;
def riscv_srlw      : SDNode<"RISCVISD::SRLW", SDT_RISCVIntBinOpW>;
def riscv_read_csr  : SDNode<"RISCVISD::READ_CSR", SDT_RISCVReadCSR,
                             [SDNPHasChain]>;
def riscv_write_csr : SDNode<"RISCVISD::WRITE_CSR", SDT_RISCVWriteCSR,
                             [SDNPHasChain]>;
def riscv_swap_csr  : SDNode<"RISCVISD::SWAP_CSR", SDT_RISCVSwapCSR,
                             [SDNPHasChain]>;

def riscv_read_cycle_wide : SDNode<"RISCVISD::READ_CYCLE_WIDE",
                                   SDT_RISCVReadCycleWide,
                                   [SDNPHasChain, SDNPSideEffect]>;

def riscv_add_lo : SDNode<"RISCVISD::ADD_LO", SDTIntBinOp>;
def riscv_hi : SDNode<"RISCVISD::HI", SDTIntUnaryOp>;
def riscv_lla : SDNode<"RISCVISD::LLA", SDTIntUnaryOp>;
def riscv_add_tprel : SDNode<"RISCVISD::ADD_TPREL",
                             SDTypeProfile<1, 3, [SDTCisSameAs<0, 1>,
                                                  SDTCisSameAs<0, 2>,
                                                  SDTCisSameAs<0, 3>,
                                                  SDTCisInt<0>]>>;

def riscv_la : SDNode<"RISCVISD::LA", SDTLoad,
                      [SDNPHasChain, SDNPMayLoad, SDNPMemOperand]>;
def riscv_la_tls_ie : SDNode<"RISCVISD::LA_TLS_IE", SDTLoad,
                             [SDNPHasChain, SDNPMayLoad, SDNPMemOperand]>;
def riscv_la_tls_gd : SDNode<"RISCVISD::LA_TLS_GD", SDTIntUnaryOp>;

//===----------------------------------------------------------------------===//
// Operand and SDNode transformation definitions.
//===----------------------------------------------------------------------===//

class ImmXLenAsmOperand<string prefix, string suffix = ""> : AsmOperandClass {
  let Name = prefix # "ImmXLen" # suffix;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

class ImmAsmOperand<string prefix, int width, string suffix> : AsmOperandClass {
  let Name = prefix # "Imm" # width # suffix;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

def ImmZeroAsmOperand : AsmOperandClass {
  let Name = "ImmZero";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

// A parse method for (${gpr}) or 0(${gpr}), where the 0 is be silently ignored.
def ZeroOffsetMemOpOperand : AsmOperandClass {
  let Name = "ZeroOffsetMemOpOperand";
  let RenderMethod = "addRegOperands";
  let PredicateMethod = "isGPR";
  let ParserMethod = "parseZeroOffsetMemOp";
}

def GPRMemZeroOffset : RegisterOperand<GPR> {
  let ParserMatchClass = ZeroOffsetMemOpOperand;
  let PrintMethod = "printZeroOffsetMemOp";
}

class SImmAsmOperand<int width, string suffix = "">
    : ImmAsmOperand<"S", width, suffix> {
}

class UImmAsmOperand<int width, string suffix = "">
    : ImmAsmOperand<"U", width, suffix> {
}

def FenceArg : AsmOperandClass {
  let Name = "FenceArg";
  let RenderMethod = "addFenceArgOperands";
  let DiagnosticType = "InvalidFenceArg";
}

def fencearg : Operand<XLenVT> {
  let ParserMatchClass = FenceArg;
  let PrintMethod = "printFenceArg";
  let DecoderMethod = "decodeUImmOperand<4>";
  //let OperandType = "OPERAND_UIMM4";
  //let OperandNamespace = "RISCVOp";
}

def UImmLog2XLenAsmOperand : AsmOperandClass {
  let Name = "UImmLog2XLen";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidUImmLog2XLen";
}

def uimmlog2xlen : Operand<XLenVT>, ImmLeaf<XLenVT, [{
  if (Subtarget->is64Bit())
    return isUInt<6>(Imm);
  return isUInt<5>(Imm);
}]> {
  let ParserMatchClass = UImmLog2XLenAsmOperand;
  // TODO: should ensure invalid shamt is rejected when decoding.
  let DecoderMethod = "decodeUImmOperand<6>";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (!MCOp.evaluateAsConstantImm(Imm))
      return false;
    if (STI.getTargetTriple().isArch64Bit())
      return isUInt<6>(Imm);
    return isUInt<5>(Imm);
  }];
  //let OperandType = "OPERAND_UIMMLOG2XLEN";
  //let OperandNamespace = "RISCVOp";
}

def uimm2 : Operand<XLenVT> {
  let ParserMatchClass = UImmAsmOperand<2>;
  let DecoderMethod = "decodeUImmOperand<2>";
  //let OperandType = "OPERAND_UIMM2";
  //let OperandNamespace = "RISCVOp";
}

def uimm3 : Operand<XLenVT> {
  let ParserMatchClass = UImmAsmOperand<3>;
  let DecoderMethod = "decodeUImmOperand<3>";
  //let OperandType = "OPERAND_UIMM3";
  //let OperandNamespace = "RISCVOp";
}

def uimm5 : Operand<XLenVT>, ImmLeaf<XLenVT, [{return isUInt<5>(Imm);}]> {
  let ParserMatchClass = UImmAsmOperand<5>;
  let DecoderMethod = "decodeUImmOperand<5>";
  //let OperandType = "OPERAND_UIMM5";
  //let OperandNamespace = "RISCVOp";
}

def InsnDirectiveOpcode : AsmOperandClass {
  let Name = "InsnDirectiveOpcode";
  let ParserMethod = "parseInsnDirectiveOpcode";
  let RenderMethod = "addImmOperands";
  let PredicateMethod = "isImm";
}

def uimm7_opcode : Operand<XLenVT> {
  let ParserMatchClass = InsnDirectiveOpcode;
  let DecoderMethod = "decodeUImmOperand<7>";
  //let OperandType = "OPERAND_UIMM7";
  //let OperandNamespace = "RISCVOp";
}

def uimm7 : Operand<XLenVT> {
  let ParserMatchClass = UImmAsmOperand<7>;
  let DecoderMethod = "decodeUImmOperand<7>";
  //let OperandType = "OPERAND_UIMM7";
  //let OperandNamespace = "RISCVOp";
}

def simm12 : Operand<XLenVT>, ImmLeaf<XLenVT, [{return isInt<12>(Imm);}]> {
  let ParserMatchClass = SImmAsmOperand<12>;
  let EncoderMethod = "getImmOpValue";
  let DecoderMethod = "decodeSImmOperand<12>";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isInt<12>(Imm);
    return MCOp.isBareSymbolRef();
  }];
  //let OperandType = "OPERAND_SIMM12";
  //let OperandNamespace = "RISCVOp";
}

// // A 13-bit signed immediate where the least significant bit is zero.
def simm13_lsb0 : Operand<OtherVT> {
  let ParserMatchClass = SImmAsmOperand<13, "Lsb0">;
  let PrintMethod = "printBranchOperand";
  let EncoderMethod = "getImmOpValueAsr1";
  let DecoderMethod = "decodeSImmOperandAndLsl1<13>";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isShiftedInt<12, 1>(Imm);
    return MCOp.isBareSymbolRef();
  }];
  //let OperandType = "OPERAND_PCREL";
}

class UImm20Operand : Operand<XLenVT> {
  let EncoderMethod = "getImmOpValue";
  let DecoderMethod = "decodeUImmOperand<20>";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isUInt<20>(Imm);
    return MCOp.isBareSymbolRef();
  }];
  //let OperandType = "OPERAND_UIMM20";
  //let OperandNamespace = "RISCVOp";
}

def uimm20_lui : UImm20Operand {
  let ParserMatchClass = UImmAsmOperand<20, "LUI">;
}
def uimm20_auipc : UImm20Operand {
  let ParserMatchClass = UImmAsmOperand<20, "AUIPC">;
}

def Simm21Lsb0JALAsmOperand : SImmAsmOperand<21, "Lsb0JAL"> {
  let ParserMethod = "parseJALOffset";
}

// A 21-bit signed immediate where the least significant bit is zero.
def simm21_lsb0_jal : Operand<OtherVT> {
  let ParserMatchClass = Simm21Lsb0JALAsmOperand;
  let PrintMethod = "printBranchOperand";
  let EncoderMethod = "getImmOpValueAsr1";
  let DecoderMethod = "decodeSImmOperandAndLsl1<21>";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isShiftedInt<20, 1>(Imm);
    return MCOp.isBareSymbolRef();
  }];
  //let OperandType = "OPERAND_PCREL";
}

def BareSymbol : AsmOperandClass {
  let Name = "BareSymbol";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidBareSymbol";
  let ParserMethod = "parseBareSymbol";
}

// A bare symbol.
def bare_symbol : Operand<XLenVT> {
  let ParserMatchClass = BareSymbol;
}

def CallSymbol : AsmOperandClass {
  let Name = "CallSymbol";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidCallSymbol";
  let ParserMethod = "parseCallSymbol";
}

// A bare symbol used in call/tail only.
def call_symbol : Operand<XLenVT> {
  let ParserMatchClass = CallSymbol;
}

def PseudoJumpSymbol : AsmOperandClass {
  let Name = "PseudoJumpSymbol";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidPseudoJumpSymbol";
  let ParserMethod = "parsePseudoJumpSymbol";
}

// A bare symbol used for pseudo jumps only.
def pseudo_jump_symbol : Operand<XLenVT> {
  let ParserMatchClass = PseudoJumpSymbol;
}

def TPRelAddSymbol : AsmOperandClass {
  let Name = "TPRelAddSymbol";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidTPRelAddSymbol";
  let ParserMethod = "parseOperandWithModifier";
}

// A bare symbol with the %tprel_add variant.
def tprel_add_symbol : Operand<XLenVT> {
  let ParserMatchClass = TPRelAddSymbol;
}

def CSRSystemRegister : AsmOperandClass {
  let Name = "CSRSystemRegister";
  let ParserMethod = "parseCSRSystemRegister";
  let DiagnosticType = "InvalidCSRSystemRegister";
}

def csr_sysreg : Operand<XLenVT> {
  let ParserMatchClass = CSRSystemRegister;
  let PrintMethod = "printCSRSystemRegister";
  let DecoderMethod = "decodeUImmOperand<12>";
  //let OperandType = "OPERAND_UIMM12";
  //let OperandNamespace = "RISCVOp";
}

// A parameterized register class alternative to i32imm/i64imm from Target.td.
def ixlenimm : Operand<XLenVT>;

def ixlenimm_li : Operand<XLenVT> {
  let ParserMatchClass = ImmXLenAsmOperand<"", "LI">;
}

// Standalone (codegen-only) immleaf patterns.

// A 12-bit signed immediate plus one where the imm range will be [-2047, 2048].
def simm12_plus1 : ImmLeaf<XLenVT,
  [{return (isInt<12>(Imm) && Imm != -2048) || Imm == 2048;}]>;

// A 12-bit signed immediate sub one and exclude zero
def simm12_minus1_nonzero : PatLeaf<(imm), [{
  if (!N->hasOneUse())
    return false;
  // The immediate operand must be in range [-2049, 0) or (0, 2046].
  int64_t Imm = N->getSExtValue();
  return (Imm >= -2049 && Imm < 0) || (Imm > 0 && Imm <= 2046);
}]>;

// A 6-bit constant greater than 32.
def uimm6gt32 : ImmLeaf<XLenVT, [{
  return isUInt<6>(Imm) && Imm > 32;
}]>;

// Addressing modes.
// Necessary because a frameindex can't be matched directly in a pattern.
def FrameAddrRegImm : ComplexPattern<iPTR, 2, "SelectFrameAddrRegImm",
                                     [frameindex, or, add]>;
def AddrRegImm : ComplexPattern<iPTR, 2, "SelectAddrRegImm">;

// Return the negation of an immediate value.
def NegImm : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(-N->getSExtValue(), SDLoc(N),
                                   N->getValueType(0));
}]>;

// Return an immediate value minus 32.
def ImmSub32 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getSExtValue() - 32, SDLoc(N),
                                   N->getValueType(0));
}]>;

// Return an immediate value plus 1.
def ImmPlus1 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getSExtValue() + 1, SDLoc(N),
                                   N->getValueType(0));
}]>;

// Return an immediate subtracted from XLen.
def ImmSubFromXLen : SDNodeXForm<imm, [{
  uint64_t XLen = Subtarget->getXLen();
  return CurDAG->getTargetConstant(XLen - N->getZExtValue(), SDLoc(N),
                                   N->getValueType(0));
}]>;

// Return an immediate subtracted from 32.
def ImmSubFrom32 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(32 - N->getZExtValue(), SDLoc(N),
                                   N->getValueType(0));
}]>;

// Check if (add r, imm) can be optimized to (ADDI (ADDI r, imm0), imm1),
// in which imm = imm0 + imm1 and both imm0 and imm1 are simm12. We make imm0
// as large as possible and imm1 as small as possible so that we might be able
// to use c.addi for the small immediate.
def AddiPair : PatLeaf<(imm), [{
  if (!N->hasOneUse())
    return false;
  // The immediate operand must be in range [-4096,-2049] or [2048,4094].
  int64_t Imm = N->getSExtValue();
  return (-4096 <= Imm && Imm <= -2049) || (2048 <= Imm && Imm <= 4094);
}]>;

// Return imm - (imm < 0 ? -2048 : 2047).
def AddiPairImmSmall : SDNodeXForm<imm, [{
  int64_t Imm = N->getSExtValue();
  int64_t Adj = N->getSExtValue() < 0 ? -2048 : 2047;
  return CurDAG->getTargetConstant(Imm - Adj, SDLoc(N),
                                   N->getValueType(0));
}]>;

// Return -2048 if immediate is negative or 2047 if positive. These are the
// largest simm12 values.
def AddiPairImmLarge : SDNodeXForm<imm, [{
  int64_t Imm = N->getSExtValue() < 0 ? -2048 : 2047;
  return CurDAG->getTargetConstant(Imm, SDLoc(N),
                                   N->getValueType(0));
}]>;

def TrailingZeros : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getAPIntValue().countTrailingZeros(),
                                   SDLoc(N), N->getValueType(0));
}]>;

def XLenSubTrailingOnes : SDNodeXForm<imm, [{
  uint64_t XLen = Subtarget->getXLen();
  uint64_t TrailingOnes = N->getAPIntValue().countTrailingOnes();
  return CurDAG->getTargetConstant(XLen - TrailingOnes, SDLoc(N),
                                   N->getValueType(0));
}]>;

// Checks if this mask is a non-empty sequence of ones starting at the
// most/least significant bit with the remainder zero and exceeds simm32/simm12.
def LeadingOnesMask : PatLeaf<(imm), [{
  if (!N->hasOneUse())
    return false;
  return !isInt<32>(N->getSExtValue()) && isMask_64(~N->getSExtValue());
}], TrailingZeros>;

def TrailingOnesMask : PatLeaf<(imm), [{
  if (!N->hasOneUse())
    return false;
  return !isInt<12>(N->getSExtValue()) && isMask_64(N->getZExtValue());
}], XLenSubTrailingOnes>;

//===----------------------------------------------------------------------===//
// Instruction Formats
//===----------------------------------------------------------------------===//

include "GArchInstrFormats.td"

//===----------------------------------------------------------------------===//
// Instruction Class Templates
//===----------------------------------------------------------------------===//

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class BranchCC_rri<bits<3> funct3, string opcodestr>
    : RVInstB<funct3, OPC_BRANCH, (outs),
              (ins GPR:$rs1, GPR:$rs2, simm13_lsb0:$imm12),
              opcodestr, "$rs1, $rs2, $imm12">,
      Sched<[]> {
  let isBranch = 1;
  let isTerminator = 1;
}

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in {
class Load_ri<bits<3> funct3, string opcodestr>
    : RVInstI<funct3, OPC_LOAD, (outs GPR:$rd), (ins GPR:$rs1, simm12:$imm12),
              opcodestr, "$rd, ${imm12}(${rs1})">;

class HLoad_r<bits<7> funct7, bits<5> funct5, string opcodestr>
    : RVInstR<funct7, 0b100, OPC_SYSTEM, (outs GPR:$rd),
              (ins GPRMemZeroOffset:$rs1), opcodestr, "$rd, $rs1"> {
  let rs2 = funct5;
}
}

// Operands for stores are in the order srcreg, base, offset rather than
// reflecting the order these fields are specified in the instruction
// encoding.
let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in {
class Store_rri<bits<3> funct3, string opcodestr>
    : RVInstS<funct3, OPC_STORE, (outs),
              (ins GPR:$rs2, GPR:$rs1, simm12:$imm12),
              opcodestr, "$rs2, ${imm12}(${rs1})">;

class HStore_rr<bits<7> funct7, string opcodestr>
    : RVInstR<funct7, 0b100, OPC_SYSTEM, (outs),
              (ins GPR:$rs2, GPRMemZeroOffset:$rs1),
               opcodestr, "$rs2, $rs1"> {
  let rd = 0;
}
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ALU_ri<bits<3> funct3, string opcodestr>
    : RVInstI<funct3, OPC_OP_IMM, (outs GPR:$rd), (ins GPR:$rs1, simm12:$imm12),
              opcodestr, "$rd, $rs1, $imm12">,
      Sched<[]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class Shift_ri<bits<5> imm11_7, bits<3> funct3, string opcodestr>
    : RVInstIShift<imm11_7, funct3, OPC_OP_IMM, (outs GPR:$rd),
                   (ins GPR:$rs1, uimmlog2xlen:$shamt), opcodestr,
                   "$rd, $rs1, $shamt">,
      Sched<[]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ALU_rr<bits<7> funct7, bits<3> funct3, string opcodestr,
             bit Commutable = 0>
    : RVInstR<funct7, funct3, OPC_OP, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
              opcodestr, "$rd, $rs1, $rs2"> {
  let isCommutable = Commutable;
}

let hasNoSchedulingInfo = 1,
    hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
class CSR_ir<bits<3> funct3, string opcodestr>
    : RVInstI<funct3, OPC_SYSTEM, (outs GPR:$rd), (ins csr_sysreg:$imm12, GPR:$rs1),
              opcodestr, "$rd, $imm12, $rs1">, Sched<[]>;

let hasNoSchedulingInfo = 1,
    hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
class CSR_ii<bits<3> funct3, string opcodestr>
    : RVInstI<funct3, OPC_SYSTEM, (outs GPR:$rd),
              (ins csr_sysreg:$imm12, uimm5:$rs1),
              opcodestr, "$rd, $imm12, $rs1">, Sched<[]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ShiftW_ri<bits<7> imm11_5, bits<3> funct3, string opcodestr>
    : RVInstIShiftW<imm11_5, funct3, OPC_OP_IMM_32, (outs GPR:$rd),
                    (ins GPR:$rs1, uimm5:$shamt), opcodestr,
                    "$rd, $rs1, $shamt">,
      Sched<[]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ALUW_rr<bits<7> funct7, bits<3> funct3, string opcodestr,
              bit Commutable = 0>
    : RVInstR<funct7, funct3, OPC_OP_32, (outs GPR:$rd),
              (ins GPR:$rs1, GPR:$rs2), opcodestr, "$rd, $rs1, $rs2"> {
  let isCommutable = Commutable;
}

let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
class Priv<string opcodestr, bits<7> funct7>
    : RVInstR<funct7, 0b000, OPC_SYSTEM, (outs), (ins GPR:$rs1, GPR:$rs2),
              opcodestr, "">;

let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
class Priv_rr<string opcodestr, bits<7> funct7>
    : RVInstR<funct7, 0b000, OPC_SYSTEM, (outs), (ins GPR:$rs1, GPR:$rs2),
              opcodestr, "$rs1, $rs2"> {
  let rd = 0;
}

//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//

def OPC_GRAPH      : RISCVOpcode<"GRAPH",      0b0001011>;
def GINIT : RVInstR<0b0000000, 0b000, OPC_GRAPH, (outs), 
                (ins GPR:$rs1, GPR:$rs2), "ginit", "%rs1, $rs2">;
def GPUT_PIXEL : RVInstR<0b0000000, 0b001, OPC_GRAPH, (outs), 
                (ins GPR:$rs1, GPR:$rs2, GPR:$rd), "gput_pixel", "$rd, %rs1, $rs2">;
def GWIS_OPEN : RVInstR<0b0000000, 0b010, OPC_GRAPH, (outs GPR:$rd), 
                (ins), "gwis_open", "$rd">;
def GTIME : RVInstR<0b0000000, 0b011, OPC_GRAPH, (outs GPR:$rd), 
                (ins), "gtime", "$rd">;
def GFLUSH : RVInstR<0b0000000, 0b100, OPC_GRAPH, (outs), 
                (ins), "gflush", "">;


let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
let isReMaterializable = 1, isAsCheapAsAMove = 1 in
def LUI : RVInstU<OPC_LUI, (outs GPR:$rd), (ins uimm20_lui:$imm20),
                  "lui", "$rd, $imm20">, Sched<[]>;

def AUIPC : RVInstU<OPC_AUIPC, (outs GPR:$rd), (ins uimm20_auipc:$imm20),
                    "auipc", "$rd, $imm20">, Sched<[]>;

let isCall = 1 in
def JAL : RVInstJ<OPC_JAL, (outs GPR:$rd), (ins simm21_lsb0_jal:$imm20),
                  "jal", "$rd, $imm20">, Sched<[]>;

let isCall = 1 in
def JALR : RVInstI<0b000, OPC_JALR, (outs GPR:$rd),
                   (ins GPR:$rs1, simm12:$imm12),
                   "jalr", "$rd, ${imm12}(${rs1})">,
           Sched<[]>;
} // hasSideEffects = 0, mayLoad = 0, mayStore = 0

def BEQ  : BranchCC_rri<0b000, "beq">;
def BNE  : BranchCC_rri<0b001, "bne">;
def BLT  : BranchCC_rri<0b100, "blt">;
def BGE  : BranchCC_rri<0b101, "bge">;
def BLTU : BranchCC_rri<0b110, "bltu">;
def BGEU : BranchCC_rri<0b111, "bgeu">;

def LB  : Load_ri<0b000, "lb">, Sched<[]>;
def LH  : Load_ri<0b001, "lh">, Sched<[]>;
def LW  : Load_ri<0b010, "lw">, Sched<[]>;
def LBU : Load_ri<0b100, "lbu">, Sched<[]>;
def LHU : Load_ri<0b101, "lhu">, Sched<[]>;

def SB : Store_rri<0b000, "sb">, Sched<[]>;
def SH : Store_rri<0b001, "sh">, Sched<[]>;
def SW : Store_rri<0b010, "sw">, Sched<[]>;

// ADDI isn't always rematerializable, but isReMaterializable will be used as
// a hint which is verified in isReallyTriviallyReMaterializable.
let isReMaterializable = 1, isAsCheapAsAMove = 1 in
def ADDI  : ALU_ri<0b000, "addi">;

def SLTI  : ALU_ri<0b010, "slti">;
def SLTIU : ALU_ri<0b011, "sltiu">;

let isReMaterializable = 1, isAsCheapAsAMove = 1 in {
def XORI  : ALU_ri<0b100, "xori">;
def ORI   : ALU_ri<0b110, "ori">;
}

def ANDI  : ALU_ri<0b111, "andi">;

def SLLI : Shift_ri<0b00000, 0b001, "slli">;
def SRLI : Shift_ri<0b00000, 0b101, "srli">;
def SRAI : Shift_ri<0b01000, 0b101, "srai">;

def ADD  : ALU_rr<0b0000000, 0b000, "add", /*Commutable*/1>,
           Sched<[]>;
def SUB  : ALU_rr<0b0100000, 0b000, "sub">,
           Sched<[]>;
def SLL  : ALU_rr<0b0000000, 0b001, "sll">,
           Sched<[]>;
def SLT  : ALU_rr<0b0000000, 0b010, "slt">,
           Sched<[]>;
def SLTU : ALU_rr<0b0000000, 0b011, "sltu">,
           Sched<[]>;
def XOR  : ALU_rr<0b0000000, 0b100, "xor", /*Commutable*/1>,
           Sched<[]>;
def SRL  : ALU_rr<0b0000000, 0b101, "srl">,
           Sched<[]>;
def SRA  : ALU_rr<0b0100000, 0b101, "sra">,
           Sched<[]>;
def OR   : ALU_rr<0b0000000, 0b110, "or", /*Commutable*/1>,
           Sched<[]>;
def AND  : ALU_rr<0b0000000, 0b111, "and", /*Commutable*/1>,
           Sched<[]>;

let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in {
def FENCE : RVInstI<0b000, OPC_MISC_MEM, (outs),
                    (ins fencearg:$pred, fencearg:$succ),
                    "fence", "$pred, $succ">, Sched<[]> {
  bits<4> pred;
  bits<4> succ;

  let rs1 = 0;
  let rd = 0;
  let imm12 = {0b0000,pred,succ};
}

def FENCE_TSO : RVInstI<0b000, OPC_MISC_MEM, (outs), (ins), "fence.tso", "">, Sched<[]> {
  let rs1 = 0;
  let rd = 0;
  let imm12 = {0b1000,0b0011,0b0011};
}

def FENCE_I : RVInstI<0b001, OPC_MISC_MEM, (outs), (ins), "fence.i", "">, Sched<[]> {
  let rs1 = 0;
  let rd = 0;
  let imm12 = 0;
}

def ECALL : RVInstI<0b000, OPC_SYSTEM, (outs), (ins), "ecall", "">, Sched<[]> {
  let rs1 = 0;
  let rd = 0;
  let imm12 = 0;
}

def EBREAK : RVInstI<0b000, OPC_SYSTEM, (outs), (ins), "ebreak", "">,
             Sched<[]> {
  let rs1 = 0;
  let rd = 0;
  let imm12 = 1;
}

// This is a de facto standard (as set by GNU binutils) 32-bit unimplemented
// instruction (i.e., it should always trap, if your implementation has invalid
// instruction traps).
def UNIMP : RVInstI<0b001, OPC_SYSTEM, (outs), (ins), "unimp", "">,
            Sched<[]> {
  let rs1 = 0;
  let rd = 0;
  let imm12 = 0b110000000000;
}
} // hasSideEffects = 1, mayLoad = 0, mayStore = 0

def CSRRW : CSR_ir<0b001, "csrrw">;
def CSRRS : CSR_ir<0b010, "csrrs">;
def CSRRC : CSR_ir<0b011, "csrrc">;

def CSRRWI : CSR_ii<0b101, "csrrwi">;
def CSRRSI : CSR_ii<0b110, "csrrsi">;
def CSRRCI : CSR_ii<0b111, "csrrci">;

/// RV64I instructions

let Predicates = [IsRV64] in {
def LWU   : Load_ri<0b110, "lwu">, Sched<[]>;
def LD    : Load_ri<0b011, "ld">, Sched<[]>;
def SD    : Store_rri<0b011, "sd">, Sched<[]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def ADDIW : RVInstI<0b000, OPC_OP_IMM_32, (outs GPR:$rd),
                    (ins GPR:$rs1, simm12:$imm12),
                    "addiw", "$rd, $rs1, $imm12">,
            Sched<[]>;

def SLLIW : ShiftW_ri<0b0000000, 0b001, "slliw">;
def SRLIW : ShiftW_ri<0b0000000, 0b101, "srliw">;
def SRAIW : ShiftW_ri<0b0100000, 0b101, "sraiw">;

def ADDW  : ALUW_rr<0b0000000, 0b000, "addw", /*Commutable*/1>,
            Sched<[]>;
def SUBW  : ALUW_rr<0b0100000, 0b000, "subw">,
            Sched<[]>;
def SLLW  : ALUW_rr<0b0000000, 0b001, "sllw">,
            Sched<[]>;
def SRLW  : ALUW_rr<0b0000000, 0b101, "srlw">,
            Sched<[]>;
def SRAW  : ALUW_rr<0b0100000, 0b101, "sraw">,
            Sched<[]>;
} // Predicates = [IsRV64]

//===----------------------------------------------------------------------===//
// Privileged instructions
//===----------------------------------------------------------------------===//

let isBarrier = 1, isReturn = 1, isTerminator = 1 in {
def URET : Priv<"uret", 0b0000000>, Sched<[]> {
  let rd = 0;
  let rs1 = 0;
  let rs2 = 0b00010;
}

def SRET : Priv<"sret", 0b0001000>, Sched<[]> {
  let rd = 0;
  let rs1 = 0;
  let rs2 = 0b00010;
}

def MRET : Priv<"mret", 0b0011000>, Sched<[]> {
  let rd = 0;
  let rs1 = 0;
  let rs2 = 0b00010;
}
} // isBarrier = 1, isReturn = 1, isTerminator = 1

def WFI : Priv<"wfi", 0b0001000>, Sched<[]> {
  let rd = 0;
  let rs1 = 0;
  let rs2 = 0b00101;
}

def SFENCE_W_INVAL : Priv<"sfence.w.inval", 0b0001100>, Sched<[]> {
  let rd = 0;
  let rs1 = 0;
  let rs2 = 0;
}

def SFENCE_INVAL_IR : Priv<"sfence.inval.ir", 0b0001100>, Sched<[]> {
  let rd = 0;
  let rs1 = 0;
  let rs2 = 0b00001;
}

def SFENCE_VMA  : Priv_rr<"sfence.vma", 0b0001001>, Sched<[]>;
def SINVAL_VMA  : Priv_rr<"sinval.vma", 0b0001011>, Sched<[]>;
def HFENCE_VVMA : Priv_rr<"hfence.vvma", 0b0010001>, Sched<[]>;
def HFENCE_GVMA : Priv_rr<"hfence.gvma", 0b0110001>, Sched<[]>;
def HINVAL_VVMA : Priv_rr<"hinval.vvma", 0b0010011>, Sched<[]>;
def HINVAL_GVMA : Priv_rr<"hinval.gvma", 0b0110011>, Sched<[]>;

def HLV_B   : HLoad_r<0b0110000, 0b00000, "hlv.b">, Sched<[]>;
def HLV_BU  : HLoad_r<0b0110000, 0b00001, "hlv.bu">, Sched<[]>;
def HLV_H   : HLoad_r<0b0110010, 0b00000, "hlv.h">, Sched<[]>;
def HLV_HU  : HLoad_r<0b0110010, 0b00001, "hlv.hu">, Sched<[]>;
def HLVX_HU : HLoad_r<0b0110010, 0b00011, "hlvx.hu">, Sched<[]>;
def HLV_W   : HLoad_r<0b0110100, 0b00000, "hlv.w">, Sched<[]>;
def HLVX_WU : HLoad_r<0b0110100, 0b00011, "hlvx.wu">, Sched<[]>;
def HSV_B   : HStore_rr<0b0110001, "hsv.b">, Sched<[]>;
def HSV_H   : HStore_rr<0b0110011, "hsv.h">, Sched<[]>;
def HSV_W   : HStore_rr<0b0110101, "hsv.w">, Sched<[]>;

let Predicates = [IsRV64] in {
def HLV_WU  : HLoad_r<0b0110100, 0b00001, "hlv.wu">, Sched<[]>;
def HLV_D   : HLoad_r<0b0110110, 0b00000, "hlv.d">, Sched<[]>;
def HSV_D   : HStore_rr<0b0110111, "hsv.d">, Sched<[]>;
}

//===----------------------------------------------------------------------===//
// Debug instructions
//===----------------------------------------------------------------------===//

let isBarrier = 1, isReturn = 1, isTerminator = 1 in {
def DRET : Priv<"dret", 0b0111101>, Sched<[]> {
  let rd = 0;
  let rs1 = 0;
  let rs2 = 0b10010;
}
} // isBarrier = 1, isReturn = 1, isTerminator = 1

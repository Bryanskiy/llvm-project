//===----------------------------------------------------------------------===//
//
// This file contains the sim implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Instruction Formats
//===----------------------------------------------------------------------===//
include "simInstrFormats.td"

//===----------------------------------------------------------------------===//
// sim specific DAG Nodes.
//===----------------------------------------------------------------------===//

// Target-independent type requirements, but with target-specific formats.
def SDT_CallSeqStart : SDCallSeqStart<[SDTCisVT<0, i32>,
                                       SDTCisVT<1, i32>]>;
def SDT_CallSeqEnd   : SDCallSeqEnd<[SDTCisVT<0, i32>,
                                     SDTCisVT<1, i32>]>;

// Target-dependent type requirements.
def SDT_simCall     : SDTypeProfile<0, -1, [SDTCisVT<0, XLenVT>]>;
def SDT_simSelectCC : SDTypeProfile<1, 5, [SDTCisSameAs<1, 2>,
                                             SDTCisVT<3, OtherVT>,
                                             SDTCisSameAs<0, 4>,
                                             SDTCisSameAs<4, 5>]>;
def SDT_simBrCC : SDTypeProfile<0, 4, [SDTCisSameAs<0, 1>,
                                         SDTCisVT<2, OtherVT>,
                                         SDTCisVT<3, OtherVT>]>;
def SDT_simReadCSR  : SDTypeProfile<1, 1, [SDTCisInt<0>, SDTCisInt<1>]>;
def SDT_simWriteCSR : SDTypeProfile<0, 2, [SDTCisInt<0>, SDTCisInt<1>]>;
def SDT_simSwapCSR  : SDTypeProfile<1, 2, [SDTCisInt<0>, SDTCisInt<1>,
                                             SDTCisInt<2>]>;
def SDT_simReadCycleWide : SDTypeProfile<2, 0, [SDTCisVT<0, i32>,
                                                  SDTCisVT<1, i32>]>;
def SDT_simIntUnaryOpW : SDTypeProfile<1, 1, [
  SDTCisSameAs<0, 1>, SDTCisVT<0, i64>
]>;
def SDT_simIntBinOpW : SDTypeProfile<1, 2, [
  SDTCisSameAs<0, 1>, SDTCisSameAs<0, 2>, SDTCisVT<0, i64>
]>;
def SDT_simIntShiftDOpW : SDTypeProfile<1, 3, [
  SDTCisSameAs<0, 1>, SDTCisSameAs<0, 2>, SDTCisVT<0, i64>, SDTCisVT<3, i64>
]>;

// Target-independent nodes, but with target-specific formats.
def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_CallSeqStart,
                           [SDNPHasChain, SDNPOutGlue]>;
def callseq_end   : SDNode<"ISD::CALLSEQ_END", SDT_CallSeqEnd,
                           [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

// Target-dependent nodes.
def sim_call      : SDNode<"simISD::CALL", SDT_simCall,
                             [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                              SDNPVariadic]>;
def sim_ret_flag  : SDNode<"simISD::RET_FLAG", SDTNone,
                             [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;
def sim_uret_flag : SDNode<"simISD::URET_FLAG", SDTNone,
                             [SDNPHasChain, SDNPOptInGlue]>;
def sim_sret_flag : SDNode<"simISD::SRET_FLAG", SDTNone,
                             [SDNPHasChain, SDNPOptInGlue]>;
def sim_mret_flag : SDNode<"simISD::MRET_FLAG", SDTNone,
                             [SDNPHasChain, SDNPOptInGlue]>;
def sim_selectcc  : SDNode<"simISD::SELECT_CC", SDT_simSelectCC>;
def sim_brcc      : SDNode<"simISD::BR_CC", SDT_simBrCC,
                             [SDNPHasChain]>;
def sim_tail      : SDNode<"simISD::TAIL", SDT_simCall,
                             [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                              SDNPVariadic]>;
def sim_sllw      : SDNode<"simISD::SLLW", SDT_simIntBinOpW>;
def sim_sraw      : SDNode<"simISD::SRAW", SDT_simIntBinOpW>;
def sim_srlw      : SDNode<"simISD::SRLW", SDT_simIntBinOpW>;
def sim_read_csr  : SDNode<"simISD::READ_CSR", SDT_simReadCSR,
                             [SDNPHasChain]>;
def sim_write_csr : SDNode<"simISD::WRITE_CSR", SDT_simWriteCSR,
                             [SDNPHasChain]>;
def sim_swap_csr  : SDNode<"simISD::SWAP_CSR", SDT_simSwapCSR,
                             [SDNPHasChain]>;

def sim_read_cycle_wide : SDNode<"simISD::READ_CYCLE_WIDE",
                                   SDT_simReadCycleWide,
                                   [SDNPHasChain, SDNPSideEffect]>;

def sim_add_lo : SDNode<"simISD::ADD_LO", SDTIntBinOp>;
def sim_hi : SDNode<"simISD::HI", SDTIntUnaryOp>;
def sim_lla : SDNode<"simISD::LLA", SDTIntUnaryOp>;
def sim_add_tprel : SDNode<"simISD::ADD_TPREL",
                             SDTypeProfile<1, 3, [SDTCisSameAs<0, 1>,
                                                  SDTCisSameAs<0, 2>,
                                                  SDTCisSameAs<0, 3>,
                                                  SDTCisInt<0>]>>;

def sim_la : SDNode<"simISD::LA", SDTLoad,
                      [SDNPHasChain, SDNPMayLoad, SDNPMemOperand]>;
def sim_la_tls_ie : SDNode<"simISD::LA_TLS_IE", SDTLoad,
                             [SDNPHasChain, SDNPMayLoad, SDNPMemOperand]>;
def sim_la_tls_gd : SDNode<"simISD::LA_TLS_GD", SDTIntUnaryOp>;

//===----------------------------------------------------------------------===//
// Operand and SDNode transformation definitions.
//===----------------------------------------------------------------------===//

class ImmAsmOperand<string prefix, int width, string suffix> : AsmOperandClass {
  let Name = prefix # "Imm" # width # suffix;
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
  let OperandType = "OPERAND_SIMM12";
  let OperandNamespace = "simOp";
}

// A 13-bit signed immediate where the least significant bit is zero.
def simm13_lsb0 : Operand<OtherVT> {
  let ParserMatchClass = SImmAsmOperand<13, "Lsb0">;
  let PrintMethod = "printBranchOperand";
  let EncoderMethod = "getImmOpValueAsr1";
  let DecoderMethod = "decodeSImmOperandAndLsl1<13>";
  let OperandType = "OPERAND_PCREL";
}

//===----------------------------------------------------------------------===//RVInst
// Instruction Class Templates
//===----------------------------------------------------------------------===//

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class BranchCC_rri<bits<3> funct3, string opcodestr>
    : simInstB<funct3, OPC_BRANCH, (outs),
              (ins GPR:$rs1, GPR:$rs2, simm13_lsb0:$imm12),
              opcodestr, "$rs1, $rs2, $imm12">,
      Sched<[WriteJmp, ReadJmp, ReadJmp]> {
  let isBranch = 1;
  let isTerminator = 1;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ALU_ri<bits<3> funct3, string opcodestr>
    : simInstI<funct3, OPC_OP_IMM, (outs GPR:$rd), (ins GPR:$rs1, simm12:$imm12),
              opcodestr, "$rd, $rs1, $imm12">,
      Sched<[WriteIALU, ReadIALU]>;


let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in {
class Load_ri<bits<3> funct3, string opcodestr>
    : simInstI<funct3, OPC_LOAD, (outs GPR:$rd), (ins GPR:$rs1, simm12:$imm12),
              opcodestr, "$rd, ${imm12}(${rs1})">;

class HLoad_r<bits<7> funct7, bits<5> funct5, string opcodestr>
    : simInstR<funct7, 0b100, OPC_SYSTEM, (outs GPR:$rd),
              (ins GPRMemZeroOffset:$rs1), opcodestr, "$rd, $rs1"> {
  let rs2 = funct5;
}
}

// Operands for stores are in the order srcreg, base, offset rather than
// reflecting the order these fields are specified in the instruction
// encoding.
let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in {
class Store_rri<bits<3> funct3, string opcodestr>
    : simInstS<funct3, OPC_STORE, (outs),
              (ins GPR:$rs2, GPR:$rs1, simm12:$imm12),
              opcodestr, "$rs2, ${imm12}(${rs1})">;
}

//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//

def BEQ  : BranchCC_rri<0b000, "beq">;
def BNE  : BranchCC_rri<0b001, "bne">;
def BLT  : BranchCC_rri<0b100, "blt">;
def BGE  : BranchCC_rri<0b101, "bge">;
def BLTU : BranchCC_rri<0b110, "bltu">;
def BGEU : BranchCC_rri<0b111, "bgeu">;

def LB  : Load_ri<0b000, "lb">, Sched<[WriteLDB, ReadMemBase]>;
def LH  : Load_ri<0b001, "lh">, Sched<[WriteLDH, ReadMemBase]>;
def LW  : Load_ri<0b010, "lw">, Sched<[WriteLDW, ReadMemBase]>;
def LBU : Load_ri<0b100, "lbu">, Sched<[WriteLDB, ReadMemBase]>;
def LHU : Load_ri<0b101, "lhu">, Sched<[WriteLDH, ReadMemBase]>;

def SB : Store_rri<0b000, "sb">, Sched<[WriteSTB, ReadStoreData, ReadMemBase]>;
def SH : Store_rri<0b001, "sh">, Sched<[WriteSTH, ReadStoreData, ReadMemBase]>;
def SW : Store_rri<0b010, "sw">, Sched<[WriteSTW, ReadStoreData, ReadMemBase]>;


def ADDI  : ALU_ri<0b000, "addi">;

// Pessimistically assume the stack pointer will be clobbered
let Defs = [X2], Uses = [X2] in {
def ADJCALLSTACKDOWN : Pseudo<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                              [(callseq_start timm:$amt1, timm:$amt2)]>;
def ADJCALLSTACKUP   : Pseudo<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                              [(callseq_end timm:$amt1, timm:$amt2)]>;
} // Defs = [X2], Uses = [X2]
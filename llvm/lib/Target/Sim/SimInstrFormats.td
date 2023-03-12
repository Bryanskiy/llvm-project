//===-- SimInstrFormats.td - Sim Instruction Formats -----*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// Generic Sim Format
class InstFormat<bits<5> val> {
  bits<5> Value = val;
}

def InstFormatR      : InstFormat<0>;
def InstFormatI      : InstFormat<1>;
def InstFormatS      : InstFormat<2>;
def InstFormatB      : InstFormat<3>;
def InstFormatU      : InstFormat<4>;
def InstFormatJ      : InstFormat<5>;

// The following opcode names match those given in Table 19.1 in the
// RISC-V User-level ISA specification ("RISC-V base opcode map").
class SimOpcode<string name, bits<7> val> {
  string Name = name;
  bits<7> Value = val;
}

def OPC_LOAD      : SimOpcode<"LOAD",      0b0000011>;
def OPC_LOAD_FP   : SimOpcode<"LOAD_FP",   0b0000111>;
def OPC_CUSTOM_0  : SimOpcode<"CUSTOM_0",  0b0001011>;
def OPC_MISC_MEM  : SimOpcode<"MISC_MEM",  0b0001111>;
def OPC_OP_IMM    : SimOpcode<"OP_IMM",    0b0010011>;
def OPC_AUIPC     : SimOpcode<"AUIPC",     0b0010111>;
def OPC_OP_IMM_32 : SimOpcode<"OP_IMM_32", 0b0011011>;
def OPC_STORE     : SimOpcode<"STORE",     0b0100011>;
def OPC_STORE_FP  : SimOpcode<"STORE_FP",  0b0100111>;
def OPC_CUSTOM_1  : SimOpcode<"CUSTOM_1",  0b0101011>;
def OPC_AMO       : SimOpcode<"AMO",       0b0101111>;
def OPC_OP        : SimOpcode<"OP",        0b0110011>;
def OPC_LUI       : SimOpcode<"LUI",       0b0110111>;
def OPC_OP_32     : SimOpcode<"OP_32",     0b0111011>;
def OPC_MADD      : SimOpcode<"MADD",      0b1000011>;
def OPC_MSUB      : SimOpcode<"MSUB",      0b1000111>;
def OPC_NMSUB     : SimOpcode<"NMSUB",     0b1001011>;
def OPC_NMADD     : SimOpcode<"NMADD",     0b1001111>;
def OPC_OP_FP     : SimOpcode<"OP_FP",     0b1010011>;
def OPC_OP_V      : SimOpcode<"OP_V",      0b1010111>;
def OPC_CUSTOM_2  : SimOpcode<"CUSTOM_2",  0b1011011>;
def OPC_BRANCH    : SimOpcode<"BRANCH",    0b1100011>;
def OPC_JALR      : SimOpcode<"JALR",      0b1100111>;
def OPC_JAL       : SimOpcode<"JAL",       0b1101111>;
def OPC_SYSTEM    : SimOpcode<"SYSTEM",    0b1110011>;
def OPC_CUSTOM_3  : SimOpcode<"CUSTOM_3",  0b1111011>;

class SimInst<dag outs, dag ins, string opcodestr, string argstr,
             list<dag> pattern, InstFormat format>
    : Instruction {

  let Namespace = "Sim";
  let DecoderNamespace = "Sim";
  let Size = 4;

  field bits<32> Inst;

  bits<7> Opcode = 0;
  let Inst{6-0} = Opcode;

  dag OutOperandList = outs;
  dag InOperandList = ins;
  let AsmString = opcodestr # "\t" # argstr;
  let Pattern = pattern;
}

class SimInstR<bits<7> funct7, bits<3> funct3, SimOpcode opcode, dag outs,
              dag ins, string opcodestr, string argstr>
    : SimInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> rd;

  let Inst{31-25} = funct7;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7} = rd;
  let Opcode = opcode.Value;
}


class SimInstI<bits<3> funct3, SimOpcode opcode, dag outs, dag ins,
              string opcodestr, string argstr>
    : SimInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<12> imm12;
  bits<5> rs1;
  bits<5> rd;

  let Inst{31-20} = imm12;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7} = rd;
  let Opcode = opcode.Value;
}


class SimInstS<bits<3> funct3, SimOpcode opcode, dag outs, dag ins,
              string opcodestr, string argstr>
    : SimInst<outs, ins, opcodestr, argstr, [], InstFormatS> {
  bits<12> imm12;
  bits<5> rs2;
  bits<5> rs1;

  let Inst{31-25} = imm12{11-5};
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7} = imm12{4-0};
  let Opcode = opcode.Value;
}

class SimInstB<bits<3> funct3, SimOpcode opcode, dag outs, dag ins,
              string opcodestr, string argstr>
    : SimInst<outs, ins, opcodestr, argstr, [], InstFormatB> {
  bits<12> imm12;
  bits<5> rs2;
  bits<5> rs1;

  let Inst{31} = imm12{11};
  let Inst{30-25} = imm12{9-4};
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-8} = imm12{3-0};
  let Inst{7} = imm12{10};
  let Opcode = opcode.Value;
}

class SimInstU<SimOpcode opcode, dag outs, dag ins, string opcodestr,
              string argstr>
    : SimInst<outs, ins, opcodestr, argstr, [], InstFormatU> {
  bits<20> imm20;
  bits<5> rd;

  let Inst{31-12} = imm20;
  let Inst{11-7} = rd;
  let Opcode = opcode.Value;
}

class SimInstJ<SimOpcode opcode, dag outs, dag ins, string opcodestr,
              string argstr>
    : SimInst<outs, ins, opcodestr, argstr, [], InstFormatJ> {
  bits<20> imm20;
  bits<5> rd;

  let Inst{31} = imm20{19};
  let Inst{30-21} = imm20{9-0};
  let Inst{20} = imm20{10};
  let Inst{19-12} = imm20{18-11};
  let Inst{11-7} = rd;
  let Opcode = opcode.Value;
}
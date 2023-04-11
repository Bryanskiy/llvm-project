//===-- RISCVRegisterInfo.td - RISC-V Register defs --------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the RISC-V register files
//===----------------------------------------------------------------------===//

let Namespace = "GArch" in {
class GArchReg<bits<5> Enc, string n, list<string> alt = []> : Register<n> {
  let HWEncoding{4-0} = Enc;
  let AltNames = alt;
}

class GArchReg16<bits<5> Enc, string n, list<string> alt = []> : Register<n> {
  let HWEncoding{4-0} = Enc;
  let AltNames = alt;
}

def sub_16 : SubRegIndex<16>;
class GArchReg32<GArchReg16 subreg> : Register<""> {
  let HWEncoding{4-0} = subreg.HWEncoding{4-0};
  let SubRegs = [subreg];
  let SubRegIndices = [sub_16];
  let AsmName = subreg.AsmName;
  let AltNames = subreg.AltNames;
}

// Because GArchReg64 register have AsmName and AltNames that alias with their
// 16/32-bit sub-register, GArchAsmParser will need to coerce a register number
// from a GArchReg16/GArchReg32 to the equivalent GArchReg64 when appropriate.
def sub_32 : SubRegIndex<32>;
class GArchReg64<GArchReg32 subreg> : Register<""> {
  let HWEncoding{4-0} = subreg.HWEncoding{4-0};
  let SubRegs = [subreg];
  let SubRegIndices = [sub_32];
  let AsmName = subreg.AsmName;
  let AltNames = subreg.AltNames;
}

class GArchRegWithSubRegs<bits<5> Enc, string n, list<Register> subregs,
                          list<string> alt = []>
      : RegisterWithSubRegs<n, subregs> {
  let HWEncoding{4-0} = Enc;
  let AltNames = alt;
}

def ABIRegAltName : RegAltNameIndex;

def sub_32_hi  : SubRegIndex<32, 32>;
} // Namespace = "GArch"

// Integer registers
// CostPerUse is set higher for registers that may not be compressible as they
// are not part of GPRC, the most restrictive register class used by the
// compressed instruction set. This will influence the greedy register
// allocator to reduce the use of registers that can't be encoded in 16 bit
// instructions.

let RegAltNameIndices = [ABIRegAltName] in {
  def X0  : GArchReg<0, "x0", ["zero"]>, DwarfRegNum<[0]>;
  let CostPerUse = [0, 1] in {
  def X1  : GArchReg<1, "x1", ["ra"]>, DwarfRegNum<[1]>;
  def X2  : GArchReg<2, "x2", ["sp"]>, DwarfRegNum<[2]>;
  def X3  : GArchReg<3, "x3", ["gp"]>, DwarfRegNum<[3]>;
  def X4  : GArchReg<4, "x4", ["tp"]>, DwarfRegNum<[4]>;
  def X5  : GArchReg<5, "x5", ["t0"]>, DwarfRegNum<[5]>;
  def X6  : GArchReg<6, "x6", ["t1"]>, DwarfRegNum<[6]>;
  def X7  : GArchReg<7, "x7", ["t2"]>, DwarfRegNum<[7]>;
  }
  def X8  : GArchReg<8, "x8", ["s0", "fp"]>, DwarfRegNum<[8]>;
  def X9  : GArchReg<9, "x9", ["s1"]>, DwarfRegNum<[9]>;
  def X10 : GArchReg<10,"x10", ["a0"]>, DwarfRegNum<[10]>;
  def X11 : GArchReg<11,"x11", ["a1"]>, DwarfRegNum<[11]>;
  def X12 : GArchReg<12,"x12", ["a2"]>, DwarfRegNum<[12]>;
  def X13 : GArchReg<13,"x13", ["a3"]>, DwarfRegNum<[13]>;
  def X14 : GArchReg<14,"x14", ["a4"]>, DwarfRegNum<[14]>;
  def X15 : GArchReg<15,"x15", ["a5"]>, DwarfRegNum<[15]>;
  let CostPerUse = [0, 1] in {
  def X16 : GArchReg<16,"x16", ["a6"]>, DwarfRegNum<[16]>;
  def X17 : GArchReg<17,"x17", ["a7"]>, DwarfRegNum<[17]>;
  def X18 : GArchReg<18,"x18", ["s2"]>, DwarfRegNum<[18]>;
  def X19 : GArchReg<19,"x19", ["s3"]>, DwarfRegNum<[19]>;
  def X20 : GArchReg<20,"x20", ["s4"]>, DwarfRegNum<[20]>;
  def X21 : GArchReg<21,"x21", ["s5"]>, DwarfRegNum<[21]>;
  def X22 : GArchReg<22,"x22", ["s6"]>, DwarfRegNum<[22]>;
  def X23 : GArchReg<23,"x23", ["s7"]>, DwarfRegNum<[23]>;
  def X24 : GArchReg<24,"x24", ["s8"]>, DwarfRegNum<[24]>;
  def X25 : GArchReg<25,"x25", ["s9"]>, DwarfRegNum<[25]>;
  def X26 : GArchReg<26,"x26", ["s10"]>, DwarfRegNum<[26]>;
  def X27 : GArchReg<27,"x27", ["s11"]>, DwarfRegNum<[27]>;
  def X28 : GArchReg<28,"x28", ["t3"]>, DwarfRegNum<[28]>;
  def X29 : GArchReg<29,"x29", ["t4"]>, DwarfRegNum<[29]>;
  def X30 : GArchReg<30,"x30", ["t5"]>, DwarfRegNum<[30]>;
  def X31 : GArchReg<31,"x31", ["t6"]>, DwarfRegNum<[31]>;
  }
}

def XLenVT : ValueTypeByHwMode<[RV32, RV64],
                               [i32,  i64]>;
def XLenRI : RegInfoByHwMode<
      [RV32,              RV64],
      [RegInfo<32,32,32>, RegInfo<64,64,64>]>;

// The order of registers represents the preferred allocation sequence.
// Registers are listed in the order caller-save, callee-save, specials.
def GPR : RegisterClass<"GArch", [XLenVT], 32, (add
    (sequence "X%u", 10, 17),
    (sequence "X%u", 5, 7),
    (sequence "X%u", 28, 31),
    (sequence "X%u", 8, 9),
    (sequence "X%u", 18, 27),
    (sequence "X%u", 0, 4)
  )> {
  let RegInfos = XLenRI;
}

def GPRX0 : RegisterClass<"GArch", [XLenVT], 32, (add X0)> {
  let RegInfos = XLenRI;
}

def GPRNoX0 : RegisterClass<"GArch", [XLenVT], 32, (sub GPR, X0)> {
  let RegInfos = XLenRI;
}

def GPRNoX0X2 : RegisterClass<"GArch", [XLenVT], 32, (sub GPR, X0, X2)> {
  let RegInfos = XLenRI;
}

// Don't use X1 or X5 for JALR since that is a hint to pop the return address
// stack on some microarchitectures. Also remove the reserved registers X0, X2,
// X3, and X4 as it reduces the number of register classes that get synthesized
// by tablegen.
def GPRJALR : RegisterClass<"GArch", [XLenVT], 32, (sub GPR, (sequence "X%u", 0, 5))> {
  let RegInfos = XLenRI;
}

def GPRC : RegisterClass<"GArch", [XLenVT], 32, (add
    (sequence "X%u", 10, 15),
    (sequence "X%u", 8, 9)
  )> {
  let RegInfos = XLenRI;
}

// For indirect tail calls, we can't use callee-saved registers, as they are
// restored to the saved value before the tail call, which would clobber a call
// address. We shouldn't use x5 since that is a hint for to pop the return
// address stack on some microarchitectures.
def GPRTC : RegisterClass<"GArch", [XLenVT], 32, (add
    (sequence "X%u", 6, 7),
    (sequence "X%u", 10, 17),
    (sequence "X%u", 28, 31)
  )> {
  let RegInfos = XLenRI;
}

def SP : RegisterClass<"GArch", [XLenVT], 32, (add X2)> {
  let RegInfos = XLenRI;
}

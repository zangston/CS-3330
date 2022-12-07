# -*-sh-*- # this line enables partial syntax highlighting in emacs

######### The PC #############
register fF { pc:64 = 0; }


########## Fetch #############
pc = F_pc;

# wire icode:4, ifun:4, rA:4, rB:4, valC:64;

f_icode = i10bytes[4..8];
# f_ifun = i10bytes[0..4];
f_rA = i10bytes[12..16];
f_rB = i10bytes[8..12];

f_valC = [
     f_icode in { JXX } : i10bytes[8..72];
     1 : i10bytes[16..80];
];

wire offset : 64, valP : 64;
offset = [
       f_icode in { HALT, NOP, RET } : 1;
       f_icode in { RRMOVQ, OPQ, PUSHQ, POPQ } : 2;
       f_icode in { JXX, CALL } : 9;
       1 : 10;
];
valP = F_pc + offset;

f_Stat = [
     f_icode == HALT : STAT_HLT;
     f_icode > 0xB : STAT_INS;
     1 : STAT_AOK;
];

########## Fetch-Decode register ##########
register fD {
	 icode : 4 = NOP;
	 # ifun : 4 = ALWAYS;

	 rA : 4 = REG_NONE;
	 rB : 4 = REG_NONE;
	 
	 valC : 64 = 0;

	 Stat : 3 = STAT_AOK;
}


########## Decode #############

reg_srcA = [
	 D_icode in {RMMOVQ} : D_rA;
	 1 : REG_NONE;
];
d_valA = [
       reg_srcA == REG_NONE : 0;
       reg_srcA == m_dstM : m_valM;
       reg_srcA == W_dstM : W_valM;
       1 : reg_outputA;
];

reg_srcB = [
	 D_icode in {RMMOVQ, MRMOVQ} : D_rB;
	 1 : REG_NONE;
];
d_valB = [
       reg_srcB == REG_NONE : 0;
       reg_srcB == m_dstM : m_valM;
       reg_srcB == W_dstM : W_valM;
       1 : reg_outputB;
];

wire loadUse : 1;
loadUse = [
	E_icode == MRMOVQ && reg_srcA == E_dstM : true;
	E_icode == MRMOVQ && reg_srcB == E_dstM : true;
	1 : false;
];

d_dstM = [
	 D_icode in { MRMOVQ } : D_rA;
	 1 : REG_NONE;
];

d_icode = D_icode;
d_valC = D_valC;

d_Stat = D_Stat;

stall_F = [
	f_Stat != STAT_AOK : true;
	loadUse == 1 : true;
	1 : false;
];
stall_D = loadUse;
bubble_E = loadUse;

########## Decode-Execute register ##########
register dE {
	 icode : 4 = NOP;

	 dstM : 4 = REG_NONE;

	 valA : 64 = 0;
	 valB : 64 = 0;
	 valC : 64 = 0;

	 Stat : 3 = STAT_AOK;
}

########## Execute #############
wire operand1 : 64, operand2 : 64;

operand1 = [
	 E_icode in { MRMOVQ, RMMOVQ } : E_valC;
	 1 : 0;
];
operand2 = [
	 E_icode in { MRMOVQ, RMMOVQ } : E_valB;
	 1 : 0;
];

# wire valE : 64;

e_valE = [
       E_icode in { MRMOVQ, RMMOVQ } : operand1 + operand2;
       1 : 0;
];

e_icode = E_icode;

e_dstM = E_dstM;

e_valA = E_valA;

e_Stat = E_Stat;

########## Execute-Memory register ##########
register eM {
	 icode : 4 = NOP;	 

	 dstM : 4 = NOP;

	 valA : 64 = 0;
	 valE : 64 = 0;	 

	 Stat : 3 = STAT_AOK;
}

########## Memory #############

mem_readbit = M_icode in { MRMOVQ };
mem_writebit = M_icode in { RMMOVQ };
mem_addr = [
	 M_icode in { MRMOVQ, RMMOVQ } : M_valE;
	 1: 0xBADBADBAD;
];
mem_input = [
	  M_icode in { RMMOVQ } : M_valA;
	  1: 0xBADBADBAD;
];

m_valM = mem_output;

m_icode = M_icode;

m_dstM = M_dstM;

m_Stat = M_Stat;

########## Memory-Writeback register #########
register mW {
	 icode : 4 = NOP;
	 
	 dstM : 4 = REG_NONE;

	 valM : 64 = 0;

	 Stat : 3 = STAT_AOK;
}

########## Writeback #############

reg_dstM = [
	 W_icode in {MRMOVQ} : W_dstM;
	 1: REG_NONE;
];
reg_inputM = [
	   W_icode in {MRMOVQ} : W_valM;
      	   1: 0xBADBADBAD;
];

Stat = W_Stat;

f_pc = valP;

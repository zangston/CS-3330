/* @title pipehw1.hcl
 * @author Winston Zhang, wy5rge
 * @date 18 Oct 2022
 * @description Submission for HCL6, pipehw1, for CS 3330
 */

/* ================================================================
 * PC, conditiona code, and pipeline registers
 *
 * Note: I tried to do what was suggested and declare
 * 	   pipeline register between stages but that
 *	   was too confusing for my tiny retard brain
 * ================================================================
 */
// PC register
register pP { 
	 pc : 64 = 0; 
}

// Condition code register
register cC {
	 SF : 1 = 0;
	 ZF : 1 = 1;
};

// Fetch-to-Decode pipeline register
register fD {
	 icode : 4 = NOP;
	 ifun : 4 = ALWAYS;	 

	 rA : 4 = REG_NONE;
	 rB : 4 = REG_NONE;
	 
	 valC : 64 = 0;

	 Stat : 3 = STAT_AOK;
}

// Decode-to-Execute pipeline register
register dE {
	 icode : 4 = NOP;
	 ifun : 4 = ALWAYS;

	 rA : 4 = REG_NONE;
	 rB : 4 = REG_NONE;

	 valA : 64 = 0;
	 valB : 64 = 0;
	 valC : 64 = 0;

	 Stat : 3 = STAT_AOK;
}

// Execute-to-Memory pipeline register
register eM {
	 icode : 4 = NOP;
	 ifun : 4 = ALWAYS;	 

	 conditionsMet : 1 = 0;

	 rA : 4 = REG_NONE;
	 rB : 4 = REG_NONE;

	 valA : 64 = 0;
	 # valB : 64 = 0;
	 valC : 64 = 0;
	 valE : 64 = 0;

	 Stat : 3 = STAT_AOK;
}

// Memory-to-Writeback pipeline register
register mW {
	 icode : 4 = NOP;
	 ifun : 4 = ALWAYS;

	 rA : 4 = REG_NONE;
	 rB : 4 = REG_NONE;

	 valA : 64 = 0;
	 # valB : 64 = 0;
	 valC : 64 = 0;	 
	 valE : 64 = 0;

	 Stat : 3 = STAT_AOK;
}

/* ========================================================================
 * Fetch stage
 * ========================================================================
 */
pc = P_pc;


// Extract icode, register indices, immediate value from instruction
f_icode = i10bytes[4..8];
f_ifun = i10bytes[0..4];
f_rA = i10bytes[12..16];
f_rB = i10bytes[8..12];

f_valC = [
     f_icode in { JXX } : i10bytes[8..72];
     1 : i10bytes[16..80];
];

// Compute pc increment
wire offset : 64, valP : 64;
offset = [
       f_icode in { HALT, NOP } : 1;
       f_icode in { RRMOVQ, CMOVXX, OPQ } : 2;
       f_icode in { IRMOVQ } : 10;
       1 : 0xBADBADBAD;
];
valP = P_pc + offset;

// Evaluate Stat code based on opcode
f_Stat = [
       f_icode == HALT : STAT_HLT;
       f_icode > 0xB : STAT_INS;
       1 : STAT_AOK;
];

// Stall PC register if Stat code is not AOK
stall_P = [
        f_Stat != STAT_AOK : true;
        1 : false;
];

/* ===========================================================================================
 * Decode stage
 * ===========================================================================================
 */

// Feed opcode into next pipeline register
d_icode = D_icode;
d_ifun = D_ifun;

// Source selection
d_rA = D_rA;

reg_srcA = [
	 D_icode in { RRMOVQ, CMOVXX, OPQ } : D_rA;
	 1 : REG_NONE;
];

/* Forward value from memory-to-writeback pipeline register if an instruction is
 * 	   writing to a register that we want to read from
 */
d_valA = [
       E_icode == RRMOVQ && reg_srcA == E_rB && reg_srcA != REG_NONE && e_conditionsMet : e_valA;
       E_icode == IRMOVQ && reg_srcA == E_rB && reg_srcA != REG_NONE : e_valC;
       E_icode == OPQ && reg_srcA == E_rB && reg_srcA != REG_NONE : e_valE;

       M_icode == RRMOVQ && reg_srcA == M_rB && reg_srcA != REG_NONE && e_conditionsMet : m_valA;
       M_icode == IRMOVQ && reg_srcA == M_rB && reg_srcA != REG_NONE : m_valC;
       M_icode == OPQ && reg_srcA == M_rB && reg_srcA != REG_NONE : m_valE;

       W_icode == RRMOVQ && reg_srcA == W_rB && reg_srcA != REG_NONE && e_conditionsMet : W_valA;
       W_icode == IRMOVQ && reg_srcA == W_rB && reg_srcA != REG_NONE : W_valC;
       W_icode == OPQ && reg_srcA == W_rB && reg_srcA != REG_NONE : W_valE;

       1 : reg_outputA;
];

d_rB = D_rB;

reg_srcB = D_rB;

d_valB = [
       E_icode == RRMOVQ && reg_srcB == E_rB && reg_srcB != REG_NONE && e_conditionsMet : e_valA;
       E_icode == IRMOVQ && reg_srcB == E_rB && reg_srcB != REG_NONE : e_valC;
       E_icode == OPQ && reg_srcB == E_rB && reg_srcB != REG_NONE : e_valE;

       M_icode == RRMOVQ && reg_srcB == M_rB && reg_srcB != REG_NONE && e_conditionsMet : m_valA;
       M_icode == IRMOVQ && reg_srcB == M_rB && reg_srcB != REG_NONE : m_valC;
       M_icode == OPQ && reg_srcB == M_rB && reg_srcB != REG_NONE : m_valE;

       W_icode == RRMOVQ && reg_srcB == W_rB && reg_srcB != REG_NONE && e_conditionsMet : W_valA;
       W_icode == IRMOVQ && reg_srcB == W_rB && reg_srcB != REG_NONE : W_valC;
       W_icode == OPQ && reg_srcB == W_rB && reg_srcB != REG_NONE : W_valE;

       1: reg_outputB;
];

d_valC = D_valC;

// Feed stat code into next pipeline register
d_Stat = D_Stat;

/* ==============================================================================================
 * Execute stage
 * ==============================================================================================
 */
// Feed opcode to next pipeline register
e_icode = E_icode;
e_ifun = E_ifun;

e_conditionsMet = [
		E_ifun == ALWAYS : true;
		E_ifun == LE : C_SF || C_ZF;
		E_ifun == LT : C_SF;
		E_ifun == EQ : C_ZF;
		E_ifun == NE : !C_ZF;
		E_ifun == GE : !C_SF;
		E_ifun == GT : !C_SF && !C_ZF;
		1 : false;
];

e_rA = E_rA;
e_valA = E_valA;

e_rB = [
     E_icode == CMOVXX && e_conditionsMet == false : REG_NONE;
     1 : E_rB;
];

e_valC = E_valC;

e_valE = [
       E_icode == OPQ && E_ifun == ADDQ : E_valA + E_valB;
       E_icode == OPQ && E_ifun == SUBQ : E_valB - E_valA;
       E_icode == OPQ && E_ifun == ANDQ : E_valA & E_valB;
       E_icode == OPQ && E_ifun == XORQ : E_valA ^ E_valB;
       1 : 0xDEADBEEF;
];

// Set condition codes
c_ZF = e_valE == 0;
c_SF = e_valE >= 0x8000000000000000;
stall_C = E_icode != OPQ;

// Feed stat code to next pipeline register
e_Stat = E_Stat;

/* ======================================================================================
 * Memory stage
 *
 * Assignment writeup says that none of the instructions that are to be implemented
 * 	      use the memory stage so we simply just feed values from one pipeline
 *	      register to another
 * ======================================================================================
 */
m_icode = M_icode;
m_ifun = M_ifun;

m_rA = M_rA;
m_rB = M_rB;

m_valA = M_valA;
# m_valB = M_valB;
m_valC = M_valC;
m_valE = M_valE;

m_Stat = M_Stat;

/* ===================================================================================
 * Writeback stage
 * ===================================================================================
 */
reg_dstE = [
	 W_icode in { IRMOVQ, RRMOVQ, OPQ, CMOVXX } : W_rB;
	 1 : REG_NONE;
];

reg_inputE = [
	   W_icode in { RRMOVQ, CMOVXX } : W_valA;
	   W_icode in { IRMOVQ } : W_valC;
	   W_icode in { OPQ } : W_valE;
	   1 : 0xBADBADBAD;
];

/* ========================================================================================
 * PC and Status updates
 * ========================================================================================
 */
Stat = W_Stat;

p_pc = valP;

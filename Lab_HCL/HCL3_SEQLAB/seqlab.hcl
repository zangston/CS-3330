/* seqlab.hcl
 * @author Winston Zhang, wyz5rge
 * @date 28 Sept 2022
 * @description submission for HCL3 Lab for CS 3330. Based off my irrr.hcl file
 * 		written for last week's homework, HCL2
 */

register pP {  
	pc : 64 = 0;
	
	// Keeping this comment block in case it's important/useful in the future	
	# there are also two other signals we can optionally use:
	# "bubble_P = true" resets every register in P to its default value
	# "stall_P = true" causes P_pc not to change, ignoring p_pc's value
} 

# "pc" is a pre-defined input to the instruction memory and is the 
# address to fetch 10 bytes from (into pre-defined output "i10bytes").
pc = P_pc;

/* Register for storing condition codes
 * Default values are declared below
 */
register cC {
	 SF : 1 = 0;
	 ZF : 1 = 1;
}

/* ===============================================================================
 * Fetch Stage
 * ===============================================================================
 */
// Declaring wires for opcode, icode, ifun
wire opcode : 8, icode : 4, ifun : 4;

// Extracting bits for opcode from instruction memory, icode from opcode
opcode = i10bytes[0..8];
icode = opcode[4..8];
ifun = opcode[0..4];

# named constants can help make code readable
const TOO_BIG = 0xC; # the first unused icode in Y86-64

# some named constants are built-in: the icodes, ifuns, STAT_??? and REG_???

/* Stat code ssignment MUX
 * Current configured to stop on halt icode, or
 * icode larger than 11
 */
Stat = [
     icode == HALT : STAT_HLT;
     icode > 11    : STAT_INS;
     1 : STAT_AOK;
];

// Declaring wires for bits we want to extract from instruction
wire rA : 4, rB : 4, valC : 64;

// Extract rA, rB, from instruciton into separate wires
rA = i10bytes[12..16];
rB = i10bytes[8..12];

// Extract valC from instruction, depending on instruction
valC = [
     icode == JXX : i10bytes[8..72];
     1: i10bytes[16..80];
];

/* =============================================================================
 * EXECUTE STAGE
 * =============================================================================
 */
// Combined code block for implemented instructions irmovq, rrmovq, jxx

// Set register source to rA if instruction is rrmovq
reg_srcA = [
	 icode == RRMOVQ : rA;
	 icode == CMOVXX: rA;
	 icode == RMMOVQ : rA;

	 icode == OPQ : rA;
	 1 : REG_NONE;
];

reg_srcB = [
	 icode == RMMOVQ : rB;

	 icode == OPQ : rB;

	 1 : REG_NONE;
];

/* Set value of destination register based on instruction
 * Implemented instructions: irmovq, rrmovq, OPq, cmovCC
 */
wire valE : 64;
valE = [
     icode == IRMOVQ : valC;
     icode == RRMOVQ : reg_outputA;
     icode == CMOVXX : reg_outputA;
     icode == RMMOVQ : valC + reg_outputB;
     
     //OPQ assignments
     icode == OPQ && ifun == ADDQ : reg_outputA + reg_outputB;
     icode == OPQ && ifun == SUBQ : reg_outputB - reg_outputA;
     icode == OPQ && ifun == ANDQ : reg_outputA & reg_outputB;
     icode == OPQ && ifun == XORQ : reg_outputA ^ reg_outputB;

     1 : 0xBEEF;	   # might need to change this later...
];
reg_inputE = valE;

/* Set condition codes
 * Currently configured to only set when executing OPq instructions
 */
c_ZF = [
     icode == OPQ : (valE == 0);
     1 : C_ZF;
];
c_SF = [
     icode == OPQ: (valE >= 0x8000000000000000);
     1 : C_SF;
];

// Condition settings for condition move instructions
wire conditionsMet : 1;

/* Boolean value derived from the sign and zero flags,
 * 	   based on which condition we want to use. 
 * The value of this boolean determines whether a conditional jump
 *     will be executed.
 */
conditionsMet = [
	      ifun == ALWAYS : 1;
	      ifun == LE : C_SF || C_ZF;
	      ifun == LT : (C_SF == 1);
	      ifun == EQ : (C_ZF == 1);
	      ifun == NE : (C_ZF != 1);
	      ifun == GE : !C_SF || C_ZF;
	      ifun == GT : !C_SF && !C_ZF;
	      
	      1 : 0
];

/* =================================================================
 * MEMORY STAGE
 * =================================================================
 */
mem_readbit = [
	    icode == MRMOVQ : 1;
	    1 : 0;
];
mem_writebit = [
	     icode == RMMOVQ : 1;
	     1 : 0;
];

mem_addr = valE;

mem_input = reg_outputA;


/* =================================================================
 * WRITEBACK STAGE
 * =================================================================
 */
reg_dstE = [
	 !conditionsMet && icode == CMOVXX : REG_NONE;	# Don't execute move if ocndition not met
	 
	 // Register destinations for move instructions
	 icode == IRMOVQ : rB;
	 // icode == RRMOVQ : rB;	# Commented out because RRMOVQ is now just a special case of CMOVXX
	 icode == CMOVXX : rB;

	 icode == OPQ : rB;
	 
	 1 : REG_NONE;
];

/* ========================================================================================================
 * Update program counter
 * ========================================================================================================
 */
// We use this value to increment the program counter, depending on the instruction
wire valP : 64;

valP = [
     icode == HALT	: P_pc + 1;
     icode == NOP	: P_pc + 1;
     icode == RRMOVQ	: P_pc + 2;
     icode == IRMOVQ	: P_pc + 10;
     icode == RMMOVQ	: P_pc + 10;
     icode == MRMOVQ	: P_pc + 10;
     icode == OPQ	: P_pc + 2;
     icode == JXX	: valC;	 # Updated after implementing irmovq, rrmovq, and unconditional jump instructions
     icode == CALL	: P_pc + 9;
     icode == RET	: P_pc + 1;
     icode == PUSHQ	: P_pc + 2;
     icode == POPQ	: P_pc + 2;
     1 : 0xBADBADBAD;
];
p_pc = valP;

/* irrr.hcl
 * @author Winston Zhang, wyz5rge
 * @description submission for HCL2 Homework for CS 3330. Based off my pc.hcl file
 * 		written for last week's lab, HCL1
 */

register pP {  
    # our own internal register. P_pc is its output, p_pc is its input.
	pc:64 = 0; # 64-bits wide; 0 is its default value.
	
	# we could add other registers to the P register bank
	# register bank should be a lower-case letter and an upper-case letter, in that order.
	
	# there are also two other signals we can optionally use:
	# "bubble_P = true" resets every register in P to its default value
	# "stall_P = true" causes P_pc not to change, ignoring p_pc's value
} 

# "pc" is a pre-defined input to the instruction memory and is the 
# address to fetch 10 bytes from (into pre-defined output "i10bytes").
pc = P_pc;

# we can define our own input/output "wires" of any number of 0<bits<=80
wire opcode:8, icode:4;

# the x[i..j] means "just the bits between i and j".  x[0..1] is the 
# low-order bit, similar to what the c code "x&1" does; "x&7" is x[0..3]
opcode = i10bytes[0..8];   # first byte read from instruction memory
icode = opcode[4..8];      # top nibble of that byte

# named constants can help make code readable
const TOO_BIG = 0xC; # the first unused icode in Y86-64

# some named constants are built-in: the icodes, ifuns, STAT_??? and REG_???

// Declaring wires for bits we want to extract from instruction
wire rA : 4, rB : 4, valC : 64;

// Extract rA, rB, and valC values from instruciton into separate wires
rA = i10bytes[12..16];
rB = i10bytes[8..12];	# seems like little endian still fucks me up
// valC = i10bytes[16..80];
   # commented out because valC depends on the instruction


/* Separate code blocks for each instruction
 * Commented out so I could combine them into one cleaner block of code - also because
	  irmovq and rrmovq had different ways of handling the data that had to be moved

// Code block for rrmovq

reg_srcA = [
	   icode == RRMOVQ : rA;
	   1 : REG_NONE;
];

// Send value from rA into data input
reg_inputE = reg_outputA;

// Code block for irmovq implrementation 
// Set register to write to destination register in instruction for irmovq and rrmovq instructions
reg_dstE = [
	 icode == IRMOVQ : rB;
	 icode == RRMOVQ : rB;
	 1 : REG_NONE;
];

// Send valC to register file
reg_inputE = valC;
*/

/* Removed the other STAT_INS assignments that were included from last week's lab assignment
 *	   because the homework writeup doesn't call for them.
 */
Stat = [
     icode == HALT : STAT_HLT;
     icode > 11    : STAT_INS;
     1 : STAT_AOK;
];

// Combined code block for newly implemented instructions
// Extract valC depending on the instruction - bits 8 thru 72 for jXX, 16 thru 80 otherwise
valC = [
     icode == JXX : i10bytes[8..72];
     1 : i10bytes[16..80];
];

// Set register source to rA if instruction is rrmovq
reg_srcA = [
	 icode == RRMOVQ : rA;
	 1 : REG_NONE;
];

// Set data input to valC if irmovq instruction, value of rA if rrmovq
reg_inputE = [
	   icode == IRMOVQ : valC;
	   icode == RRMOVQ : reg_outputA;
	   1 : 0xBEEF;	   # might need to change this later...
];

reg_dstE = [
	 icode == IRMOVQ : rB;
	 icode == RRMOVQ : rB;
	 1 : REG_NONE;
];

// Update program counter
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

`timescale 1ns / 1ps
// definition of all ALU operation : ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
// `define ALU_ADD  4'b0000 // Add (discard last carry)
// `define ALU_SUB  4'b0001 // Sub by two's complement
// `define ALU_AND  4'b0010 // And bitwise 
// `define ALU_OR   4'b0011 // Or  bitwise 
// `define ALU_XOR  4'b0100 // Xor bitwise 
// `define ALU_SLL  4'b0101 // Shift left logical
// `define ALU_SRL  4'b0110 // Shift right logical
// `define ALU_SRA  4'b0111 // Shift right arithmetic
// `define ALU_SLT  4'b1000 // Set less than (signed)
// `define ALU_SLTU 4'b1001 // Set less than (unsigned)
package op_codes_pkg;
    typedef enum logic [2:0] {
        TYPE_R,
        TYPE_I,
        TYPE_S,
        TYPE_B,
        TYPE_U,
        TYPE_J,
        TYPE_UNKNOWN
    } format_t;

    // Opcodes standards RV32I (bits [6:2], ou [6:0] si vous incluez les bits bas '11')
    localparam [6:0] OP_LOAD   = 7'b0000011; // Type I (ex: lb, lh, lw)
    localparam [6:0] OP_STORE  = 7'b0100011; // Type S (ex: sb, sh, sw)

    localparam [6:0] OP_BRANCH = 7'b1100011; // Type B (ex: beq, bne, blt)

    localparam [6:0] OP_JALR   = 7'b1100111; // Type I 
    localparam [6:0] OP_JAL    = 7'b1101111; // Type J

    localparam [6:0] OP_IMM    = 7'b0010011; // Type I (ex: ADDI, ANDI...) Except SLLI SRLI SRAI
    localparam [6:0] OP_REG    = 7'b0110011; // Type R (ex: ADD, SUB, OR...)

    localparam [6:0] OP_AUIPC  = 7'b0010111; // Type U
    localparam [6:0] OP_LUI    = 7'b0110111; // Type U

    localparam [6:0] OP_MISCMEM= 7'b0001111; // Type I (ex: ecall, ebreak)
    localparam [6:0] OP_SYS    = 7'b1110011; // Type I (ex: fence)
endpackage
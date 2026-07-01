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
package alu_pkg;
    typedef enum logic [3:0] { 
        ALU_ADD  = 4'b0000, // Add (discard last carry)  hex : 0  // BEQ | LB | SB
        ALU_SUB  = 4'b0001, // Sub by two's complement   hex : 1  f7
        ALU_AND  = 4'b0010, // And bitwise               hex : 2  // BGEU
        ALU_OR   = 4'b0011, // Or  bitwise               hex : 3  // BLTU
        ALU_XOR  = 4'b0100, // Xor bitwise               hex : 4  // BLT | LBU
        ALU_SLL  = 4'b0101, // Shift left logical        hex : 5  // BNE | LH | SH
        ALU_SRL  = 4'b0110, // Shift right logical       hex : 6  // BGE | LHU
        ALU_SRA  = 4'b0111, // Shift right arithmetic    hex : 7  f7
        ALU_SLT  = 4'b1000, // Set less than (signed)    hex : 8  // LW | SW
        ALU_SLTU = 4'b1001, // Set less than (unsigned)  hex : 9  ...
        ALU_ERR  = 4'b1111  //                           hex : 0
    } alu_op_t;

    typedef enum logic [3:0] {
        BR_BEQ  = 4'b0000,
        BR_BGEU  = 4'b0010,
        BR_BLTU   = 4'b0011,
        BR_BLT  = 4'b0100,
        BR_BNE  = 4'b0101,
        BR_BGE  = 4'b0110,
        BR_ERR  = 4'b1111 
    } branch_op_t;

    typedef enum logic [3:0] {
        LS_LSB  = 4'b0000,
        LS_LBU  = 4'b0100,
        LS_LSH  = 4'b0101,
        LS_LHU  = 4'b0110,
        LS_LSW  = 4'b1000,
        LS_ERR  = 4'b1111 
    } ls_op_t;
endpackage
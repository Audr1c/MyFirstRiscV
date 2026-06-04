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
        ALU_ADD  = 4'b0000, // Add (discard last carry)
        ALU_SUB  = 4'b0001, // Sub by two's complement
        ALU_AND  = 4'b0010, // And bitwise 
        ALU_OR   = 4'b0011, // Or  bitwise 
        ALU_XOR  = 4'b0100, // Xor bitwise 
        ALU_SLL  = 4'b0101, // Shift left logical
        ALU_SRL  = 4'b0110, // Shift right logical
        ALU_SRA  = 4'b0111, // Shift right arithmetic
        ALU_SLT  = 4'b1000, // Set less than (signed)
        ALU_SLTU = 4'b1001  // Set less than (unsigned)
    } alu_op_t;
endpackage
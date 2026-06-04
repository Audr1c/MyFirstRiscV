

`timescale 1ns / 1ps

module alu(
    input  logic [31:0] in1,
    input  logic [31:0] in2,
    input  alu_op_t alu_ctrl

    output logic [31:0] out,
    output logic zero,
);
    
    always_comb begin
        case (alu_ctrl)
            ALU_ADD : out = in1 + in2;
            ALU_SUB : out = in1 - in2;
            ALU_AND : out = in1 & in2;
            ALU_OR  : out = in1 | in2;
            ALU_XOR : out = in1 ^ in2;
            ALU_SLL : out = in1 << in2;
            ALU_SRL : out = in1 >> in2;
            ALU_SRA : out = in1 >> in2;
            ALU_SLT : out = in1 < in2;
            ALU_SLTU: out = in1 < in2;
        endcase

        assign zero = out == 0; // ~(|out)
    end
endmodule
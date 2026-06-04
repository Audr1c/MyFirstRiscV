

`timescale 1ns / 1ps
import alu_pkg::*;
module alu(
    input  logic [31:0] in1,
    input  logic [31:0] in2,
    input  alu_op_t alu_ctrl,

    output logic [31:0] out,
    output logic zero
);
    
    always_comb begin
        case (alu_ctrl)
            ALU_ADD : out = in1 + in2;
            ALU_SUB : out = in1 - in2;
            ALU_AND : out = in1 & in2;
            ALU_OR  : out = in1 | in2;
            ALU_XOR : out = in1 ^ in2;
            ALU_SLL : out = in1 << in2[4:0];
            ALU_SRL : out = in1 >> in2[4:0];
            ALU_SRA : out = (-(1&in1[31]) << (32 -in2[4:0])) | (in1 >> in2[4:0]);
            ALU_SLT : out = $signed(in1) < $signed(in2);
            ALU_SLTU: out = in1 < in2;
        endcase

        assign zero = out == 0; // ~(|out)
    end
endmodule
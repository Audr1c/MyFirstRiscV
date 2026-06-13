`timescale 1ns / 1ps

module RegFile (
    input  logic [31:0] in,
    output logic [31:0] out1,
    output logic [31:0] out2,

    input  logic [4:0] rd,
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,

    input  logic RegWrite,
    input  logic clk,
    input  logic rst
);

    logic [31:0] x0 = 32'h0;
    logic [31:0] xreg [1:31];

    always_comb begin
        if (rs1!==0) out1 = xreg[rs1];
        else out1 = x0;
        if (rs2!==0) out2 = xreg[rs2];
        else out2 = x0;
    end

    always_ff @(posedge clk, posedge rst) begin 
        if (rst == 1) begin
            foreach (xreg[i]) begin
                xreg[i] <= 32'h0;
            end
        end
        else 
            if (RegWrite & rd !== 0) begin 
                xreg[rd] <= in;
            end
    end

endmodule
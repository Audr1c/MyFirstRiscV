`timescale 1ns / 1ps
module pc (
    input   logic          clk,
    input   logic          rst,
    input   logic  [31:0]  new_pc,
    input   logic          override,
    output  logic  [31:0]  pc
);

    always_ff @( posedge clk, posedge rst ) begin 
        if (rst) 
            pc <= 32'b0;
        else if (override)
            pc <= new_pc;
        else 
            pc <= pc + 1;        
    end

endmodule
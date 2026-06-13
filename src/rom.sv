`timescale 1ns / 1ps
module rom #(
    parameter PROG_FILE = "programms/default.txt"
)(
    input logic [31:0] pc,
    input logic clk,
    input logic rst,
    
    output logic [31:0] out
);

    logic [31:0] mem [0:1023]; // 1024 entry ROM

    task reset(); begin
        string file_name;
        file_name = PROG_FILE;
        // Permet de surcharger le nom du fichier au runtime avec +PROG_FILE=...
        void'($value$plusargs("PROG_FILE=%s", file_name)); 
        //vvp build/sim_out +PROG_FILE="mon_programme_de_test.bin"
        
        $readmemh(file_name, mem); // from hex 
        // $readmemb from binary
    end
    endtask

    initial begin
        reset();
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            out <= mem[0];
        else 
            out <= mem[pc[9:0]];
    end




endmodule
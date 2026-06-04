`define CLR_RESET  "\033[0m"
`define CLR_RED    "\033[1;31m"
`define CLR_GREEN  "\033[1;32m"
`define CLR_YELLOW "\033[1;33m"
`define CLR_BLUE   "\033[1;34m"


`timescale 1ns / 1ps
string formatted_msg;

module alu_tb;

    int errors = 0;
    int tests_run = 0;

    logic [31:0] in1;
    logic [31:0] in2;
    logic [31:0] out;
    logic zero;
    alu_op_t alu_op;


    alu dut (
        .in1(in1),
        .in2(in2),
        .alu_ctrl(alu_op),

        .out(out),
        .zero(zero)
    );

    // creation de la task

    task verification_alu(
        input  logic [31:0] in1_test,
        input  logic [31:0] in2_test,
        input  alu_op_t alu_ctrl_test

        output logic [31:0] out_expect,
        output logic zero_expect,

        string op
    );
        begin 
            tests_run ++;
            
            in1 = in1_test;
            in2 = in2_test;
            alu_ctrl = alu_ctrl_test;
            #10;

            if (out !== out_expect || zero !== zero_expect) begin
                formatted_msg = $sformatf("  [ERROR] Test %0d: %08h %s %08h gave %08h and z: %08h (Expected: Res %08h, %08h)",
                    tests_run, in1_test, op, in2_test, out, zero, out_expect, zero_expect);
                $display("%s%s%s", `CLR_RED, formatted_msg, `CLR_RESET);
                errors++;
            end else begin
                formatted_msg = $sformatf("  [SUCCESS] Test %0d: %08h %s %08h = %08h and z: %08h",
                    tests_run, in1_test, op, in2_test, out, zero);
                $display("%s%s%s", `CLR_GREEN, formatted_msg, `CLR_RESET);
            end
        end
    endtask



    initial begin
        $dumpfile("build/alu_simulation.vcd");
        $dumpvars(0, alu_tb);

        formatted_msg = $sformatf("-- ALU Test Bench --");
        $display("%s%s%s", `CLR_BLUE, formatted_msg, `CLR_RESET);

        $display("* Testing Add :");
        
        verification_alu(32'd0,         32'd0,           ALU_ADD,     32'd0,     1, " + ");         
        verification_alu(32'd1500,      32'd2500,        ALU_ADD,     32'd4000,  0, " + ");    
        verification_alu(32'hFFFF_FFFF, 32'd1,           ALU_ADD,     32'd0,     1, " + ");
        verification_alu(32'd10,        32'hFFFF_FFFB,   ALU_ADD,     32'd5,     0, " + ");
         
        $display("* End test Add !");
        
         formatted_msg = $sformatf("   END : %0d Tests executes | %0d Erreur(s)", tests_run, errors);
        if (errors == 0) $display("%s%s%s", `CLR_GREEN, formatted_msg, `CLR_RESET);
        else             $display("%s%s%s", `CLR_RED, formatted_msg, `CLR_RESET);
        
        $finish;
    end
endmodule

`define CLR_RESET  "\033[0m"
`define CLR_RED    "\033[1;31m"
`define CLR_GREEN  "\033[1;32m"
`define CLR_YELLOW "\033[1;33m"
`define CLR_BLUE   "\033[1;34m"


`timescale 1ns / 1ps
string formatted_msg;

import alu_pkg::*;

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
        input  alu_op_t     alu_ctrl_test,
        
        input  logic [31:0] out_expect, 
        input  logic        zero_expect,
        input  string       op
    );
        begin 
            tests_run ++;
            
            in1 = in1_test;
            in2 = in2_test;
            alu_op = alu_ctrl_test;
            #10;

            if (out !== out_expect || zero !== zero_expect) begin
                formatted_msg = $sformatf("  [ ERROR ] Test %02d: %08h %s %08h gave %08h and z: %08h (Expected: Res %08h, %08h)",
                    tests_run, in1_test, op, in2_test, out, zero, out_expect, zero_expect);
                $display("%s%s%s", `CLR_RED, formatted_msg, `CLR_RESET);
                errors++;
            end else begin
                formatted_msg = $sformatf("  [SUCCESS] Test %02d: %08h %s %08h = %08h and z: %08h",
                    tests_run, in1_test, op, in2_test, out, zero);
                $display("%s%s%s", `CLR_GREEN, formatted_msg, `CLR_RESET);
            end
        end
    endtask



    initial begin
        // L'enregistrement VCD est maintenant géré globalement par master_tb.sv
        // $dumpfile et $dumpvars ont été retirés ici.

        formatted_msg = $sformatf("-- ALU Test Bench --");
        $display("%s%s%s", `CLR_BLUE, formatted_msg, `CLR_RESET);

        // ==========================================
        // 1. ADD
        // ==========================================
        $display("* Testing Add :");
        verification_alu(32'd0,         32'd0,           ALU_ADD,     32'd0,     1, " + ");
        verification_alu(32'd1500,      32'd2500,        ALU_ADD,     32'd4000,  0, " + ");
        verification_alu(32'hFFFF_FFFF, 32'd1,           ALU_ADD,     32'd0,     1, " + ");
        verification_alu(32'd10,        32'hFFFF_FFFB,   ALU_ADD,     32'd5,     0, " + ");

        // these test created by AI
        // ==========================================
        // 2. SUB
        // ==========================================
        $display("* Testing Sub :");
        verification_alu(32'd0,         32'd0,           ALU_SUB,     32'd0,     1, " - ");
        verification_alu(32'd2500,      32'd1500,        ALU_SUB,     32'd1000,  0, " - ");
        verification_alu(32'd10,        32'd15,          ALU_SUB,     32'hFFFF_FFFb, 0, " - "); // -5
        verification_alu(32'h0,         32'd1,           ALU_SUB,     32'hFFFF_FFFF, 0, " - "); // -1

        // ==========================================
        // 3. AND
        // ==========================================
        $display("* Testing AND :");
        verification_alu(32'hFFFF_FFFF, 32'h0000_0000,   ALU_AND,     32'h0,     1, " & ");
        verification_alu(32'hA5A5_A5A5, 32'h5A5A_5A5A,   ALU_AND,     32'h0,     1, " & ");
        verification_alu(32'hFFFF_1234, 32'h0000_FFFF,   ALU_AND,     32'h1234,  0, " & ");

        // ==========================================
        // 4. OR
        // ==========================================
        $display("* Testing OR :");
        verification_alu(32'hA5A5_0000, 32'h0000_5A5A,   ALU_OR,      32'hA5A5_5A5A, 0, " | ");
        verification_alu(32'h0,         32'h0,           ALU_OR,      32'h0,     1, " | ");

        // ==========================================
        // 5. XOR
        // ==========================================
        $display("* Testing XOR :");
        verification_alu(32'hFFFF_FFFF, 32'hFFFF_FFFF,   ALU_XOR,     32'h0,     1, " ^ ");
        verification_alu(32'h1234_5678, 32'h8765_4321,   ALU_XOR,     32'h9551_1559, 0, " ^ ");

        // ==========================================
        // 6. SLL (Shift Left Logical)
        // ==========================================
        $display("* Testing SLL :");
        verification_alu(32'h0000_0001, 32'd4,           ALU_SLL,     32'h0000_0010, 0, "<< ");
        verification_alu(32'h8000_0000, 32'd1,           ALU_SLL,     32'h0,     1, "<< ");
        // Le RISC-V n'utilise que les 5 bits de poids faible de in2 pour la distance de décalage (32 positions max)
        verification_alu(32'hFFFF_FFFF, 32'd32,          ALU_SLL,     32'hFFFF_FFFF, 0, "<< "); // 32 = 5'b00000 donc décalage de 0

        // ==========================================
        // 7. SRL (Shift Right Logical)
        // ==========================================
        $display("* Testing SRL :");
        verification_alu(32'h8000_0000, 32'd1,           ALU_SRL,     32'h4000_0000, 0, ">> ");
        verification_alu(32'h0000_0010, 32'd4,           ALU_SRL,     32'h0000_0001, 0, ">> ");

        // ==========================================
        // 8. SRA (Shift Right Arithmetic)
        // ==========================================
        $display("* Testing SRA :");
        verification_alu(32'h8000_0000, 32'd1,           ALU_SRA,     32'hc000_0000, 0, ">>>"); // Extension du bit de signe
        verification_alu(32'h7000_0000, 32'd1,           ALU_SRA,     32'h3800_0000, 0, ">>>"); // Pas d'extension car positif

        // ==========================================
        // 9. SLT (Set Less Than - Signed)
        // ==========================================
        $display("* Testing SLT :");
        verification_alu(32'hFFFF_FFFF, 32'd1,           ALU_SLT,     32'd1,     0, "< s "); // -1 < 1 (Vrai)
        verification_alu(32'd5,         32'hFFFF_FFFB,   ALU_SLT,     32'd0,     1, "< s "); // 5 < -5 (Faux, out=0 donc zero=1)
        verification_alu(32'hFFFF_FFFE, 32'hFFFF_FFFF,   ALU_SLT,     32'd1,     0, "< s "); // -2 < -1 (Vrai)

        // ==========================================
        // 10. SLTU (Set Less Than - Unsigned)
        // ==========================================
        $display("* Testing SLTU :");
        verification_alu(32'hFFFF_FFFF, 32'd1,           ALU_SLTU,    32'd0,     1, "< u "); // Max_Unsigned < 1 (Faux)
        verification_alu(32'd1,         32'hFFFF_FFFF,   ALU_SLTU,    32'd1,     0, "< u "); // 1 < Max_Unsigned (Vrai)

        // ==========================================
        // Fin de la simulation
        // ==========================================
        
         formatted_msg = $sformatf("   END : %0d Tests executed | %0d Errors(s)", tests_run, errors);
        if (errors == 0) $display("%s%s%s", `CLR_GREEN, formatted_msg, `CLR_RESET);
        else             $display("%s%s%s", `CLR_RED, formatted_msg, `CLR_RESET);
        
        // Signale au master_tb que l'ALU a terminé pour lancer la suite
        -> master_tb.alu_is_done;
    end
endmodule

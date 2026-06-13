`timescale 1ns / 1ps
`define CLR_RESET  "\033[0m"
`define CLR_RED    "\033[1;31m"
`define CLR_GREEN  "\033[1;32m"
`define CLR_YELLOW "\033[1;33m"
`define CLR_BLUE   "\033[1;34m"

`define PERIOD 10




module regfile_tb;

    string formatted_msg_regfile;
    int errors = 0;
    int tests_run = 0;

    logic [31:0] in;
    logic [31:0] out1;
    logic [31:0] out2;

    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;

    logic RegWrite;
    logic clk = 0;
    logic rst;

    always
	#(`PERIOD/2) clk = ~clk;




    RegFile dut (
        .in(in),
        .out1(out1),
        .out2(out2),
        
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),

        .RegWrite(RegWrite),
        .clk(clk),
        .rst(rst)
    );

    // creation de la task

    task verification_regfile(
        input  logic [31:0] in_test,
        
        input  logic [4:0] rd_test,
        input  logic [4:0] rs1_test,
        input  logic [4:0] rs2_test,
        input  logic RegWrite_test,
        input  logic rst_test,
        
        input  logic [31:0] out1_expect, 
        input  logic [31:0] out2_expect
    );
        string ifwrite;
        begin 
            tests_run ++;
            
            in = in_test;
            rd = rd_test;
            rs1 = rs1_test;
            rs2 = rs2_test;
            RegWrite = RegWrite_test;
            rst = rst_test;
            #10;

            ifwrite = RegWrite ? $sformatf(":[Rd:%02h]=%08h", rd, in): "";

            if (out1 !== out1_expect || out2 !== out2_expect) begin
                formatted_msg_regfile = $sformatf("  [ ERROR ] Test %02d: Read[rs1 :%02h]=%08h;[rs2 :%02h]=%08h Write[%d]%s (but expected out1 : %08h, out2: %08h)",
                    tests_run, rs1, out1, rs2, out2,RegWrite, ifwrite, out1_expect, out2_expect);

                $display("%s%s%s", `CLR_RED, formatted_msg_regfile, `CLR_RESET);
                errors++;
            end else begin
                formatted_msg_regfile = $sformatf("  [SUCCESS] Test %02d: Read[rs1 :%02h]=%08h;[rs2 :%02h]=%08h Write[%d]%s",
                    tests_run, rs1, out1, rs2, out2,RegWrite, ifwrite);
                $display("%s%s%s", `CLR_GREEN, formatted_msg_regfile, `CLR_RESET);
            end
        end
    endtask



    initial begin
        // Attente de la fin du test ALU (remplace le délai manuel)
        @(master_tb.alu_is_done);
        
        // L'enregistrement VCD est maintenant géré par master_tb.sv

        formatted_msg_regfile = $sformatf("-- RegFile Test Bench --");
        $display("%s%s%s", `CLR_BLUE, formatted_msg_regfile, `CLR_RESET);
        rst = 0;

        // // ==========================================
        // // 1. Reseting and First write and read
        // // ==========================================
        // $display("* Testing Add :");
        // verification_regfile(32'h0000_0000, 5'h00, 5'h00, 5'h03, 0, 1, 32'h0000_0000, 32'h0000_0000);
        // verification_regfile(32'h0020_4000, 5'h01, 5'h01, 5'h00, 1, 0, 32'h0020_4000, 32'h0000_0000);
        // verification_regfile(32'h0000_0000, 5'h00, 5'h00, 5'h01, 0, 0, 32'h0000_0000, 32'h0020_4000);


        // these test created by AI
        // ==========================================
        // 1. Gestion du Reset
        // ==========================================
        $display("\n* Cas 1: Initialisation / Reset");
        verification_regfile(32'h0, 5'h00, 5'h00, 5'h05, 0, 1, 32'h0, 32'h0);

        // ==========================================
        // 2. Règle d'or RV32I : Le registre x0 doit rester à 0
        // ==========================================
        $display("\n* Cas 2: Écriture dans x0 (Doit rester à 0)");
        // Tentative d'écriture de 0xFFFF_FFFF dans x0
        verification_regfile(32'hFFFF_FFFF, 5'h00, 5'h00, 5'h00, 1, 0, 32'h0, 32'h0);

        // ==========================================
        // 3. Écritures et Lectures Basiques (Registres standards)
        // ==========================================
        $display("\n* Cas 3: Écritures et Lectures basiques");
        // Écriture dans x1 (0x12345678)
        verification_regfile(32'h1234_5678, 5'h01, 5'h00, 5'h00, 1, 0, 32'h0, 32'h0);
        // Écriture dans x2 (0xABCDEF01)
        verification_regfile(32'hABCD_EF01, 5'h02, 5'h00, 5'h00, 1, 0, 32'h0, 32'h0);
        // Lecture simultanée de x1 (rs1) et x2 (rs2)
        verification_regfile(32'h0, 5'h00, 5'h01, 5'h02, 0, 0, 32'h1234_5678, 32'hABCD_EF01);

        // ==========================================
        // 4. Vérification de l'interdiction d'écriture (RegWrite = 0)
        // ==========================================
        $display("\n* Cas 4: Tentative d'écriture sans autorisation (RegWrite=0)");
        // Tente d'écrire dans x1 avec RegWrite = 0
        verification_regfile(32'hDEAD_BEEF, 5'h01, 5'h01, 5'h02, 0, 0, 32'h1234_5678, 32'hABCD_EF01);

        // ==========================================
        // 5. Lecture et Écriture simultanée sur le même registre
        // ==========================================
        $display("\n* Cas 5: Écriture et Lecture simultanée (Même adresse)");
        // Écriture de 0x5555_5555 dans x3, tout en lisant x3.
        // Selon ton choix de design (transparent ou non), ajuste la valeur attendue.
        // Ici, on part du principe que la lecture est asynchrone (donnée mise à jour après le front d'horloge).
        verification_regfile(32'h5555_5555, 5'h03, 5'h03, 5'h00, 1, 0, 32'h5555_5555, 32'h0);

        // ==========================================
        // 6. Validation des limites des adresses (x31)
        // ==========================================
        $display("\n* Cas 6: Test du dernier registre (x31)");
        verification_regfile(32'hAAAA_BBBB, 5'd31, 5'd31, 5'h00, 1, 0, 32'hAAAA_BBBB, 32'h0);
        
        // ==========================================
        // Fin de la simulation
        // ==========================================
        
         formatted_msg_regfile = $sformatf("   END : %0d Tests executed | %0d Errors(s)", tests_run, errors);
        if (errors == 0) $display("%s%s%s", `CLR_GREEN, formatted_msg_regfile, `CLR_RESET);
        else             $display("%s%s%s", `CLR_RED, formatted_msg_regfile, `CLR_RESET);
        
        -> master_tb.regfile_is_done;
    end
endmodule

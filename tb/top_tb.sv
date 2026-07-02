`timescale 1ns / 1ps

`define CLR_RESET  "\033[0m"
`define CLR_RED    "\033[1;31m"
`define CLR_GREEN  "\033[1;32m"
`define CLR_BLUE   "\033[1;34m"

module top_tb;

    int errors = 0;
    int tests_run = 0;
    string formatted_msg;

    // Signaux de contrôle
    logic clk;
    logic rst;

    // Instanciation de ton processeur 
    top #(
        .PROG_FILE("programms/bin/stage6.hex") 
    ) dut (
        .clk(clk),
        .rst(rst)
    );

    // Génération de l'horloge (Période de 10ns)
    always #5 clk = ~clk;

    // ----------------------------------------------------------------------
    // Task de Vérification Automatique Adaptée au Délai Synchrone
    // ----------------------------------------------------------------------
    task automatic verify_register(
        input int          reg_idx,
        input logic [31:0] expected_val,
        input string       instr_str
    );
        logic [31:0] execution_pc;
        begin
            tests_run++;
            
            // 1. On capture le PC pendant que l'instruction est en train de s'exécuter
            execution_pc = dut.pc_pc; 
            
            // 2. On attend le front montant qui va valider l'écriture dans xreg
            @(posedge clk);
            #1; // Petit délai pour laisser l'affectation non-bloquante (<=) se mettre à jour

            // 3. Vérification du tiroir de registre
            if (dut.regs.xreg[reg_idx] !== expected_val) begin
                formatted_msg = $sformatf("   [FAIL] Test %02d | Instr: %-25s | x%0d = %08h (Attendu: %08h) | PC: %08h", 
                    tests_run, instr_str, reg_idx, dut.regs.xreg[reg_idx], expected_val, execution_pc);
                $display("%s%s%s", `CLR_RED, formatted_msg, `CLR_RESET);
                errors++;
            end else begin
                formatted_msg = $sformatf("   [OK]   Test %02d | Instr: %-25s | x%0d = %08h | PC: %08h", 
                    tests_run, instr_str, reg_idx, dut.regs.xreg[reg_idx], execution_pc);
                $display("%s%s%s", `CLR_GREEN, formatted_msg, `CLR_RESET);
            end
        end
    endtask

    // ----------------------------------------------------------------------
    // Séquence de Test
    // ----------------------------------------------------------------------
    initial begin
        // Attente du signal d'orchestration global
        @(master_tb.cu_is_done);
        $display("%s-- Démarrage de la vérification automatique du programme ALU --%s", `CLR_BLUE, `CLR_RESET);

        // Phase de Reset initial
        clk = 0;
        rst = 1;
        #20; 
        rst = 0; // Libération du processeur

        // AMORÇAGE : On attend le tout premier front d'horloge pour que la ROM 
        // charge l'instruction à l'adresse 0 et l'amène sur le décodeur.
        @(posedge clk);

        // --- Déroulement synchrone du programme d'instructions ---

        // 1. Test des immédiats (Type-I)
        verify_register(1, 32'd15,        "addi x1, x0, 15");
        verify_register(2, 32'hFFFF_FFFB, "addi x2, x0, -5"); // -5 en complément à deux

        // 2. Test des opérations Type-R
        verify_register(3, 32'd10,        "add x3, x1, x2");  // 15 + (-5) = 10
        verify_register(4, 32'd20,        "sub x4, x1, x2");  // 15 - (-5) = 20
        verify_register(5, 32'h0000_000B, "and x5, x1, x2");  // 15 & -5 = 11 (0x0B)
        verify_register(6, 32'hFFFF_FFFF, "or  x6, x1, x2");  // 15 | -5 = -1
        verify_register(7, 32'hFFFF_FFF4, "xor x7, x1, x2");  // 15 ^ -5 = -12

        // 3. Test des décalages
        verify_register(8, 32'd240,       "slli x8, x1, 4");  // 15 << 4 = 240
        verify_register(9, 32'hFFFF_FFFE, "srai x9, x2, 2");  // -5 >>> 2 = -2

        // ------------------------------------------------------------------
        // Bilan de fin de simulation
        // ------------------------------------------------------------------
        $display("\n%s==================================================%s", `CLR_BLUE, `CLR_RESET);
        formatted_msg = $sformatf("   BILAN : %0d Tests exécutés | %0d Erreur(s)", tests_run, errors);
        
        if (errors == 0) begin
            $display("%s%s%s", `CLR_GREEN, formatted_msg, `CLR_RESET);
            $display("%s   [SUCCESS] Le datapath ALU fonctionne parfaitement !%s", `CLR_GREEN, `CLR_RESET);
        end else begin
            $display("%s%s%s", `CLR_RED, formatted_msg, `CLR_RESET);
            $display("%s   [FAIL] Des divergences ont été détectées dans le traitement.%s", `CLR_RED, `CLR_RESET);
        end
        $display("%s==================================================%s", `CLR_BLUE, `CLR_RESET);

        -> master_tb.top_is_done;
    end

endmodule
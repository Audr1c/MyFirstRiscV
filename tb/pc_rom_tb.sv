`define CLR_RESET  "\033[0m"
`define CLR_RED    "\033[1;31m"
`define CLR_GREEN  "\033[1;32m"
`define CLR_YELLOW "\033[1;33m"
`define CLR_BLUE   "\033[1;34m"

`define PERIOD 10

`timescale 1ns / 1ps
string formatted_msg_pc;

module pc_tb;

    int errors = 0;
    int tests_run = 0;

    // ----------------------------------------------------------------------
    // Signals
    // ----------------------------------------------------------------------
    logic clk = 0;
    logic rst;
    logic  [31:0] new_pc;
    logic override;
    logic  [31:0] pc;
    logic  [31:0] instruction;

    always
        #(`PERIOD/2) clk = ~clk;

    // ----------------------------------------------------------------------
    // DUT Instantiation
    // ----------------------------------------------------------------------
    pc dut_pc (
        .clk      (clk),
        .rst      (rst),
        .new_pc   (new_pc),
        .override (override),
        .pc       (pc)
    );


     rom #(
            .PROG_FILE("programms/prog_pc_rom_tb.txt") 
     ) dut_rom (
        .pc  (pc),
        .clk (clk),
        .rst (rst),
        .out (instruction)
    );

    // ----------------------------------------------------------------------
    // Verification Task
    // ----------------------------------------------------------------------
    task check_state(
        input  logic [31:0] pc_expect,
        input  logic [31:0] instruction_expect
    );
        begin
            tests_run++;

            if (pc !== pc_expect || instruction !== instruction_expect) begin
                formatted_msg_pc = $sformatf("  [ ERROR ] Test %02d: Actual pc:%08h inst:%08h (Expected pc:%08h inst:%08h)",
                    tests_run, pc, instruction, pc_expect, instruction_expect);
                $display("%s%s%s", `CLR_RED, formatted_msg_pc, `CLR_RESET);
                errors++;
            end else begin
                formatted_msg_pc = $sformatf("  [SUCCESS] Test %02d: pc:%08h inst:%08h",
                    tests_run, pc, instruction);
                $display("%s%s%s", `CLR_GREEN, formatted_msg_pc, `CLR_RESET);
            end
        end
    endtask

    initial begin
        // Wait for master start trigger
        @(master_tb.regfile_is_done);

        formatted_msg_pc = $sformatf("-- PC & ROM Test Bench --");
        $display("%s%s%s", `CLR_BLUE, formatted_msg_pc, `CLR_RESET);
        
        rst = 1;
        override = 0;
        new_pc = 0;
        @(negedge clk);
        rst = 0;

        // ==========================================
        // 1. Initial Test Cases (0 to 15)
        // ==========================================
        $display("* Check first 16 values (PC increments automatically)");
        for (int i = 0; i < 16; i++) begin
            @(negedge clk);
            // La ROM étant synchrone, elle met à jour sa valeur avec 1 cycle de retard
            // Ainsi, lorsque l'instruction correspond à l'adresse 'i', le PC a déjà
            // pris la valeur 'i + 1' sur le front d'horloge.
            check_state(i + 1, i * 32'h11111111);
        end

        // ==========================================
        // 2. Jump to 0x100
        // ==========================================
        $display("\n* Jump to 0x100 and check ABCD1234");
        @(negedge clk);
        override = 1;
        new_pc = 32'h100;
        @(negedge clk);
        override = 0;
        @(negedge clk); // Laisse 1 cycle supplémentaire à la ROM pour lire la nouvelle adresse
        check_state(32'h101, 32'hABCD1234);

        // ==========================================
        // 3. Jump to 0x3FE
        // ==========================================
        $display("\n* Jump to last address 0x3FE and check BABABABA");
        @(negedge clk);
        override = 1;
        new_pc = 32'h3FE;
        @(negedge clk);
        override = 0;
        @(negedge clk);
        check_state(32'h3FF, 32'hBABABABA);

        // ==========================================
        // End of Simulation
        // ==========================================
        formatted_msg_pc = $sformatf("   END : %0d Tests executed | %0d Errors(s)", tests_run, errors);
        if (errors == 0) $display("%s%s%s", `CLR_GREEN, formatted_msg_pc, `CLR_RESET);
        else             $display("%s%s%s", `CLR_RED, formatted_msg_pc, `CLR_RESET);

        // Trigger completion event in master
        // Note : Assure-toi que "event pc_is_done;" est déclaré dans master_tb.sv si tu dé-commentes ceci
        -> master_tb.pc_rom_is_done;

    end

endmodule
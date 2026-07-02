`timescale 1ns / 1ps
// integer idx;
module master_tb;

    // Événement global pour synchroniser la séquence des tests
    event master_is_done;
    event alu_is_done;
    event regfile_is_done;
    event pc_rom_is_done;
    event decoder_is_done;
    event cu_is_done;
    event top_is_done;

    // Instanciation de tes deux bancs de test en tant que sous-modules
    alu_tb     u_alu_tb();
    regfile_tb u_regfile_tb();
    pc_tb u_pc_rom_tb();
    decoder_tb u_decoder_tb();
    ControlUnit_tb u_cu_tb();
    top_tb u_top_tb();
    

    initial begin
        $dumpfile("build/simulation.fst");
        $dumpvars(0, master_tb); // Enregistre tous les signaux de toute la hiérarchie
        // Force l'affichage de chaque élément du tableau
        // for (integer idx = 1; idx <= 31; idx = idx + 1) begin
            // $dumpvars(0, master_tb.u_top_tb.dut.regs.xreg);
            $dumpvars(0, master_tb.u_top_tb.dut.regs.xreg[1]);
            $dumpvars(0, master_tb.u_top_tb.dut.regs.xreg[2]);
            $dumpvars(0, master_tb.u_top_tb.dut.regs.xreg[3]);
            $dumpvars(0, master_tb.u_top_tb.dut.regs.xreg[4]);
            $dumpvars(0, master_tb.u_top_tb.dut.regs.xreg[5]);
            $dumpvars(0, master_tb.u_top_tb.dut.regs.xreg[6]);
            $dumpvars(0, master_tb.u_top_tb.dut.regs.xreg[7]);
            $dumpvars(0, master_tb.u_top_tb.dut.regs.xreg[8]);
            $dumpvars(0, master_tb.u_top_tb.dut.regs.xreg[9]);
            $dumpvars(0, master_tb.u_top_tb.dut.regs.xreg[10]);
            $dumpvars(0, master_tb.u_top_tb.dut.regs.xreg[11]);
            $dumpvars(0, master_tb.u_top_tb.dut.regs.xreg[12]);
        // end
        -> master_is_done;
        @(alu_is_done);
        @(regfile_is_done);
        @(pc_rom_is_done);
        @(decoder_is_done);
        @(cu_is_done);
        @(top_is_done);
        #100;
        $finish;
    end
endmodule
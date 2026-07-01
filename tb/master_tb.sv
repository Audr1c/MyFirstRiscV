`timescale 1ns / 1ps

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
        $dumpfile("build/simulation.vcd");
        $dumpvars(0, master_tb); // Enregistre tous les signaux de toute la hiérarchie
        -> master_is_done;
        @(alu_is_done);
        @(regfile_is_done);
        @(pc_rom_is_done);
        @(decoder_is_done);
        @(cu_is_done);
        @(top_is_done);
        $finish;
    end
endmodule
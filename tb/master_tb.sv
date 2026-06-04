`timescale 1ns / 1ps

module master_tb;

    // Événement global pour synchroniser la séquence des tests
    event alu_is_done;

    // Instanciation de tes deux bancs de test en tant que sous-modules
    alu_tb     u_alu_tb();
    regfile_tb u_regfile_tb();

    initial begin
        $dumpfile("build/simulation.vcd");
        $dumpvars(0, master_tb); // Enregistre tous les signaux de toute la hiérarchie
    end
endmodule
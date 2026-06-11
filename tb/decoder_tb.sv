`define CLR_RESET  "\033[0m"
`define CLR_RED    "\033[1;31m"
`define CLR_GREEN  "\033[1;32m"
`define CLR_YELLOW "\033[1;33m"
`define CLR_BLUE   "\033[1;34m"

`timescale 1ns / 1ps
string formatted_msg_decoder;

module decoder_tb;

    int errors = 0;
    int tests_run = 0;

    // ----------------------------------------------------------------------
    // Signals
    // ----------------------------------------------------------------------
    logic  [31:0] instruction;
    logic  [6:0] OpCode;
    logic  [4:0] rd;
    logic  [4:0] rs1;
    logic  [4:0] rs2;
    logic  [2:0] funct3;
    logic  [6:0] funct7;
    logic  [31:0] imm;

    // ----------------------------------------------------------------------
    // DUT Instantiation
    // ----------------------------------------------------------------------
    decoder dut (
        .instruction (instruction),
        .OpCode      (OpCode),
        .rd          (rd),
        .rs1         (rs1),
        .rs2         (rs2),
        .funct3      (funct3),
        .funct7      (funct7),
        .imm         (imm)
    );

    // ----------------------------------------------------------------------
    // Verification Task
    // ----------------------------------------------------------------------
    task verification_decoder(
        input  logic  [31:0]instruction_test,
        input  logic  [6:0]OpCode_expect,
        input  logic  [4:0]rd_expect,
        input  logic  [4:0]rs1_expect,
        input  logic  [4:0]rs2_expect,
        input  logic  [2:0]funct3_expect,
        input  logic  [6:0]funct7_expect,
        input  logic  [31:0]imm_expect
    );
        begin
            tests_run++;

            // Apply inputs
            instruction = instruction_test;
            #10;

            if (OpCode !== OpCode_expect || rd !== rd_expect || rs1 !== rs1_expect || rs2 !== rs2_expect || funct3 !== funct3_expect || funct7 !== funct7_expect || imm !== imm_expect) begin
                formatted_msg_decoder = $sformatf("  [ ERROR ] Test %02d: instruction:%h | Actual OpCode:%h (Expected:%h), Actual rd:%h (Expected:%h), Actual rs1:%h (Expected:%h), Actual rs2:%h (Expected:%h), Actual funct3:%h (Expected:%h), Actual funct7:%h (Expected:%h), Actual imm:%h (Expected:%h)",
                    tests_run, instruction_test, OpCode, OpCode_expect, rd, rd_expect, rs1, rs1_expect, rs2, rs2_expect, funct3, funct3_expect, funct7, funct7_expect, imm, imm_expect);
                $display("%s%s%s", `CLR_RED, formatted_msg_decoder, `CLR_RESET);
                errors++;
            end else begin
                formatted_msg_decoder = $sformatf("  [SUCCESS] Test %02d: instruction:%h = OpCode:%h, rd:%h, rs1:%h, rs2:%h, funct3:%h, funct7:%h, imm:%h",
                    tests_run, instruction_test, OpCode, rd, rs1, rs2, funct3, funct7, imm);
                $display("%s%s%s", `CLR_GREEN, formatted_msg_decoder, `CLR_RESET);
            end
        end
    endtask

    initial begin
        // Wait for master start trigger
        @(master_tb.pc_rom_is_done);

        formatted_msg_decoder = $sformatf("-- decoder Test Bench --");
        $display("%s%s%s", `CLR_BLUE, formatted_msg_decoder, `CLR_RESET);

        // ==========================================
        // 1. Test Cases - RV32I Validation
        // ==========================================
        $display("* Running test cases...");

        // --- TYPE R ---
        $display(" -- Type R --");
        // test 1
        // ADD r3, r1, r2 (0x002081B3) -> rd=3, rs1=1, rs2=2, funct3=0, funct7=00, opcode=33
        verification_decoder(32'h002081B3, 7'h33, 5'd3, 5'd1, 5'd2, 3'h0, 7'h00, 32'h0);
        
        // test 2
        // SUB r5, r10, r11 (0x40B502B3) -> rd=5, rs1=10, rs2=11, funct3=0, funct7=20, opcode=33
        verification_decoder(32'h40B502B3, 7'h33, 5'd5, 5'd10, 5'd11, 3'h0, 7'h20, 32'h0);
        
        // test 3
        // SRL r4, r5, r6 (0x0062D233) -> rd=4, rs1=5, rs2=6, funct3=5, funct7=00, opcode=33
        verification_decoder(32'h0062D233, 7'h33, 5'd4, 5'd5, 5'd6, 3'h5, 7'h00, 32'h0);

        // test 4
        // --- TYPE I (Arithmétique immédiate) ---
        $display(" -- Type I1 --");
        // ADDI r1, r0, 0 (0x00000093) -> rd=1, rs1=0, imm=0, funct3=0, opcode=13
        verification_decoder(32'h00000093, 7'h13, 5'd1, 5'd0, 5'd0, 3'h0, 7'h00, 32'd0);
        
        // test 5
        // ADDI r2, r4, 5 (0x00520113) -> rd=2, rs1=4, imm=5, funct3=0, opcode=13
        verification_decoder(32'h00520113, 7'h13, 5'd2, 5'd4, 5'd0, 3'h0, 7'h00, 32'd5);
        
        // test 6
        // ADDI r5, r6, -1 (0xFFF30293) -> Ext. de signe max négatif (-1) -> imm=32'hFFFFFFFF
        verification_decoder(32'hFFF30293, 7'h13, 5'd5, 5'd6, 5'd0, 3'h0, 7'h00, 32'hFFFFFFFF);
        
        // test 7
        // ANDI r10, r11, 2047 (0x7FF5F513) -> Imm max positif (2047) -> imm=32'h000007FF
        verification_decoder(32'h7FF5F513, 7'h13, 5'd10, 5'd11, 5'd0, 3'h7, 7'h00, 32'h000007FF);
        
        // test 8
        // SRAI r12, r13, -2048 (0x8006D613) -> Imm max négatif (-2048) -> imm=32'hFFFFF800
        verification_decoder(32'h8006D613, 7'h13, 5'd12, 5'd13, 5'd0, 3'h5, 7'h00, 32'hFFFFF800);

        // test 9
        // --- TYPE I (Loads & JALR) ---
        $display(" -- Type I2 --");
        // LW r4, 16(s1) (0x0104A203) -> rs1=9, rd=4, imm=16, funct3=2, opcode=03
        verification_decoder(32'h0104A203, 7'h03, 5'd4, 5'd9, 5'd0, 3'h2, 7'h00, 32'd16);
        
        // test 10
        // LBU r8, -4(r9) (0xFFC4C403) -> rs1=9, rd=8, imm=-4 (32'hFFFFFFFC), funct3=4, opcode=03
        verification_decoder(32'hFFC4C403, 7'h03, 5'd8, 5'd9, 5'd0, 3'h4, 7'h00, 32'hFFFFFFFC);

        // test 11
        // JALR r1, 0(r5) (0x000280E7) -> rd=1, rs1=5, imm=0, funct3=0, opcode=67
        verification_decoder(32'h000280E7, 7'h67, 5'd1, 5'd5, 5'd0, 3'h0, 7'h00, 32'h0);

        // --- TYPE S (Stores) ---
        $display("-- Type S --");
        // test 12
        // SW r2, 8(r1) (0x0020A423) -> rs1=1, rs2=2, imm=8, funct3=2, opcode=23
        verification_decoder(32'h0020A423, 7'h23, 5'd0, 5'd1, 5'd2, 3'h2, 7'h00, 32'd8);
        
        // test 13
        // SB r7, -1(r3) (0xFE718FA3) -> rs1=3, rs2=7, imm=-1 (32'hFFFFFFFF), funct3=0, opcode=23
        // Note: imm[11:5]=7'h7F, imm[4:0]=5'h1F
        verification_decoder(32'hFE718FA3, 7'h23, 5'd0, 5'd3, 5'd7, 3'h0, 7'h00, 32'hFFFFFFFF);

        // --- TYPE B (Branches - Reconstruction d'immédiat complexe) ---
        $display("-- Type B --");
        // test 14
        // BEQ r1, r2, 16 (0x00208863) -> rs1=1, rs2=2, imm=16, funct3=0, opcode=63
        // imm[12]=0, imm[11]=0, imm[10:5]=000000, imm[4:1]=1000, imm[0]=0
        verification_decoder(32'h00208863, 7'h63, 5'd0, 5'd1, 5'd2, 3'h0, 7'h00, 32'd16);
        
        // test 15
        // BNE r10, r11, -8 (0xFEB51CE3) -> rs1=10, rs2=11, imm=-8 (32'hFFFFFFF8)
        verification_decoder(32'hFEB51CE3, 7'h63, 5'd0, 5'd10, 5'd11, 3'h1, 7'h00, 32'hFFFFFFF8);

        // --- TYPE U ---
        $display("-- Type U --");
        // test 16
        // LUI r5, 0x12345 (0x123452B7) -> rd=5, imm=0x12345000, opcode=37
        verification_decoder(32'h123452B7, 7'h37, 5'd5, 5'd0, 5'd0, 3'h0, 7'h00, 32'h12345000);
        
        // test 17
        // AUIPC r10, 0x00000 (0x00000517) -> rd=10, imm=0, opcode=17
        verification_decoder(32'h00000517, 7'h17, 5'd10, 5'd0, 5'd0, 3'h0, 7'h00, 32'h0);

        // --- TYPE J (Sauts - Reconstruction d'immédiat entrelacé) ---
        $display("-- Type J --");
        // test 18
        // JAL r1, 2048 (0x080000ef) -> rd=1, imm=2048 (32'h00000800), opcode=6F
        verification_decoder(32'h080000EF, 7'h6F, 5'd1, 5'd0, 5'd0, 3'h0, 7'h00, 32'h00000080);
        
        // test 19
        // JAL r0, -4 (0xFFDFF06F) -> rd=0 (J), imm=-4 (32'hFFFFFFFC), opcode=6F
        verification_decoder(32'hFFDFF06F, 7'h6F, 5'd0, 5'd0, 5'd0, 3'h0, 7'h00, 32'hFFFFFFFC);
        // ==========================================
        // End of Simulation
        // ==========================================
        formatted_msg_decoder = $sformatf("   END : %0d Tests executed | %0d Errors(s)", tests_run, errors);
        if (errors == 0) $display("%s%s%s", `CLR_GREEN, formatted_msg_decoder, `CLR_RESET);
        else             $display("%s%s%s", `CLR_RED, formatted_msg_decoder, `CLR_RESET);

        // Trigger completion event in master
        -> master_tb.decoder_is_done;

    end

endmodule
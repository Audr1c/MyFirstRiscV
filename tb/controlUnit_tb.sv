`timescale 1ns / 1ps
`define CLR_RESET  "\033[0m"
`define CLR_RED    "\033[1;31m"
`define CLR_GREEN  "\033[1;32m"
`define CLR_YELLOW "\033[1;33m"
`define CLR_BLUE   "\033[1;34m"

string formatted_msg_ControlUnit;
import alu_pkg::*;
import op_codes_pkg::*;

module ControlUnit_tb;

    int errors = 0;
    int tests_run = 0;

    // ----------------------------------------------------------------------
    // Signals
    // ----------------------------------------------------------------------
    logic  [31:0] instruction;
    logic regWrite;
    logic ALU_src;
    logic  [3:0] alu_ctrl;
    logic MemWrite;
    logic MemSrc;
    logic MemToReg;
    logic PCsrc;

    // ----------------------------------------------------------------------
    // DUT Instantiation
    // ----------------------------------------------------------------------
    ControlUnit dut (
        .instruction (instruction),
        .regWrite    (regWrite),
        .ALU_src     (ALU_src),
        .alu_ctrl    (alu_ctrl),
        .MemWrite    (MemWrite),
        .MemSrc      (MemSrc),
        .MemToReg    (MemToReg),
        .PCsrc       (PCsrc)
    );

    // ----------------------------------------------------------------------
    // Verification Task
    // ----------------------------------------------------------------------
    task verification_ControlUnit(
        input  logic [31:0] instruction_test,
        input  logic regWrite_expect,
        input  logic       ALU_src_expect,
        input  logic [3:0] alu_ctrl_expect,
        input  logic       MemWrite_expect,
        input  logic       MemSrc_expect,
        input  logic       MemToReg_expect,
        input  logic       PCsrc_expect,
        input  string      instr
    );
        begin
            tests_run++;

            // Apply inputs
            instruction = instruction_test;
            #10;

            if (regWrite !== regWrite_expect || ALU_src !== ALU_src_expect || alu_ctrl !== alu_ctrl_expect || MemWrite !== MemWrite_expect || MemSrc !== MemSrc_expect || MemToReg !== MemToReg_expect || PCsrc !== PCsrc_expect) begin
                formatted_msg_ControlUnit = $sformatf("  [FAIL] Test %02d | Instr: %-20s (%08h)\n         Expected -> RWr:%b ALUSrc:%b ALUCtrl:%h MemWr:%b MemSrc:%b MemToReg:%b PCSrc:%b\n         Actual   -> RWr:%b ALUSrc:%b ALUCtrl:%h MemWr:%b MemSrc:%b MemToReg:%b PCSrc:%b",
                    tests_run, instr, instruction_test,
                    regWrite_expect, ALU_src_expect, alu_ctrl_expect, MemWrite_expect, MemSrc_expect, MemToReg_expect, PCsrc_expect,
                    regWrite, ALU_src, alu_ctrl, MemWrite, MemSrc, MemToReg, PCsrc);
                $display("%s%s%s", `CLR_RED, formatted_msg_ControlUnit, `CLR_RESET);
                errors++;
            end else begin
                formatted_msg_ControlUnit = $sformatf("  [OK]   Test %02d | Instr: %-20s (%08h) | RWr:%b ALUSrc:%b ALUCtrl:%h MemWr:%b MemSrc:%b MemToReg:%b PCSrc:%b",
                    tests_run, instr, instruction_test, regWrite, ALU_src, alu_ctrl, MemWrite, MemSrc, MemToReg, PCsrc);
                $display("%s%s%s", `CLR_GREEN, formatted_msg_ControlUnit, `CLR_RESET);
            end
        end
    endtask

    initial begin
        
        @(master_tb.decoder_is_done);
        formatted_msg_ControlUnit = $sformatf("-- Control Unit Test Bench --");
        $display("%s%s%s", `CLR_BLUE, formatted_msg_ControlUnit, `CLR_RESET);
        // Warning by default
        // $display("%s[ WARNING ] Test cases not implemented!%s", `CLR_RED, `CLR_RESET);

        // ------------------------------------------------------------------
        // FORMATS U-type & J-type
        // ------------------------------------------------------------------
        // LUI      (opcode: 0110111)
        verification_ControlUnit(32'h00001537, 1, 1, 4'h0, 0, 0, 0, 0, "LUI x10, 0x1");
        // AUIPC    (opcode: 0010111)
        verification_ControlUnit(32'h00001517, 1, 1, 4'h0, 0, 0, 0, 0, "AUIPC x10, 0x1");
        // JAL      (opcode: 1101111)
        verification_ControlUnit(32'h000000ef, 1, 0, 4'h0, 0, 0, 0, 1, "JAL x1, 0");

        // ------------------------------------------------------------------
        // FORMAT I-type (Sauts & Loads)
        // ------------------------------------------------------------------
        // JALR     (opcode: 1100111, funct3: 000)
        verification_ControlUnit(32'h000000e7, 1, 1, 4'h0, 0, 0, 0, 1, "JALR x1, x0, 0");
        // LB       (opcode: 0000011, funct3: 000)
        verification_ControlUnit(32'h00000003, 1, 1, LS_LSB, 0, 0, 1, 0, "LB x0, 0(x0)");
        // LH       (opcode: 0000011, funct3: 001)
        verification_ControlUnit(32'h00001003, 1, 1, LS_LSH, 0, 0, 1, 0, "LH x0, 0(x0)");
        // LW       (opcode: 0000011, funct3: 010)
        verification_ControlUnit(32'h00002003, 1, 1, LS_LSW, 0, 0, 1, 0, "LW x0, 0(x0)");
        // LBU      (opcode: 0000011, funct3: 100)
        verification_ControlUnit(32'h00004003, 1, 1, LS_LBU, 0, 0, 1, 0, "LBU x0, 0(x0)");
        // LHU      (opcode: 0000011, funct3: 101)
        verification_ControlUnit(32'h00005003, 1, 1, LS_LHU, 0, 0, 1, 0, "LHU x0, 0(x0)");

        // ------------------------------------------------------------------
        // FORMAT B-type (Branches) -> Opcode: 1100011
        // ------------------------------------------------------------------
        // BEQ      (funct3: 000)
        verification_ControlUnit(32'h00000063, 0, 0, BR_BEQ, 0, 0, 0, 1, "BEQ x0, x0, 0");
        // BNE      (funct3: 001)
        verification_ControlUnit(32'h00001063, 0, 0, BR_BNE, 0, 0, 0, 1, "BNE x0, x0, 0");
        // BLT      (funct3: 100)
        verification_ControlUnit(32'h00004063, 0, 0, BR_BLT, 0, 0, 0, 1, "BLT x0, x0, 0");
        // BGE      (funct3: 101)
        verification_ControlUnit(32'h00005063, 0, 0, BR_BGE, 0, 0, 0, 1, "BGE x0, x0, 0");
        // BLTU     (funct3: 110)
        verification_ControlUnit(32'h00006063, 0, 0, BR_BLTU, 0, 0, 0, 1, "BLTU x0, x0, 0");
        // BGEU     (funct3: 111)
        verification_ControlUnit(32'h00007063, 0, 0, BR_BGEU, 0, 0, 0, 1, "BGEU x0, x0, 0");

        // ------------------------------------------------------------------
        // FORMAT S-type (Stores) -> Opcode: 0100011
        // ------------------------------------------------------------------
        // SB       (funct3: 000)
        verification_ControlUnit(32'h00000023, 0, 1, LS_LSB, 1, 0, 0, 0, "SB x0, 0(x0)");
        // SH       (funct3: 001)
        verification_ControlUnit(32'h00001023, 0, 1, LS_LSH, 1, 0, 0, 0, "SH x0, 0(x0)");
        // SW       (funct3: 010)
        verification_ControlUnit(32'h00002023, 0, 1, LS_LSW, 1, 0, 0, 0, "SW x0, 0(x0)");

        // ------------------------------------------------------------------
        // FORMAT I-type (ALU Imm) -> Opcode: 0010011
        // ------------------------------------------------------------------
        // ADDI     (funct3: 000)
        verification_ControlUnit(32'h00000013, 1, 1, ALU_ADD, 0, 0, 0, 0, "ADDI x0, x0, 0");
        // SLTI     (funct3: 010)
        verification_ControlUnit(32'h00002013, 1, 1, ALU_SLT, 0, 0, 0, 0, "SLTI x0, x0, 0");
        // SLTIU    (funct3: 011)
        verification_ControlUnit(32'h00003013, 1, 1, ALU_SLTU, 0, 0, 0, 0, "SLTIU x0, x0, 0");
        // XORI     (funct3: 100)
        verification_ControlUnit(32'h00004013, 1, 1, ALU_XOR, 0, 0, 0, 0, "XORI x0, x0, 0");
        // ORI      (funct3: 110)
        verification_ControlUnit(32'h00006013, 1, 1, ALU_OR, 0, 0, 0, 0, "ORI x0, x0, 0");
        // ANDI     (funct3: 111)
        verification_ControlUnit(32'h00007013, 1, 1, ALU_AND, 0, 0, 0, 0, "ANDI x0, x0, 0");
        // SLLI     (funct3: 001, funct7: 0000000)
        verification_ControlUnit(32'h00001013, 1, 1, ALU_SLL, 0, 0, 0, 0, "SLLI x0, x0, 0");
        // SRLI     (funct3: 101, funct7: 0000000)
        verification_ControlUnit(32'h00005013, 1, 1, ALU_SRL, 0, 0, 0, 0, "SRLI x0, x0, 0");
        // SRAI     (funct3: 101, funct7: 0100000)
        verification_ControlUnit(32'h40005013, 1, 1, ALU_SRA, 0, 0, 0, 0, "SRAI x0, x0, 0");

        // ------------------------------------------------------------------
        // FORMAT R-type (ALU Reg-Reg) -> Opcode: 0110011
        // ------------------------------------------------------------------
        // ADD      (funct3: 000, funct7: 0000000)
        verification_ControlUnit(32'h00000033, 1, 0, ALU_ADD, 0, 0, 0, 0, "ADD x0, x0, x0");
        // SUB      (funct3: 000, funct7: 0100000)
        verification_ControlUnit(32'h40000033, 1, 0, ALU_SUB, 0, 0, 0, 0, "SUB x0, x0, x0");
        // SLL      (funct3: 001, funct7: 0000000)
        verification_ControlUnit(32'h00001033, 1, 0, ALU_SLL, 0, 0, 0, 0, "SLL x0, x0, x0");
        // SLT      (funct3: 010, funct7: 0000000)
        verification_ControlUnit(32'h00002033, 1, 0, ALU_SLT, 0, 0, 0, 0, "SLT x0, x0, x0");
        // SLTU     (funct3: 011, funct7: 0000000)
        verification_ControlUnit(32'h00003033, 1, 0, ALU_SLTU, 0, 0, 0, 0, "SLTU x0, x0, x0");
        // XOR      (funct3: 100, funct7: 0000000)
        verification_ControlUnit(32'h00004033, 1, 0, ALU_XOR, 0, 0, 0, 0, "XOR x0, x0, x0");
        // SRL      (funct3: 101, funct7: 0000000)
        verification_ControlUnit(32'h00005033, 1, 0, ALU_SRL, 0, 0, 0, 0, "SRL x0, x0, x0");
        // SRA      (funct3: 101, funct7: 0100000)
        verification_ControlUnit(32'h40005033, 1, 0, ALU_SRA, 0, 0, 0, 0, "SRA x0, x0, x0");
        // OR       (funct3: 110, funct7: 0000000)
        verification_ControlUnit(32'h00006033, 1, 0, ALU_OR, 0, 0, 0, 0, "OR x0, x0, x0");
        // AND      (funct3: 111, funct7: 0000000)
        verification_ControlUnit(32'h00007033, 1, 0, ALU_AND, 0, 0, 0, 0, "AND x0, x0, x0");

        // ------------------------------------------------------------------
        // SYSTEM & FENCES
        // ------------------------------------------------------------------
        // FENCE    (opcode: 0001111)
        verification_ControlUnit(32'h0000000f, 0, 0, 4'h0, 0, 0, 0, 0, "FENCE");
        // ECALL    (opcode: 1110011)
        verification_ControlUnit(32'h00000073, 0, 0, 4'h0, 0, 0, 0, 0, "ECALL");
        // EBREAK   (opcode: 1110011, imm: 1)
        verification_ControlUnit(32'h00100073, 0, 0, 4'h0, 0, 0, 0, 0, "EBREAK");

        // ------------------------------------------------------------------
        // End of Simulation
        // ------------------------------------------------------------------
        formatted_msg_ControlUnit = $sformatf("   END : %0d Tests executed | %0d Errors(s)", tests_run, errors);
        if (errors == 0) $display("%s%s%s", `CLR_GREEN, formatted_msg_ControlUnit, `CLR_RESET);
        else             $display("%s%s%s", `CLR_RED, formatted_msg_ControlUnit, `CLR_RESET);

        ->master_tb.cu_is_done;
    end

endmodule
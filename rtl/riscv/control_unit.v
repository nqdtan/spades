`include "Opcode.vh"

module control_unit(
  input [31:0] cpu_inst,
  input [31:0] cpu_inst_stg1,
  input [31:0] cpu_inst_stg2,
  input [31:0] cpu_inst_stg3,
  input [31:0] cpu_inst_stg4,

  input reg_wen_stg1,
  input reg_wen_stg2,
  input reg_wen_stg3,
  input reg_wen_stg4,

  output pc_sel,
  output [2:0] imm_sel,
  output reg_wen,

  output br_un,
  input  br_eq,
  input  br_lt,

  output bsel,
  output asel,

  // Hazards
  output a_fwd_0,
  output a_fwd_1,
  output b_fwd_0,
  output b_fwd_1,
  output a_fwd_2,
  output b_fwd_2,
  output a_fwd_3,
  output b_fwd_3,

  output load_hazard_3,

  output [2:0] alu_sel0, // ALU op select
  output alu_sel1,       // Add_RShift type
  output bcopy,

  output [3:0] mem_rw,

  output [1:0] wb_sel
);
  reg [2:0] alu_sel0_comb;
  reg       alu_sel1_comb;
  reg       asel_comb, bsel_comb;
  reg       pc_sel_comb;
  reg [2:0] imm_sel_comb;
  reg       reg_wen_comb;
  reg       br_un_comb;
  reg [3:0] mem_rw_comb;
  reg [1:0] wb_sel_comb;
  reg       bcopy_comb;
  reg       rf_ra1_ren_comb, rf_ra2_ren_comb;

  assign alu_sel0 = alu_sel0_comb;
  assign alu_sel1 = alu_sel1_comb;
  assign asel     = asel_comb;
  assign bsel     = bsel_comb;
  assign imm_sel  = imm_sel_comb;
  assign reg_wen  = reg_wen_comb;
  assign br_un    = br_un_comb;
  assign mem_rw   = mem_rw_comb;
  assign wb_sel   = wb_sel_comb;
  assign pc_sel   = pc_sel_comb;
  assign bcopy    = bcopy_comb;

  wire [2:0] funct3 = cpu_inst[14:12];
  wire [6:0] opcode = cpu_inst[6:0];
  wire [4:0] ra1    = cpu_inst[19:15];
  wire [4:0] ra2    = cpu_inst[24:20];

  wire [6:0] opcode_stg1 = cpu_inst_stg1[6:0];
  wire [6:0] opcode_stg2 = cpu_inst_stg2[6:0];
  wire [6:0] opcode_stg3 = cpu_inst_stg3[6:0];
  wire [6:0] opcode_stg4 = cpu_inst_stg4[6:0];

  wire [4:0] wa_stg1 = cpu_inst_stg1[11:7];
  wire [4:0] wa_stg2 = cpu_inst_stg2[11:7];

  wire [2:0] funct3_stg1 = cpu_inst_stg1[14:12];

  wire [4:0] wa_stg3 = cpu_inst_stg3[11:7];
  wire [4:0] wa_stg4 = cpu_inst_stg4[11:7];

  // Data hazard: forwarding data from ALU
  assign a_fwd_0 = (reg_wen_stg1 & ra1 == wa_stg1 & ra1 != 0);
  assign b_fwd_0 = (reg_wen_stg1 & ra2 == wa_stg1 & ra2 != 0);

  assign a_fwd_1 = (reg_wen_stg2 & ra1 == wa_stg2 & ra1 != 0);
  assign b_fwd_1 = (reg_wen_stg2 & ra2 == wa_stg2 & ra2 != 0);

  assign a_fwd_2 = (reg_wen_stg3 & ra1 == wa_stg3 & ra1 != 0);
  assign b_fwd_2 = (reg_wen_stg3 & ra2 == wa_stg3 & ra2 != 0);

  assign a_fwd_3 = (reg_wen_stg4 & ra1 == wa_stg4 & ra1 != 0);
  assign b_fwd_3 = (reg_wen_stg4 & ra2 == wa_stg4 & ra2 != 0);

  // Load hazard
  assign load_hazard_3 = (opcode_stg3 == `OPC_LOAD) &
                         ((ra1 == wa_stg3 & ra1 != 0 & rf_ra1_ren_comb) |
                          (ra2 == wa_stg3 & ra2 != 0 & rf_ra2_ren_comb));

  always @(*) begin
    alu_sel0_comb   = 3'b0;
    alu_sel1_comb   = 1'b0;
    asel_comb       = 1'b0;
    bsel_comb       = 1'b0;
    imm_sel_comb    = 3'b0;
    reg_wen_comb    = 1'b0;
    br_un_comb      = 1'b0;
    wb_sel_comb     = 2'b0;
    bcopy_comb      = 1'b0;
    rf_ra1_ren_comb = 1'b0;
    rf_ra2_ren_comb = 1'b0;
    mem_rw_comb     = 4'b0;

    case (opcode)
      `OPC_CSR: begin
        if (funct3 == `FNC_CSRRW) begin
          rf_ra1_ren_comb = 1'b1;
          rf_ra2_ren_comb = 1'b0;
        end
      end

      // Special immediate instructions
      `OPC_LUI: begin
        reg_wen_comb  = 1'b1;
        wb_sel_comb   = 2'b1;
        imm_sel_comb  = 3'b100; // Imm_UI
        alu_sel0_comb = `FNC_ADD_SUB;
        alu_sel1_comb = `FNC2_ADD;
        bcopy_comb    = 1'b1;
        bsel_comb     = 2'b01; // Imm
      end

      `OPC_AUIPC: begin
        reg_wen_comb  = 1'b1;
        wb_sel_comb   = 2'b1;   // Select WB ALU
        imm_sel_comb  = 3'b100; // Imm_UI
        alu_sel0_comb = `FNC_ADD_SUB;
        alu_sel1_comb = `FNC2_ADD;
        asel_comb     = 1'b1; // PC
        bsel_comb     = 1'b1; // Imm
      end

      // Jump instructions
      `OPC_JAL: begin
        wb_sel_comb   = 2'd2;   // WB from PC
        asel_comb     = 1'b1;   // PC
        bsel_comb     = 1'b1;   // Imm
        reg_wen_comb  = 1'b1;
        imm_sel_comb  = 3'b011; // Imm_J
      end

      `OPC_JALR: begin
        wb_sel_comb   = 2'd2;   // WB from PC
        asel_comb     = 1'b0;   // RF
        bsel_comb     = 1'b1;   // Imm
        reg_wen_comb  = 1'b1;
        imm_sel_comb  = 3'b000; // Imm_I

        rf_ra1_ren_comb = 1'b1;
        rf_ra2_ren_comb = 1'b0;
      end

      // Branch instructions
      `OPC_BRANCH: begin
        if (funct3 == `FNC_BLTU || funct3 == `FNC_BGEU)
          br_un_comb = 1'b1;

        asel_comb       = 1'b1;   // PC
        bsel_comb       = 1'b1;   // Imm
        imm_sel_comb    = 3'b010; // Imm_B
        rf_ra1_ren_comb = 1'b1;
        rf_ra2_ren_comb = 1'b1;
      end

      // Memory instructions
      `OPC_STORE: begin
        asel_comb    = 1'b0;   // RF
        bsel_comb    = 1'b1;   // Imm
        imm_sel_comb = 3'b001; // Imm_S

        case (funct3)
          `FNC_SW: begin
            mem_rw_comb = 4'b1000;
          end

          `FNC_SH: begin
            mem_rw_comb = 4'b1001;
          end

          `FNC_SB: begin
            mem_rw_comb = 4'b1010;
          end

          default: begin
            mem_rw_comb = 4'bx;
          end
        endcase

        rf_ra1_ren_comb = 1'b1;
        rf_ra2_ren_comb = 1'b1;
      end

      `OPC_LOAD: begin
        asel_comb     = 1'b0; // RF
        bsel_comb     = 1'b1; // Imm
        reg_wen_comb  = 1'b1;
        wb_sel_comb   = 2'd0; // WB from Load
        case (funct3)
          `FNC_LW: begin
            mem_rw_comb = 4'b0000;
          end

          `FNC_LH: begin
            mem_rw_comb = 4'b0001;
          end

          `FNC_LB: begin
            mem_rw_comb = 4'b0010;
          end

          `FNC_LHU: begin
            mem_rw_comb = 4'b0011;
          end

          `FNC_LBU: begin
            mem_rw_comb = 4'b0100;
          end

          default: begin
            mem_rw_comb = 4'bx;
          end
        endcase

        rf_ra1_ren_comb = 1'b1;
        rf_ra2_ren_comb = 1'b0;
      end

      // Arithmetic instructions
      `OPC_ARI_RTYPE: begin
        alu_sel0_comb = funct3;
        alu_sel1_comb = cpu_inst[30];
        asel_comb     = 1'b0; // RF
        bsel_comb     = 1'b0; // RF
        reg_wen_comb  = 1'b1;
        wb_sel_comb   = 2'd1; // WB from ALU

        rf_ra1_ren_comb = 1'b1;
        rf_ra2_ren_comb = 1'b1;
      end

      `OPC_ARI_ITYPE: begin
        alu_sel0_comb = funct3;
        alu_sel1_comb = (funct3 == `FNC_SRL_SRA) ? cpu_inst[30] : 1'b0;
        asel_comb     = 1'b0;   // RF
        bsel_comb     = 1'b1;   // Imm
        imm_sel_comb  = 3'b000; // Imm_I
        reg_wen_comb  = 1'b1;
        wb_sel_comb   = 2'd1;   // WB from ALU

        rf_ra1_ren_comb = 1'b1;
        rf_ra2_ren_comb = 1'b0;
      end
    endcase
  end

  always @(*) begin
    pc_sel_comb   = 1'b0;
    case (opcode_stg1)
      // Jump instructions
      `OPC_JAL: begin
        pc_sel_comb = 1'b1;
      end

      `OPC_JALR: begin
        pc_sel_comb = 1'b1;
      end

      // Branch instructions
      `OPC_BRANCH: begin
        case (funct3_stg1)
          `FNC_BEQ: begin
            pc_sel_comb = br_eq;
          end
          `FNC_BNE: begin
            pc_sel_comb = ~br_eq;
          end
          `FNC_BLT: begin
            pc_sel_comb = br_lt;
          end
          `FNC_BGE: begin
            pc_sel_comb = ~br_lt;
          end
          `FNC_BLTU: begin
            pc_sel_comb = br_lt;
          end
          `FNC_BGEU: begin
            pc_sel_comb = ~br_lt;
          end
          default: begin
            pc_sel_comb = 1'bx;
          end
        endcase
      end
    endcase
  end

endmodule

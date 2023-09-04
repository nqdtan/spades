`timescale 1ns/1ps
`include "Opcode.vh"
`include "socket_config.vh"

module riscv #(
  parameter RESET_PC     = 32'h0000_0000,
  parameter IMEM_MIF_HEX = "imem_data.mif",
  parameter CPU_AWIDTH   = 9
) (
  input  clk,
  input  rst,

  input [31:0]  imem_addr1,
  input [31:0]  imem_din1,
  output [31:0] imem_dout1,
  input         imem_we1,

  input mmio_stall,

  // MMIO
  output [31:0] mmio_addr,
  output [31:0] mmio_din,
  input  [31:0] mmio_dout,
  output        mmio_wen,
  output        mmio_ren
);
  // Memory blocks
  localparam DMEM_AWIDTH = CPU_AWIDTH;
  localparam DMEM_DWIDTH = 32;

  // dmem is not being used. For now just allocate 32-entry dmem
  //wire [DMEM_AWIDTH-1:0] dmem_addr;
  wire [4:0] dmem_addr;
  wire [DMEM_DWIDTH-1:0] dmem_din, dmem_dout;
  wire [3:0] dmem_we;

  // Data Memory
  // Synchronous read: read takes one cycle
  // Synchronous write: write takes one cycle
  // Write-byte-enable: select which of the four bytes to write
  SYNC_RAM_WBE_LUTRAM #(
    //.AWIDTH(DMEM_AWIDTH),
    .AWIDTH(5),
    .DWIDTH(DMEM_DWIDTH),
    .MIF_HEX(IMEM_MIF_HEX)
  ) dmem (
    .q(dmem_dout),    // output
    .d(dmem_din),     // input
    .addr(dmem_addr), // input
    .wbe(dmem_we),    // input
    .en(~mmio_stall),

    .clk(clk)
  );

  localparam IMEM_AWIDTH = CPU_AWIDTH;
  localparam IMEM_DWIDTH = 32;

  wire [IMEM_AWIDTH-1:0] imem_addr;
  wire [IMEM_DWIDTH-1:0] imem_dout;
  wire [IMEM_DWIDTH-1:0] imem_din;
  wire [3:0] imem_we;
  wire imem_en;

  // Instruction Memory
  // Synchronous read: read takes one cycle
  // Synchronous write: write takes one cycle
  // Write-byte-enable: select which of the four bytes to write
  SYNC_RAM_DP_WBE_LUTRAM #(
    .AWIDTH(IMEM_AWIDTH),
    .DWIDTH(IMEM_DWIDTH),
    .MIF_HEX(IMEM_MIF_HEX)
  ) imem (
    .q0(imem_dout),    // output
    .d0(imem_din),     // input
    .addr0(imem_addr), // input
    .wbe0(imem_we),    // input
    .en0(imem_en),

    .q1(imem_dout1),
    .d1(imem_din1),
    .addr1(imem_addr1[IMEM_AWIDTH-1:0]),
    .wbe1({imem_we1, imem_we1, imem_we1, imem_we1}),
    .en1(1'b1),

    .clk(clk)
  );

  wire rf_we;
  wire [4:0]  rf_ra1, rf_ra2, rf_wa;
  wire [31:0] rf_wd;
  wire [31:0] rf_rd1, rf_rd2;

  // Asynchronous read: read data is available in the same cycle
  // Synchronous write: write takes one cycle
  ASYNC_RAM_1W2R # (
    .AWIDTH(5),
    .DWIDTH(32)
  ) rf (
    .d0(rf_wd),                 // input
    .addr0(rf_wa),              // input
    .we0(rf_we & (rf_wa != 0)), // input

    .q1(rf_rd1),    // output
    .addr1(rf_ra1), // input

    .q2(rf_rd2),    // output
    .addr2(rf_ra2), // input

    .clk(clk)
  );

  wire [31:0] cpu_inst;
  wire [31:0] cpu_inst_mux;

  // Stage 1
  wire [31:0] alu_a_pipe0_mux, alu_b_pipe0_mux;
  wire [2:0] cu_alu_sel0_pipe0;
  wire       cu_alu_sel1_pipe0;
  wire [1:0] cu_wb_sel_pipe0;
  wire [3:0] cu_mem_rw_pipe0;
  wire [31:0] pc_pipe0;
  wire [31:0] cpu_inst_pipe0;
  wire cu_reg_wen_pipe0;

  wire br_un_pipe0;
  wire br_eq, br_lt;

  // Stage 2
  wire [1:0] cu_wb_sel_pipe1;
  wire [31:0] alu_out_pipe0;
  wire [31:0] cpu_inst_pipe1;
  wire [3:0] cu_mem_rw_pipe1;
  wire [31:0] pc_pipe1;
  wire cu_reg_wen_pipe1;
  wire [31:0] alu_out;

  // ...
  wire [31:0] cpu_inst_pipe2;
  wire        cu_reg_wen_pipe2;
  wire [1:0]  cu_wb_sel_pipe2;
  wire [31:0] mem_addr_pipe1;
  wire [31:0] alu_out_pipe1;
  wire [3:0]  cu_mem_rw_pipe2;
  wire [31:0] pc_pipe2;
  wire [31:0] pc_pipe3;

  // ...
  wire [31:0] pc_pipe4;
  wire        cu_reg_wen_pipe3;
  wire [1:0]  cu_wb_sel_pipe3;
  wire [3:0]  cu_mem_rw_pipe3;
  wire [31:0] mem_addr_pipe2;
  wire [31:0] alu_out_pipe2;
  wire [31:0] cpu_inst_pipe3;

  // ...
  wire [31:0] pc_pipe5;

  // Pipelined Registers
  // Stage0: BIOSMem_a, IMem_b, PC
  // Stage1: RF | ALU
  // Stage2: BIOSMem_b, DMem_a, IMem_a

  // Stage0 ==================================================================

  wire flush;
  wire bubble, bubble_pipe0;
  wire mmio_stall_pipe0;

  // Program Counter register
  wire [31:0] pc, pc_next;
  wire pc_stall;

  REGISTER_RP_CEP #(.N(32), .INIT(RESET_PC)) pc_reg (
    .q(pc),
    .d(pc_next),
    .rst(rst),
    .ce(~pc_stall | flush),
    .clk(clk)
  );
  wire pc_stall_pipe0;

  // Read instruction from IMem
  assign imem_addr = pc[IMEM_AWIDTH+2-1:2];
  assign imem_din  = 32'b0;
  assign imem_we   = 4'b0000;
  assign imem_en   = 1'b1;

  // Immediate Generator
  wire [2:0] imm_sel;
  wire [31:0] imm_out;
  imm_gen imm_gen (
    .imm_sel(imm_sel),       // input
    .cpu_inst(cpu_inst_mux), // input
    .imm_out(imm_out)        // output
  );

  // Control Unit
  wire cu_pc_sel, cu_reg_wen, cu_br_un, cu_br_eq, cu_br_lt;
  wire cu_asel, cu_bsel;
  wire [2:0] cu_alu_sel0;
  wire cu_alu_sel1;
  wire [2:0] cu_imm_sel;
  wire [3:0] cu_mem_rw;
  wire [1:0] cu_wb_sel;
  wire cu_a_fwd_0, cu_a_fwd_1, cu_a_fwd_2, cu_a_fwd_3;
  wire cu_b_fwd_0, cu_b_fwd_1, cu_b_fwd_2, cu_b_fwd_3;
  wire cu_load_hazard_3;
  wire cu_bcopy;

  control_unit control_unit (
    .cpu_inst(cpu_inst_mux),            // input
    .cpu_inst_stg1((~mmio_stall_pipe0 & bubble_pipe0) ? 0 : cpu_inst_pipe0), // input
    .cpu_inst_stg2(cpu_inst_pipe1),     // input
    .cpu_inst_stg3(cpu_inst_pipe2),     // input
    .cpu_inst_stg4(cpu_inst_pipe3),     // input
    .reg_wen_stg1(cu_reg_wen_pipe0),    // input
    .reg_wen_stg2(cu_reg_wen_pipe1),    // input
    .reg_wen_stg3(cu_reg_wen_pipe2),    // input
    .reg_wen_stg4(cu_reg_wen_pipe3),    // input

    .pc_sel(cu_pc_sel),   // output
    .imm_sel(cu_imm_sel), // output
    .reg_wen(cu_reg_wen), // output
    .br_un(cu_br_un),     // output
    .br_eq(cu_br_eq),     // input
    .br_lt(cu_br_lt),     // input
    .bsel(cu_bsel),       // output
    .asel(cu_asel),       // output

    // Hazards
    .a_fwd_0(cu_a_fwd_0), // output
    .b_fwd_0(cu_b_fwd_0), // output
    .a_fwd_1(cu_a_fwd_1), // output
    .b_fwd_1(cu_b_fwd_1), // output
    .a_fwd_2(cu_a_fwd_2), // output
    .b_fwd_2(cu_b_fwd_2), // output
    .a_fwd_3(cu_a_fwd_3), // output
    .b_fwd_3(cu_b_fwd_3), // output

    .load_hazard_3(cu_load_hazard_3), // output

    .bcopy(cu_bcopy),
    .alu_sel0(cu_alu_sel0), // output
    .alu_sel1(cu_alu_sel1), // output
    .mem_rw(cu_mem_rw),     // output
    .wb_sel(cu_wb_sel)      // output
  );

  wire [31:0] rf_rd1_mux = rf_rd1;
  wire [31:0] rf_rd2_mux = rf_rd2;

  // ALU Datapath
  wire [31:0] alu_a = (cu_bcopy) ? 0 : pc_pipe1;

  wire cu_bcopy_pipe0;
  REGISTER_CE #(.N(1)) cu_bcopy_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(cu_bcopy),
    .q(cu_bcopy_pipe0)
  );

  wire cu_asel_pipe0;
  REGISTER_CE #(.N(1)) cu_asel_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(cu_asel),
    .q(cu_asel_pipe0)
  );

  wire cu_bsel_pipe0;
  REGISTER_CE #(.N(1)) cu_bsel_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(cu_bsel),
    .q(cu_bsel_pipe0)
  );

  wire [31:0] imm_out_pipe0;
  REGISTER_CE #(.N(32)) imm_out_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(imm_out),
    .q(imm_out_pipe0)
  );

  wire [31:0] alu_b = imm_out;

  wire [31:0] rf_rd1_pipe0, rf_rd2_pipe0;
  wire a_sel_pipe0, b_sel_pipe0;
  wire [31:0] alu_a_pipe0, alu_b_pipe0;

  // Imm. Generator Datapath
  assign imm_sel = cu_imm_sel;

  // Branch Comparator Datapath
  wire [31:0] br_a, br_b;
  wire br_un;
  assign br_un    = cu_br_un;
  assign cu_br_eq = br_eq;
  assign cu_br_lt = br_lt;

  // If Branch/Jump is taken, or if there is a Load hazard, we inject a bubble
  assign pc_stall = cu_a_fwd_0 | cu_b_fwd_0 |
                    cu_a_fwd_1 | cu_b_fwd_1 |
                    cu_load_hazard_3 |
                    cu_a_fwd_3 | cu_b_fwd_3 |
                    mmio_stall;

  assign flush    = cu_pc_sel;
  wire flush_pipe0;
  REGISTER #(.N(1)) flush_pipe0_reg (
    .clk(clk),
    .d(flush),
    .q(flush_pipe0)
  );

  wire mmio_stall_pipe1;
  REGISTER #(.N(1)) mmio_stall_pipe1_reg (
    .clk(clk),
    .d(mmio_stall_pipe0),
    .q(mmio_stall_pipe1)
  );

  // Avoid using the RST and EN pins of BRAM-dout reg to reduce net delay

  wire [31:0] imem_dout_pipe0;
  REGISTER_RP_CEP #(.N(32)) imem_dout_pipe0_reg (
    .clk(clk),
    .rst(flush | flush_pipe0),
    .ce(~(pc_stall_pipe0 | mmio_stall_pipe0)),
    .d(imem_dout),
    .q(imem_dout_pipe0)
  );

  wire [31:0] dmem_dout_pipe0;
  REGISTER_CEP #(.N(32)) dmem_dout_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(dmem_dout),
    .q(dmem_dout_pipe0)
  );

  wire [31:0] mmio_dout_pipe0;
  REGISTER_RP_CEP #(.N(32)) mmio_dout_pipe0_reg (
    .clk(clk),
    .rst(flush),
    .ce(~mmio_stall),
    .d(mmio_dout),
    .q(mmio_dout_pipe0)
  );

  assign bubble   = (pc_stall | flush);
  assign cpu_inst = imem_dout_pipe0;

  wire [31:0] cpu_inst_mux_pipe0;
  assign cpu_inst_mux = (pc_stall_pipe0) ? cpu_inst_mux_pipe0 : cpu_inst;

  wire [6:0]  opcode   = cpu_inst_mux[6:0];
  wire [2:0]  funct3   = cpu_inst_mux[14:12];

  // Stage1 ==================================================================

  REGISTER_CE #(.N(32)) rf_rd1_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(rf_rd1),
    .q(rf_rd1_pipe0)
  );

  REGISTER_CE #(.N(32)) rf_rd2_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(rf_rd2),
    .q(rf_rd2_pipe0)
  );

  REGISTER_CE #(.N(1)) a_sel_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(cu_bcopy | cu_asel),
    .q(a_sel_pipe0)
  );

  REGISTER_CE #(.N(1)) b_sel_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(cu_bsel),
    .q(b_sel_pipe0)
  );

  REGISTER_CE #(.N(32)) alu_a_pipe0_reg (
    .q(alu_a_pipe0),
    .d(alu_a),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(32)) alu_b_pipe0_reg (
    .q(alu_b_pipe0),
    .d(alu_b),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(3)) cu_alu_sel0_pipe0_reg (
    .q(cu_alu_sel0_pipe0),
    .d(cu_alu_sel0),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(1)) cu_alu_sel1_pipe0_reg (
    .q(cu_alu_sel1_pipe0),
    .d(cu_alu_sel1),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(2)) cu_wb_sel_pipe0_reg (
    .q(cu_wb_sel_pipe0),
    .d(cu_wb_sel),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(4)) cu_mem_rw_pipe0_reg (
    .q(cu_mem_rw_pipe0),
    .d(cu_mem_rw),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CEP #(.N(32)) pc_pipe0_reg (
    .q(pc_pipe0),
    .d(pc),
    .ce(~pc_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(1)) cu_reg_wen_pipe0_reg (
    .q(cu_reg_wen_pipe0),
    .d(cu_reg_wen),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER #(.N(32)) cpu_inst_mux_pipe0_reg (
    .q(cpu_inst_mux_pipe0),
    .d(cpu_inst_mux),
    .clk(clk)
  );


  REGISTER_RP_CEP #(.N(32)) cpu_inst_pipe0_reg (
    .q(cpu_inst_pipe0),
    .d(cpu_inst_mux),
    .ce(~mmio_stall),
    .rst(~mmio_stall & bubble),
    .clk(clk)
  );

  REGISTER_RP #(.N(1))  pc_stall_pipe0_reg (
    .q(pc_stall_pipe0),
    .d(pc_stall),
    .rst(flush),
    .clk(clk)
  );

  wire cu_a_fwd_1_pipe0;
  REGISTER_CE #(.N(1)) cu_a_fwd_1_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(cu_a_fwd_1),
    .q(cu_a_fwd_1_pipe0)
  );

  wire cu_a_fwd_2_pipe0;
  REGISTER_CE #(.N(1)) cu_a_fwd_2_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(cu_a_fwd_2),
    .q(cu_a_fwd_2_pipe0)
  );

  wire cu_a_fwd_3_pipe0;
  REGISTER_CE #(.N(1)) cu_a_fwd_3_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(cu_a_fwd_3),
    .q(cu_a_fwd_3_pipe0)
  );

  wire cu_b_fwd_1_pipe0;
  REGISTER_CE #(.N(1)) cu_b_fwd_1_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(cu_b_fwd_1),
    .q(cu_b_fwd_1_pipe0)
  );

  wire cu_b_fwd_2_pipe0;
  REGISTER_CE #(.N(1)) cu_b_fwd_2_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(cu_b_fwd_2),
    .q(cu_b_fwd_2_pipe0)
  );

  wire cu_b_fwd_3_pipe0;
  REGISTER_CE #(.N(1)) cu_b_fwd_3_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(cu_b_fwd_3),
    .q(cu_b_fwd_3_pipe0)
  );

  wire [31:0] rf_rd1_mux_pipe0;
  REGISTER_CE #(.N(32)) rf_rd1_mux_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(rf_rd1_mux),
    .q(rf_rd1_mux_pipe0)
  );

  wire [31:0] rf_rd2_mux_pipe0;
  REGISTER_CE #(.N(32)) rf_rd2_mux_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(rf_rd2_mux),
    .q(rf_rd2_mux_pipe0)
  );

  assign br_a = (cu_a_fwd_2_pipe0) ? alu_out_pipe2 : rf_rd1_mux_pipe0;
  assign br_b = (cu_b_fwd_2_pipe0) ? alu_out_pipe2 : rf_rd2_mux_pipe0;

  REGISTER_CE #(.N(1)) br_un_pipe0_reg (
    .q(br_un_pipe0),
    .d(br_un),
    .ce(~mmio_stall),
    .clk(clk)
  );

  wire [31:0] rf_wd_pipe0;
  REGISTER_CE #(.N(32)) rf_wd_pipe0_reg (
    .q(rf_wd_pipe0),
    .d(rf_wd),
    .ce(~mmio_stall),
    .clk(clk)
  );

  assign alu_a_pipe0_mux = (a_sel_pipe0)      ? alu_a_pipe0   :
                           (cu_a_fwd_2_pipe0) ? alu_out_pipe2 :
                           rf_rd1_pipe0;

  assign alu_b_pipe0_mux = (b_sel_pipe0)      ? alu_b_pipe0   :
                           (cu_b_fwd_2_pipe0) ? alu_out_pipe2 :
                           rf_rd2_pipe0;

  wire [6:0] opcode_pipe0 = (~mmio_stall_pipe0 & bubble_pipe0) ? 0 : cpu_inst_pipe0[6:0];

  // ALU
  alu alu (
    .alu_sel0(cu_alu_sel0_pipe0), // input
    .alu_sel1(cu_alu_sel1_pipe0), // input
    .alu_a(alu_a_pipe0_mux),      // input
    .alu_b(alu_b_pipe0_mux),      // input
    .alu_out(alu_out)             // output
  );

  // Branch Comparator
  branch_comp branch_comp (
    .br_un(br_un_pipe0), // input
    .br_a(br_a),         // input
    .br_b(br_b),         // input
    .br_eq(br_eq),       // output
    .br_lt(br_lt)        // output
  );

  wire [31:0] br_j_addr = alu_a_pipe0_mux + alu_b_pipe0_mux;
  wire [31:0] mem_addr  = alu_a_pipe0_mux + alu_b_pipe0_mux;

  REGISTER_CE #(.N(1)) bubble_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(bubble),
    .q(bubble_pipe0)
  );

  // Store mask
  wire [31:0] smask_dmem_din;
  wire [3:0] smask_dmem_we;
  store_mask smask_dmem (
    .mem_rw(bubble_pipe0 ? 4'b0 : cu_mem_rw_pipe0), // input
    .byte_addr(mem_addr[1:0]),     // input
    .mem_din(br_b),                // input
    .smask_mem_we(smask_dmem_we),  // output
    .smask_mem_din(smask_dmem_din) // output
  );

  wire [31:0] smask_mmio_din;
  wire [3:0] smask_mmio_we;
  store_mask smask_mmio (
    .mem_rw(bubble_pipe0 ? 4'b0 : cu_mem_rw_pipe0), // input
    .byte_addr(mem_addr[1:0]),     // input
    .mem_din(br_b),                // input
    .smask_mem_we(smask_mmio_we),  // output
    .smask_mem_din(smask_mmio_din) // output
  );

  wire [31:0] mem_addr_pipe0;
  REGISTER_CE #(.N(32)) mem_addr_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(mem_addr),
    .q(mem_addr_pipe0)
  );

  wire [31:0] smask_dmem_din_pipe0;
  REGISTER_CE #(.N(32)) smask_dmem_din_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(smask_dmem_din),
    .q(smask_dmem_din_pipe0)
  );

  wire [3:0] smask_dmem_we_pipe0;
  REGISTER_CE #(.N(4)) smask_dmem_we_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(smask_dmem_we),
    .q(smask_dmem_we_pipe0)
  );

  wire [31:0] smask_mmio_din_pipe0;
  REGISTER_CE #(.N(32)) smask_mmio_din_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(smask_mmio_din),
    .q(smask_mmio_din_pipe0)
  );

  wire [3:0] smask_mmio_we_pipe0;
  REGISTER_CE #(.N(4)) smask_mmio_we_pipe0_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(smask_mmio_we),
    .q(smask_mmio_we_pipe0)
  );

  wire [6:0] opcode_pipe1;
  REGISTER_CE #(.N(7)) opcode_pipe1_reg (
    .clk(clk),
    .ce(~mmio_stall),
    .d(opcode_pipe0),
    .q(opcode_pipe1)
  );

  // DMem Datapath
  // Write/Read from DMem
  assign dmem_addr = mem_addr_pipe0[DMEM_AWIDTH+2-1:2];
  assign dmem_din  = smask_dmem_din_pipe0;
  assign dmem_we   = (mem_addr_pipe0[31:28] != 4'b1000) ? smask_dmem_we_pipe0 : 4'b0;

  // MMIO Datapath
  assign mmio_addr = mem_addr_pipe0;
  assign mmio_din  = smask_mmio_din_pipe0;
  assign mmio_wen  = (opcode_pipe1 == `OPC_STORE) & (mem_addr_pipe0[31:28] == 4'b1000);
  assign mmio_ren  = (opcode_pipe1 == `OPC_LOAD)  & (mem_addr_pipe0[31:28] == 4'b1000);

  // Program Counter update
  assign pc_next = (cu_pc_sel) ? br_j_addr : (pc + 4);

  // Stage2 ==================================================================
  REGISTER_CE #(.N(2)) cu_wb_sel_pipe1_reg (
    .q(cu_wb_sel_pipe1),
    .d(cu_wb_sel_pipe0),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(32)) alu_out_pipe0_reg (
    .q(alu_out_pipe0),
    .d(alu_out),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(4)) cu_mem_rw_pipe1_reg (
    .q(cu_mem_rw_pipe1),
    .d(cu_mem_rw_pipe0),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER #(.N(1)) mmio_stall_pipe0_reg (
    .q(mmio_stall_pipe0),
    .d(mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(32)) cpu_inst_pipe1_reg (
    .q(cpu_inst_pipe1),
    .d(cpu_inst_pipe0),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CEP #(.N(32)) pc_pipe1_reg (
    .q(pc_pipe1),
    .d(pc_pipe0),
    .ce(~(pc_stall | mmio_stall)),
    .clk(clk)
  );

  REGISTER_CE #(.N(1)) cu_reg_wen_pipe1_reg (
    .q(cu_reg_wen_pipe1),
    .d(cu_reg_wen_pipe0),
    .ce(~mmio_stall),
    .clk(clk)
  );

  // ---
  REGISTER_CE #(.N(2)) cu_wb_sel_pipe2_reg (
    .q(cu_wb_sel_pipe2),
    .d(cu_wb_sel_pipe1),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(32)) mem_addr_pipe1_reg (
    .q(mem_addr_pipe1),
    .d(mem_addr_pipe0),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(32)) alu_out_pipe1_reg (
    .q(alu_out_pipe1),
    .d(alu_out_pipe0),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(4)) cu_mem_rw_pipe2_reg (
    .q(cu_mem_rw_pipe2),
    .d(cu_mem_rw_pipe1),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(32)) cpu_inst_pipe2_reg (
    .q(cpu_inst_pipe2),
    .d(cpu_inst_pipe1),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(32)) pc_pipe2_reg (
    .q(pc_pipe2),
    .d(pc_pipe1),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(1)) cu_reg_wen_pipe2_reg (
    .q(cu_reg_wen_pipe2),
    .d(cu_reg_wen_pipe1),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(32)) pc_pipe3_reg (
    .q(pc_pipe3),
    .d(pc_pipe2),
    .ce(~mmio_stall),
    .clk(clk)
  );

  // ---
  REGISTER_CE #(.N(32)) pc_pipe4_reg (
    .q(pc_pipe4),
    .d(pc_pipe3),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(1)) cu_reg_wen_pipe3_reg (
    .q(cu_reg_wen_pipe3),
    .d(cu_reg_wen_pipe2),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(2)) cu_wb_sel_pipe3_reg (
    .q(cu_wb_sel_pipe3),
    .d(cu_wb_sel_pipe2),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(4)) cu_mem_rw_pipe3_reg (
    .q(cu_mem_rw_pipe3),
    .d(cu_mem_rw_pipe2),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(32)) mem_addr_pipe2_reg (
    .q(mem_addr_pipe2),
    .d(mem_addr_pipe1),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(32)) alu_out_pipe2_reg (
    .q(alu_out_pipe2),
    .d(alu_out_pipe1),
    .ce(~mmio_stall),
    .clk(clk)
  );

  REGISTER_CE #(.N(32)) cpu_inst_pipe3_reg (
    .q(cpu_inst_pipe3),
    .d(cpu_inst_pipe2),
    .ce(~mmio_stall),
    .clk(clk)
  );

  // ---
  REGISTER_CE #(.N(32)) pc_pipe5_reg (
    .q(pc_pipe5),
    .d(pc_pipe4),
    .ce(~mmio_stall),
    .clk(clk)
  );

  // Load mask
  wire [31:0] load_data = (mem_addr_pipe2[31:28] == 4'b1000) ? mmio_dout_pipe0 : dmem_dout_pipe0;

  wire [31:0] lmask_mem_dout;
  load_mask load_mask (
    .mem_rw(cu_mem_rw_pipe3),        // input
    .byte_addr(mem_addr_pipe2[1:0]), // input
    .mem_dout(load_data),            // input
    .lmask_mem_dout(lmask_mem_dout)  // output
  );

  // WriteBack to RF Datapath
  assign rf_wd = (cu_wb_sel_pipe3 == 2'd0) ? lmask_mem_dout :
                 (cu_wb_sel_pipe3 == 2'd1) ? alu_out_pipe2  : (pc_pipe5 + 4);
  assign rf_wa  = cpu_inst_pipe3[11:7];
  assign rf_we  = cu_reg_wen_pipe3;

  assign rf_ra1 = cpu_inst_mux[19:15];
  assign rf_ra2 = cpu_inst_mux[24:20];

endmodule

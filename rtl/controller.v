`timescale 1ns/1ps
`include "axi_consts.vh"
`include "socket_config.vh"

`define DEBUG_MMIO 1

module controller #(
  parameter AXI_AWIDTH = 32,
  parameter AXI_DWIDTH = 32,
  parameter DMEM_AWIDTH = 10,
  parameter DMEM_DWIDTH = 32,
  parameter NUM_SYNCS = 16,
  parameter IMEM_MIF_HEX = "imem_data.mif"
) (
  input clk,
  input resetn, // active-low reset

  input         cl_done,
  output [11:0] cl_ctrl_addr,
  output [31:0] cl_ctrl_d,
  input  [31:0] cl_ctrl_q,
  output        cl_ctrl_ce,
  output        cl_ctrl_we,

  input socket_start,
  output socket_done,

  output        ctrl_maxi_rstart,
  output        ctrl_maxi_wstart,
  input         ctrl_maxi_rdone,
  input         ctrl_maxi_wdone,
  input  [31:0] ctrl_maxi_rdata,
  output [31:0] ctrl_maxi_wdata,
  output [63:0] ctrl_maxi_socket_offset,

  input dma0_write_idle,
  input dma1_write_idle,

  output [31:0] lsu0_ram_start_idx,
  output [31:0] lsu0_ram_block_factor,
  output [31:0] lsu0_ram_cyclic_factor,
  output [31:0] lsu0_ram_stride,
  output [31:0] lsu0_ram_seg_stride,
  output [31:0] lsu0_ram_addr_offset,

  output [31:0] lsu0_m_offset_lo,
  output [31:0] lsu0_m_offset_hi,
  output [31:0] lsu0_seg_stride,
  output [31:0] lsu0_seg_count,
  output [31:0] lsu0_len,
  output [31:0] lsu0_mode,

  output  lsu0_start,
  input   lsu0_done,

  output [31:0] lsu1_ram_start_idx,
  output [31:0] lsu1_ram_block_factor,
  output [31:0] lsu1_ram_cyclic_factor,
  output [31:0] lsu1_ram_stride,
  output [31:0] lsu1_ram_seg_stride,
  output [31:0] lsu1_ram_addr_offset,

  output [31:0] lsu1_m_offset_lo,
  output [31:0] lsu1_m_offset_hi,
  output [31:0] lsu1_seg_stride,
  output [31:0] lsu1_seg_count,
  output [31:0] lsu1_len,
  output [31:0] lsu1_mode,

  output [31:0] comm0_mode,
  output [31:0] comm1_mode,

  output  lsu1_start,
  input   lsu1_done,

  input [31:0] socket_imem_addr,
  input [31:0] socket_imem_wdata,
  input        socket_imem_we,

  input [31:0] socket_inbox,

  input [NUM_SYNCS-1:0] sync_en,

  output [31:0] squeue_out_data,
  output        squeue_out_valid,
  input         squeue_out_ready
);

  wire [31:0] mmio_addr;
  wire [31:0] mmio_din, mmio_dout;
  wire mmio_wen, mmio_ren;

  // mmio_stall
  wire mmio_stall;

  riscv #(
    .RESET_PC(32'h0000_0000),
    .IMEM_MIF_HEX(IMEM_MIF_HEX),
    .CPU_AWIDTH(9)
  ) CPU (
    .clk(clk),
    .rst(~resetn | ~socket_start),

    .imem_addr1(socket_imem_addr),
    .imem_din1(socket_imem_wdata),
    .imem_we1(socket_imem_we),

    .mmio_stall(mmio_stall),

    // MMIO
    .mmio_addr(mmio_addr), // output
    .mmio_din(mmio_din),   // output
    .mmio_dout(mmio_dout), // input
    .mmio_wen(mmio_wen),   // output
    .mmio_ren(mmio_ren)    // output
  );

  wire [31:0] mmio_dout0;

  wire [31:0] lsu0_ram_start_idx_tmp;
  wire [31:0] lsu0_ram_block_factor_tmp;
  wire [31:0] lsu0_ram_cyclic_factor_tmp;
  wire [31:0] lsu0_ram_stride_tmp;
  wire [31:0] lsu0_ram_seg_stride_tmp;
  wire [31:0] lsu0_ram_addr_offset_tmp;

  wire [31:0] lsu0_m_offset_lo_tmp;
  wire [31:0] lsu0_m_offset_hi_tmp;
  wire [31:0] lsu0_seg_stride_tmp;
  wire [31:0] lsu0_seg_count_tmp;
  wire [31:0] lsu0_len_tmp;
  wire [31:0] lsu0_mode_tmp;

  wire [31:0] lsu1_ram_start_idx_tmp;
  wire [31:0] lsu1_ram_block_factor_tmp;
  wire [31:0] lsu1_ram_cyclic_factor_tmp;
  wire [31:0] lsu1_ram_stride_tmp;
  wire [31:0] lsu1_ram_seg_stride_tmp;
  wire [31:0] lsu1_ram_addr_offset_tmp;

  wire [31:0] lsu1_m_offset_lo_tmp;
  wire [31:0] lsu1_m_offset_hi_tmp;
  wire [31:0] lsu1_seg_stride_tmp;
  wire [31:0] lsu1_seg_count_tmp;
  wire [31:0] lsu1_len_tmp;
  wire [31:0] lsu1_mode_tmp;

  wire [31:0] tq_wdata;
  wire tq_full_n, tq_empty_n;
  wire tq_enq_fire;
  wire ff_cl_scalar_full_n;

  mmio #(
    .DMEM_AWIDTH(DMEM_AWIDTH),
    .DMEM_DWIDTH(DMEM_DWIDTH),
    .NUM_SYNCS(NUM_SYNCS)
  ) mmio (
    .clk(clk),
    .resetn(resetn),

    .mmio_addr(mmio_addr),
    .mmio_din(mmio_din),
    .mmio_dout(mmio_dout0),
    .mmio_wen(mmio_wen),
    .mmio_ren(mmio_ren),

    .ctrl_maxi_rstart(ctrl_maxi_rstart),
    .ctrl_maxi_wstart(ctrl_maxi_wstart),
    .ctrl_maxi_rdone(ctrl_maxi_rdone),
    .ctrl_maxi_wdone(ctrl_maxi_wdone),
    .ctrl_maxi_rdata(ctrl_maxi_rdata),
    .ctrl_maxi_wdata(ctrl_maxi_wdata),
    .ctrl_maxi_socket_offset(ctrl_maxi_socket_offset),

    .dma0_write_idle(dma0_write_idle),
    .dma1_write_idle(dma1_write_idle),

    .lsu0_ram_start_idx(lsu0_ram_start_idx_tmp),
    .lsu0_ram_block_factor(lsu0_ram_block_factor_tmp),
    .lsu0_ram_cyclic_factor(lsu0_ram_cyclic_factor_tmp),
    .lsu0_ram_stride(lsu0_ram_stride_tmp),
    .lsu0_ram_seg_stride(lsu0_ram_seg_stride_tmp),
    .lsu0_ram_addr_offset(lsu0_ram_addr_offset_tmp),

    .lsu0_m_offset_lo(lsu0_m_offset_lo_tmp),
    .lsu0_m_offset_hi(lsu0_m_offset_hi_tmp),
    .lsu0_seg_stride(lsu0_seg_stride_tmp),
    .lsu0_seg_count(lsu0_seg_count_tmp),
    .lsu0_len(lsu0_len_tmp),
    .lsu0_mode(lsu0_mode_tmp),

    //.lsu0_start(lsu0_start),
    //.lsu0_done(lsu0_done),

`ifndef SOCKET_S
    .lsu1_ram_start_idx(lsu1_ram_start_idx_tmp),
    .lsu1_ram_block_factor(lsu1_ram_block_factor_tmp),
    .lsu1_ram_cyclic_factor(lsu1_ram_cyclic_factor_tmp),
    .lsu1_ram_stride(lsu1_ram_stride_tmp),
    .lsu1_ram_seg_stride(lsu1_ram_seg_stride_tmp),
    .lsu1_ram_addr_offset(lsu1_ram_addr_offset_tmp),

    .lsu1_m_offset_lo(lsu1_m_offset_lo_tmp),
    .lsu1_m_offset_hi(lsu1_m_offset_hi_tmp),
    .lsu1_seg_stride(lsu1_seg_stride_tmp),
    .lsu1_seg_count(lsu1_seg_count_tmp),
    .lsu1_len(lsu1_len_tmp),
    .lsu1_mode(lsu1_mode_tmp),

    //.lsu1_start(lsu1_start),
    //.lsu1_done(lsu1_done),
    .comm1_mode(comm1_mode),

`endif
    .tq_wdata(tq_wdata),
    .tq_empty_n(tq_empty_n),
    .tq_full_n(tq_full_n),
    .tq_enq_fire(tq_enq_fire),
    .ff_cl_scalar_full_n(ff_cl_scalar_full_n),

    .comm0_mode(comm0_mode),

    .sync_en(sync_en),

    .squeue_out_data(squeue_out_data),
    .squeue_out_valid(squeue_out_valid),
    .squeue_out_ready(squeue_out_ready),

    .socket_inbox(socket_inbox),
    .socket_done(socket_done)
  );

  // Only kick off the state machine if the request MMIO targets the kernel
  // (hence, the request is translated to AXI-Lite transaction). Otherwise,
  // we perform read/write to the MMIO registers in the MMIO block

  wire request_to_kernel = mmio_addr[27:8] == 0;

  localparam CL_CTRL_READ_LATENCY = 4;//4 + 1 + 1;
  wire [4:0] cl_ctrl_read_cnt_value, cl_ctrl_read_cnt_next;
  wire cl_ctrl_read_cnt_ce, cl_ctrl_read_cnt_rst;
  REGISTER_R_CE #(.N(5)) cl_ctrl_read_cnt_reg (
    .clk(clk),
    .rst(cl_ctrl_read_cnt_rst),
    .ce(cl_ctrl_read_cnt_ce),
    .d(cl_ctrl_read_cnt_next),
    .q(cl_ctrl_read_cnt_value)
  );

  wire mmio_ren_pipe0;
  REGISTER_R_CE #(.N(1)) mmio_ren_pipe0_reg (
    .clk(clk),
    .rst(~resetn | (cl_ctrl_read_cnt_value == CL_CTRL_READ_LATENCY - 2)),
    .ce(mmio_ren & request_to_kernel),
    .d(1'b1),
    .q(mmio_ren_pipe0)
  );

  wire [31:0] mmio_addr_pipe0;
  REGISTER #(.N(32)) mmio_addr_pipe0_reg (
    .clk(clk),
    .d(mmio_addr),
    .q(mmio_addr_pipe0)
  );
  wire [31:0] mmio_din_pipe0;
  REGISTER #(.N(32)) mmio_din_pipe0_reg (
    .clk(clk),
    .d(mmio_din),
    .q(mmio_din_pipe0)
  );
  wire cl_ce_pipe0;
  REGISTER #(.N(1)) cl_ce_pipe0_reg (
    .clk(clk),
    .d((mmio_wen | mmio_ren) & request_to_kernel),
    .q(cl_ce_pipe0)
  );
  wire cl_we_pipe0;
  REGISTER #(.N(1)) cl_we_pipe0_reg (
    .clk(clk),
    .d(mmio_wen & request_to_kernel),
    .q(cl_we_pipe0)
  );

  localparam FIFO_LOGDEPTH = 3;

  wire [64:0] ff_cl_scalar_enq_data, ff_cl_scalar_deq_data;
  wire ff_cl_scalar_enq_valid, ff_cl_scalar_enq_ready;
  wire ff_cl_scalar_deq_valid, ff_cl_scalar_deq_ready;
  fifo #(
    .WIDTH(65),
    .LOGDEPTH(FIFO_LOGDEPTH + 1)
  ) ff_cl_scalar (
    .clk(clk),
    .rst(rst),

    .enq_data(ff_cl_scalar_enq_data),
    .enq_valid(ff_cl_scalar_enq_valid),
    .enq_ready(ff_cl_scalar_enq_ready),

    .deq_data(ff_cl_scalar_deq_data),
    .deq_valid(ff_cl_scalar_deq_valid),
    .deq_ready(ff_cl_scalar_deq_ready)
  );

  // task queue
  wire [2:0] tq_enq_data, tq_deq_data;
  wire tq_enq_valid, tq_enq_ready;
  wire tq_deq_valid, tq_deq_ready;
  fifo #(
    .WIDTH(3),
    .LOGDEPTH(FIFO_LOGDEPTH + 1)
  ) tq (
    .clk(clk),
    .rst(~resetn),

    .enq_data(tq_enq_data),
    .enq_valid(tq_enq_valid),
    .enq_ready(tq_enq_ready),

    .deq_data(tq_deq_data),
    .deq_valid(tq_deq_valid),
    .deq_ready(tq_deq_ready)
  );

  wire [2:0] tq_deq_data_pipe;
  REGISTER #(.N(3)) tq_deq_data_reg (
    .clk(clk),
    .d(tq_deq_data),
    .q(tq_deq_data_pipe)
  );

  wire lsu0_done_pipe0;
  REGISTER_R_CE #(.N(1)) lsu0_done_reg (
    .clk(clk),
    .ce(lsu0_done),
    .rst((tq_deq_data == 2) & lsu0_done_pipe0),
    .d(1'b1),
    .q(lsu0_done_pipe0)
  );

  wire lsu1_done_pipe0;
  REGISTER_R_CE #(.N(1)) lsu1_done_reg (
    .clk(clk),
    .ce(lsu1_done),
    .rst((tq_deq_data == 4) & lsu1_done_pipe0),
    .d(1'b1),
    .q(lsu1_done_pipe0)
  );

  wire cl_start;
  wire cl_start0;
  wire cl_start1;
  wire cl_running;

  REGISTER_R_CE #(.N(1), .INIT(0)) cl_start0_reg (
    .clk(clk),
    .rst(cl_start0 & ~cl_done),
    .ce(cl_start),
    .d(1'b1),
    .q(cl_start0)
  );

  REGISTER_R_CE #(.N(1), .INIT(0)) cl_start1_reg (
    .clk(clk),
    .ce(cl_start0 & ~cl_done),
    .rst(cl_running),
    .d(1'b1),
    .q(cl_start1)
  );

  REGISTER_R_CE #(.N(1), .INIT(0)) cl_running_reg (
    .clk(clk),
    .rst(cl_done & cl_running),
    .ce(cl_start1),
    .d(1'b1),
    .q(cl_running)
  );

  wire cl_done_pipe0;
  REGISTER_R_CE #(.N(1), .INIT(0)) cl_done_reg (
    .clk(clk),
    .ce(cl_done & cl_running),
    .rst((tq_deq_data == 6) & cl_done_pipe0 & tq_deq_valid),
    .d(1'b1),
    .q(cl_done_pipe0)
  );

  wire cl_cfg_enq;
  REGISTER_R_CE #(.N(1)) cl_cfg_enq_reg (
    .clk(clk),
    .ce(cl_start),
    .rst(cl_cfg_enq & ((cl_ctrl_addr == 0) & cl_ctrl_d[0] & cl_ctrl_ce & cl_ctrl_we)),
    .d(1'b1),
    .q(cl_cfg_enq)
  );

  wire mmio_stall_pipe0;
  REGISTER #(.N(1)) mmio_stall_reg (
    .clk(clk),
    .d(mmio_stall),
    .q(mmio_stall_pipe0)
  );

  assign cl_ctrl_read_cnt_next = cl_ctrl_read_cnt_value + 1;
  assign cl_ctrl_read_cnt_ce   = (mmio_ren & request_to_kernel) | mmio_ren_pipe0;
  assign cl_ctrl_read_cnt_rst  = cl_ctrl_read_cnt_value == CL_CTRL_READ_LATENCY - 1;

//  assign cl_ctrl_addr = mmio_addr_pipe0[11:0];
//  assign cl_ctrl_d    = mmio_din_pipe0;
//  assign cl_ctrl_ce   = cl_ce_pipe0;
//  assign cl_ctrl_we   = cl_we_pipe0;

  assign cl_ctrl_addr = ff_cl_scalar_deq_data[11:0];
  assign cl_ctrl_d    = ff_cl_scalar_deq_data[63:32];
  assign cl_ctrl_ce   = ff_cl_scalar_deq_valid & ff_cl_scalar_deq_ready;
  assign cl_ctrl_we   = ~ff_cl_scalar_deq_data[64] & ff_cl_scalar_deq_valid & ff_cl_scalar_deq_ready;

  assign mmio_dout  = (cl_ctrl_read_cnt_value == CL_CTRL_READ_LATENCY - 1) ? cl_ctrl_q : mmio_dout0;
  assign mmio_stall = mmio_ren_pipe0 | ~tq_enq_ready | ~ff_cl_scalar_enq_ready;
//  assign mmio_stall = mmio_ren_pipe0 | ~tq_enq_ready;

  assign ff_cl_scalar_enq_data  = {mmio_ren, mmio_din[31:0], mmio_addr[31:0]};
//  assign ff_cl_scalar_enq_valid = (mmio_wen & request_to_kernel) & ~mmio_stall;
  assign ff_cl_scalar_enq_valid = ((mmio_wen | mmio_ren) & request_to_kernel) & tq_enq_ready & ~mmio_ren_pipe0;

  assign ff_cl_scalar_deq_ready = cl_cfg_enq | ff_cl_scalar_deq_data[64];

  assign tq_enq_fire  = tq_enq_valid & tq_enq_ready;
  assign tq_enq_data  = tq_wdata[3:1];
//  assign tq_enq_valid = tq_wdata[0];// & ~mmio_stall_pipe0;
  assign tq_enq_valid = tq_wdata[0] & ff_cl_scalar_enq_ready;

  assign ff_cl_scalar_full_n = ff_cl_scalar_enq_ready;

  wire lsu0_start_tmp = (tq_deq_data == 1) & tq_deq_valid;
  wire lsu1_start_tmp = (tq_deq_data == 3) & tq_deq_valid;
  wire cl_start_tmp   = (tq_deq_data == 5) & tq_deq_valid;

  assign tq_deq_ready = (tq_deq_data == 1) |
                        (tq_deq_data == 2 & lsu0_done_pipe0) |
                        (tq_deq_data == 3) |
                        (tq_deq_data == 4 & lsu1_done_pipe0) |
                        (tq_deq_data == 5) |
                        (tq_deq_data == 6 & cl_done_pipe0);

  wire lsu0_enqueue = (tq_wdata[3:1] == 1) & tq_enq_valid & tq_enq_ready;
  wire lsu1_enqueue = (tq_wdata[3:1] == 3) & tq_enq_valid & tq_enq_ready;

  assign tq_empty_n = tq_deq_valid; 
  assign tq_full_n  = tq_enq_ready;

  pipe_block #(.WIDTH(1), .NUM_STAGES(2)) lsu0_start_reg (
    .clk(clk),
    .d(lsu0_start_tmp),
    .q(lsu0_start)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(2)) lsu1_start_reg (
    .clk(clk),
    .d(lsu1_start_tmp),
    .q(lsu1_start)
  );

  REGISTER #(.N(1)) cl_start_reg (
    .clk(clk),
    .d(cl_start_tmp),
    .q(cl_start)
  );

`ifdef DEBUG_MMIO
  always @(posedge clk) begin
    if (tq_enq_valid & tq_enq_ready === 1'b1)
      $display("[%t] [%m] TQ ENQ %h", $time, tq_enq_data);
    if (tq_deq_valid & tq_deq_ready === 1'b1)
      $display("[%t] [%m] TQ DEQ %h", $time, tq_deq_data);

    if (ff_cl_scalar_enq_valid & ff_cl_scalar_enq_ready === 1'b1)
      $display("[%t] [%m] ff_cl_scalar ENQ %h", $time, ff_cl_scalar_enq_data);
    if (ff_cl_scalar_deq_valid & ff_cl_scalar_deq_ready === 1'b1)
      $display("[%t] [%m] ff_cl_scalar DEQ %h", $time, ff_cl_scalar_deq_data);

    if (ff_cl_scalar_enq_ready === 1'b0)
      $display("[%t] [%m] CRITICAL WARNING: ff_cl_scalar full!", $time);
  end

  always @(posedge clk) begin
    if (tq_enq_ready === 1'b0) begin
      $display("[%t] [%m] CRITICAL WARNING: task queue is full!", $time);
    end
  end
`endif

//  localparam FIFO1_LOGDEPTH = FIFO_LOGDEPTH + 1;
  localparam FIFO1_LOGDEPTH = FIFO_LOGDEPTH;

  wire [31:0] ff_lsu0_ram_start_idx_enq_data, ff_lsu0_ram_start_idx_deq_data;
  wire ff_lsu0_ram_start_idx_enq_valid, ff_lsu0_ram_start_idx_enq_ready;
  wire ff_lsu0_ram_start_idx_deq_valid, ff_lsu0_ram_start_idx_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu0_ram_start_idx (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu0_ram_start_idx_enq_data),
    .enq_valid(ff_lsu0_ram_start_idx_enq_valid),
    .enq_ready(ff_lsu0_ram_start_idx_enq_ready),

    .deq_data(ff_lsu0_ram_start_idx_deq_data),
    .deq_valid(ff_lsu0_ram_start_idx_deq_valid),
    .deq_ready(ff_lsu0_ram_start_idx_deq_ready)
  );
  wire [31:0] ff_lsu0_ram_block_factor_enq_data, ff_lsu0_ram_block_factor_deq_data;
  wire ff_lsu0_ram_block_factor_enq_valid, ff_lsu0_ram_block_factor_enq_ready;
  wire ff_lsu0_ram_block_factor_deq_valid, ff_lsu0_ram_block_factor_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu0_ram_block_factor (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu0_ram_block_factor_enq_data),
    .enq_valid(ff_lsu0_ram_block_factor_enq_valid),
    .enq_ready(ff_lsu0_ram_block_factor_enq_ready),

    .deq_data(ff_lsu0_ram_block_factor_deq_data),
    .deq_valid(ff_lsu0_ram_block_factor_deq_valid),
    .deq_ready(ff_lsu0_ram_block_factor_deq_ready)
  );
  wire [31:0] ff_lsu0_ram_cyclic_factor_enq_data, ff_lsu0_ram_cyclic_factor_deq_data;
  wire ff_lsu0_ram_cyclic_factor_enq_valid, ff_lsu0_ram_cyclic_factor_enq_ready;
  wire ff_lsu0_ram_cyclic_factor_deq_valid, ff_lsu0_ram_cyclic_factor_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu0_ram_cyclic_factor (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu0_ram_cyclic_factor_enq_data),
    .enq_valid(ff_lsu0_ram_cyclic_factor_enq_valid),
    .enq_ready(ff_lsu0_ram_cyclic_factor_enq_ready),

    .deq_data(ff_lsu0_ram_cyclic_factor_deq_data),
    .deq_valid(ff_lsu0_ram_cyclic_factor_deq_valid),
    .deq_ready(ff_lsu0_ram_cyclic_factor_deq_ready)
  );
  wire [31:0] ff_lsu0_ram_stride_enq_data, ff_lsu0_ram_stride_deq_data;
  wire ff_lsu0_ram_stride_enq_valid, ff_lsu0_ram_stride_enq_ready;
  wire ff_lsu0_ram_stride_deq_valid, ff_lsu0_ram_stride_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu0_ram_stride (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu0_ram_stride_enq_data),
    .enq_valid(ff_lsu0_ram_stride_enq_valid),
    .enq_ready(ff_lsu0_ram_stride_enq_ready),

    .deq_data(ff_lsu0_ram_stride_deq_data),
    .deq_valid(ff_lsu0_ram_stride_deq_valid),
    .deq_ready(ff_lsu0_ram_stride_deq_ready)
  );
  wire [31:0] ff_lsu0_ram_seg_stride_enq_data, ff_lsu0_ram_seg_stride_deq_data;
  wire ff_lsu0_ram_seg_stride_enq_valid, ff_lsu0_ram_seg_stride_enq_ready;
  wire ff_lsu0_ram_seg_stride_deq_valid, ff_lsu0_ram_seg_stride_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu0_ram_seg_stride (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu0_ram_seg_stride_enq_data),
    .enq_valid(ff_lsu0_ram_seg_stride_enq_valid),
    .enq_ready(ff_lsu0_ram_seg_stride_enq_ready),

    .deq_data(ff_lsu0_ram_seg_stride_deq_data),
    .deq_valid(ff_lsu0_ram_seg_stride_deq_valid),
    .deq_ready(ff_lsu0_ram_seg_stride_deq_ready)
  );
  wire [31:0] ff_lsu0_ram_addr_offset_enq_data, ff_lsu0_ram_addr_offset_deq_data;
  wire ff_lsu0_ram_addr_offset_enq_valid, ff_lsu0_ram_addr_offset_enq_ready;
  wire ff_lsu0_ram_addr_offset_deq_valid, ff_lsu0_ram_addr_offset_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu0_ram_addr_offset (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu0_ram_addr_offset_enq_data),
    .enq_valid(ff_lsu0_ram_addr_offset_enq_valid),
    .enq_ready(ff_lsu0_ram_addr_offset_enq_ready),

    .deq_data(ff_lsu0_ram_addr_offset_deq_data),
    .deq_valid(ff_lsu0_ram_addr_offset_deq_valid),
    .deq_ready(ff_lsu0_ram_addr_offset_deq_ready)
  );
  wire [31:0] ff_lsu0_m_offset_lo_enq_data, ff_lsu0_m_offset_lo_deq_data;
  wire ff_lsu0_m_offset_lo_enq_valid, ff_lsu0_m_offset_lo_enq_ready;
  wire ff_lsu0_m_offset_lo_deq_valid, ff_lsu0_m_offset_lo_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu0_m_offset_lo (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu0_m_offset_lo_enq_data),
    .enq_valid(ff_lsu0_m_offset_lo_enq_valid),
    .enq_ready(ff_lsu0_m_offset_lo_enq_ready),

    .deq_data(ff_lsu0_m_offset_lo_deq_data),
    .deq_valid(ff_lsu0_m_offset_lo_deq_valid),
    .deq_ready(ff_lsu0_m_offset_lo_deq_ready)
  );
  wire [31:0] ff_lsu0_m_offset_hi_enq_data, ff_lsu0_m_offset_hi_deq_data;
  wire ff_lsu0_m_offset_hi_enq_valid, ff_lsu0_m_offset_hi_enq_ready;
  wire ff_lsu0_m_offset_hi_deq_valid, ff_lsu0_m_offset_hi_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu0_m_offset_hi (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu0_m_offset_hi_enq_data),
    .enq_valid(ff_lsu0_m_offset_hi_enq_valid),
    .enq_ready(ff_lsu0_m_offset_hi_enq_ready),

    .deq_data(ff_lsu0_m_offset_hi_deq_data),
    .deq_valid(ff_lsu0_m_offset_hi_deq_valid),
    .deq_ready(ff_lsu0_m_offset_hi_deq_ready)
  );
  wire [31:0] ff_lsu0_seg_stride_enq_data, ff_lsu0_seg_stride_deq_data;
  wire ff_lsu0_seg_stride_enq_valid, ff_lsu0_seg_stride_enq_ready;
  wire ff_lsu0_seg_stride_deq_valid, ff_lsu0_seg_stride_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu0_seg_stride (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu0_seg_stride_enq_data),
    .enq_valid(ff_lsu0_seg_stride_enq_valid),
    .enq_ready(ff_lsu0_seg_stride_enq_ready),

    .deq_data(ff_lsu0_seg_stride_deq_data),
    .deq_valid(ff_lsu0_seg_stride_deq_valid),
    .deq_ready(ff_lsu0_seg_stride_deq_ready)
  );
  wire [31:0] ff_lsu0_seg_count_enq_data, ff_lsu0_seg_count_deq_data;
  wire ff_lsu0_seg_count_enq_valid, ff_lsu0_seg_count_enq_ready;
  wire ff_lsu0_seg_count_deq_valid, ff_lsu0_seg_count_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu0_seg_count (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu0_seg_count_enq_data),
    .enq_valid(ff_lsu0_seg_count_enq_valid),
    .enq_ready(ff_lsu0_seg_count_enq_ready),

    .deq_data(ff_lsu0_seg_count_deq_data),
    .deq_valid(ff_lsu0_seg_count_deq_valid),
    .deq_ready(ff_lsu0_seg_count_deq_ready)
  );
  wire [31:0] ff_lsu0_len_enq_data, ff_lsu0_len_deq_data;
  wire ff_lsu0_len_enq_valid, ff_lsu0_len_enq_ready;
  wire ff_lsu0_len_deq_valid, ff_lsu0_len_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu0_len (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu0_len_enq_data),
    .enq_valid(ff_lsu0_len_enq_valid),
    .enq_ready(ff_lsu0_len_enq_ready),

    .deq_data(ff_lsu0_len_deq_data),
    .deq_valid(ff_lsu0_len_deq_valid),
    .deq_ready(ff_lsu0_len_deq_ready)
  );
  wire [31:0] ff_lsu0_mode_enq_data, ff_lsu0_mode_deq_data;
  wire ff_lsu0_mode_enq_valid, ff_lsu0_mode_enq_ready;
  wire ff_lsu0_mode_deq_valid, ff_lsu0_mode_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu0_mode (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu0_mode_enq_data),
    .enq_valid(ff_lsu0_mode_enq_valid),
    .enq_ready(ff_lsu0_mode_enq_ready),

    .deq_data(ff_lsu0_mode_deq_data),
    .deq_valid(ff_lsu0_mode_deq_valid),
    .deq_ready(ff_lsu0_mode_deq_ready)
  );

`ifndef SOCKET_S
  wire [31:0] ff_lsu1_ram_start_idx_enq_data, ff_lsu1_ram_start_idx_deq_data;
  wire ff_lsu1_ram_start_idx_enq_valid, ff_lsu1_ram_start_idx_enq_ready;
  wire ff_lsu1_ram_start_idx_deq_valid, ff_lsu1_ram_start_idx_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu1_ram_start_idx (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu1_ram_start_idx_enq_data),
    .enq_valid(ff_lsu1_ram_start_idx_enq_valid),
    .enq_ready(ff_lsu1_ram_start_idx_enq_ready),

    .deq_data(ff_lsu1_ram_start_idx_deq_data),
    .deq_valid(ff_lsu1_ram_start_idx_deq_valid),
    .deq_ready(ff_lsu1_ram_start_idx_deq_ready)
  );
  wire [31:0] ff_lsu1_ram_block_factor_enq_data, ff_lsu1_ram_block_factor_deq_data;
  wire ff_lsu1_ram_block_factor_enq_valid, ff_lsu1_ram_block_factor_enq_ready;
  wire ff_lsu1_ram_block_factor_deq_valid, ff_lsu1_ram_block_factor_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu1_ram_block_factor (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu1_ram_block_factor_enq_data),
    .enq_valid(ff_lsu1_ram_block_factor_enq_valid),
    .enq_ready(ff_lsu1_ram_block_factor_enq_ready),

    .deq_data(ff_lsu1_ram_block_factor_deq_data),
    .deq_valid(ff_lsu1_ram_block_factor_deq_valid),
    .deq_ready(ff_lsu1_ram_block_factor_deq_ready)
  );
  wire [31:0] ff_lsu1_ram_cyclic_factor_enq_data, ff_lsu1_ram_cyclic_factor_deq_data;
  wire ff_lsu1_ram_cyclic_factor_enq_valid, ff_lsu1_ram_cyclic_factor_enq_ready;
  wire ff_lsu1_ram_cyclic_factor_deq_valid, ff_lsu1_ram_cyclic_factor_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu1_ram_cyclic_factor (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu1_ram_cyclic_factor_enq_data),
    .enq_valid(ff_lsu1_ram_cyclic_factor_enq_valid),
    .enq_ready(ff_lsu1_ram_cyclic_factor_enq_ready),

    .deq_data(ff_lsu1_ram_cyclic_factor_deq_data),
    .deq_valid(ff_lsu1_ram_cyclic_factor_deq_valid),
    .deq_ready(ff_lsu1_ram_cyclic_factor_deq_ready)
  );
  wire [31:0] ff_lsu1_ram_stride_enq_data, ff_lsu1_ram_stride_deq_data;
  wire ff_lsu1_ram_stride_enq_valid, ff_lsu1_ram_stride_enq_ready;
  wire ff_lsu1_ram_stride_deq_valid, ff_lsu1_ram_stride_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu1_ram_stride (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu1_ram_stride_enq_data),
    .enq_valid(ff_lsu1_ram_stride_enq_valid),
    .enq_ready(ff_lsu1_ram_stride_enq_ready),

    .deq_data(ff_lsu1_ram_stride_deq_data),
    .deq_valid(ff_lsu1_ram_stride_deq_valid),
    .deq_ready(ff_lsu1_ram_stride_deq_ready)
  );
  wire [31:0] ff_lsu1_ram_seg_stride_enq_data, ff_lsu1_ram_seg_stride_deq_data;
  wire ff_lsu1_ram_seg_stride_enq_valid, ff_lsu1_ram_seg_stride_enq_ready;
  wire ff_lsu1_ram_seg_stride_deq_valid, ff_lsu1_ram_seg_stride_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu1_ram_seg_stride (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu1_ram_seg_stride_enq_data),
    .enq_valid(ff_lsu1_ram_seg_stride_enq_valid),
    .enq_ready(ff_lsu1_ram_seg_stride_enq_ready),

    .deq_data(ff_lsu1_ram_seg_stride_deq_data),
    .deq_valid(ff_lsu1_ram_seg_stride_deq_valid),
    .deq_ready(ff_lsu1_ram_seg_stride_deq_ready)
  );
  wire [31:0] ff_lsu1_ram_addr_offset_enq_data, ff_lsu1_ram_addr_offset_deq_data;
  wire ff_lsu1_ram_addr_offset_enq_valid, ff_lsu1_ram_addr_offset_enq_ready;
  wire ff_lsu1_ram_addr_offset_deq_valid, ff_lsu1_ram_addr_offset_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu1_ram_addr_offset (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu1_ram_addr_offset_enq_data),
    .enq_valid(ff_lsu1_ram_addr_offset_enq_valid),
    .enq_ready(ff_lsu1_ram_addr_offset_enq_ready),

    .deq_data(ff_lsu1_ram_addr_offset_deq_data),
    .deq_valid(ff_lsu1_ram_addr_offset_deq_valid),
    .deq_ready(ff_lsu1_ram_addr_offset_deq_ready)
  );
  wire [31:0] ff_lsu1_m_offset_lo_enq_data, ff_lsu1_m_offset_lo_deq_data;
  wire ff_lsu1_m_offset_lo_enq_valid, ff_lsu1_m_offset_lo_enq_ready;
  wire ff_lsu1_m_offset_lo_deq_valid, ff_lsu1_m_offset_lo_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu1_m_offset_lo (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu1_m_offset_lo_enq_data),
    .enq_valid(ff_lsu1_m_offset_lo_enq_valid),
    .enq_ready(ff_lsu1_m_offset_lo_enq_ready),

    .deq_data(ff_lsu1_m_offset_lo_deq_data),
    .deq_valid(ff_lsu1_m_offset_lo_deq_valid),
    .deq_ready(ff_lsu1_m_offset_lo_deq_ready)
  );
  wire [31:0] ff_lsu1_m_offset_hi_enq_data, ff_lsu1_m_offset_hi_deq_data;
  wire ff_lsu1_m_offset_hi_enq_valid, ff_lsu1_m_offset_hi_enq_ready;
  wire ff_lsu1_m_offset_hi_deq_valid, ff_lsu1_m_offset_hi_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu1_m_offset_hi (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu1_m_offset_hi_enq_data),
    .enq_valid(ff_lsu1_m_offset_hi_enq_valid),
    .enq_ready(ff_lsu1_m_offset_hi_enq_ready),

    .deq_data(ff_lsu1_m_offset_hi_deq_data),
    .deq_valid(ff_lsu1_m_offset_hi_deq_valid),
    .deq_ready(ff_lsu1_m_offset_hi_deq_ready)
  );
  wire [31:0] ff_lsu1_seg_stride_enq_data, ff_lsu1_seg_stride_deq_data;
  wire ff_lsu1_seg_stride_enq_valid, ff_lsu1_seg_stride_enq_ready;
  wire ff_lsu1_seg_stride_deq_valid, ff_lsu1_seg_stride_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu1_seg_stride (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu1_seg_stride_enq_data),
    .enq_valid(ff_lsu1_seg_stride_enq_valid),
    .enq_ready(ff_lsu1_seg_stride_enq_ready),

    .deq_data(ff_lsu1_seg_stride_deq_data),
    .deq_valid(ff_lsu1_seg_stride_deq_valid),
    .deq_ready(ff_lsu1_seg_stride_deq_ready)
  );
  wire [31:0] ff_lsu1_seg_count_enq_data, ff_lsu1_seg_count_deq_data;
  wire ff_lsu1_seg_count_enq_valid, ff_lsu1_seg_count_enq_ready;
  wire ff_lsu1_seg_count_deq_valid, ff_lsu1_seg_count_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu1_seg_count (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu1_seg_count_enq_data),
    .enq_valid(ff_lsu1_seg_count_enq_valid),
    .enq_ready(ff_lsu1_seg_count_enq_ready),

    .deq_data(ff_lsu1_seg_count_deq_data),
    .deq_valid(ff_lsu1_seg_count_deq_valid),
    .deq_ready(ff_lsu1_seg_count_deq_ready)
  );
  wire [31:0] ff_lsu1_len_enq_data, ff_lsu1_len_deq_data;
  wire ff_lsu1_len_enq_valid, ff_lsu1_len_enq_ready;
  wire ff_lsu1_len_deq_valid, ff_lsu1_len_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu1_len (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu1_len_enq_data),
    .enq_valid(ff_lsu1_len_enq_valid),
    .enq_ready(ff_lsu1_len_enq_ready),

    .deq_data(ff_lsu1_len_deq_data),
    .deq_valid(ff_lsu1_len_deq_valid),
    .deq_ready(ff_lsu1_len_deq_ready)
  );
  wire [31:0] ff_lsu1_mode_enq_data, ff_lsu1_mode_deq_data;
  wire ff_lsu1_mode_enq_valid, ff_lsu1_mode_enq_ready;
  wire ff_lsu1_mode_deq_valid, ff_lsu1_mode_deq_ready;
  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO1_LOGDEPTH)
  ) ff_lsu1_mode (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_lsu1_mode_enq_data),
    .enq_valid(ff_lsu1_mode_enq_valid),
    .enq_ready(ff_lsu1_mode_enq_ready),

    .deq_data(ff_lsu1_mode_deq_data),
    .deq_valid(ff_lsu1_mode_deq_valid),
    .deq_ready(ff_lsu1_mode_deq_ready)
  );
`endif

  always @(posedge clk) begin
    if (ff_lsu0_ram_start_idx_enq_ready === 1'b0) begin
      $display("[%t] [%m] CRITICAL WARNING lsu0 config queue full!", $time);
    end
`ifndef SOCKET_S
    if (ff_lsu1_ram_start_idx_enq_ready === 1'b0) begin
      $display("[%t] [%m] CRITICAL WARNING lsu1 config queue full!", $time);
    end
`endif
  end

  assign ff_lsu0_ram_start_idx_enq_data      = lsu0_ram_start_idx_tmp;
  assign ff_lsu0_ram_start_idx_enq_valid     = lsu0_enqueue;
  assign ff_lsu0_ram_block_factor_enq_data   = lsu0_ram_block_factor_tmp;
  assign ff_lsu0_ram_block_factor_enq_valid  = lsu0_enqueue;
  assign ff_lsu0_ram_cyclic_factor_enq_data  = lsu0_ram_cyclic_factor_tmp;
  assign ff_lsu0_ram_cyclic_factor_enq_valid = lsu0_enqueue;
  assign ff_lsu0_ram_stride_enq_data         = lsu0_ram_stride_tmp;
  assign ff_lsu0_ram_stride_enq_valid        = lsu0_enqueue;
  assign ff_lsu0_ram_seg_stride_enq_data     = lsu0_ram_seg_stride_tmp;
  assign ff_lsu0_ram_seg_stride_enq_valid    = lsu0_enqueue;
  assign ff_lsu0_ram_addr_offset_enq_data    = lsu0_ram_addr_offset_tmp;
  assign ff_lsu0_ram_addr_offset_enq_valid   = lsu0_enqueue;

  assign ff_lsu0_m_offset_lo_enq_data  = lsu0_m_offset_lo_tmp;
  assign ff_lsu0_m_offset_lo_enq_valid = lsu0_enqueue;
  assign ff_lsu0_m_offset_hi_enq_data  = lsu0_m_offset_hi_tmp;
  assign ff_lsu0_m_offset_hi_enq_valid = lsu0_enqueue;
  assign ff_lsu0_seg_stride_enq_data   = lsu0_seg_stride_tmp;
  assign ff_lsu0_seg_stride_enq_valid  = lsu0_enqueue;
  assign ff_lsu0_seg_count_enq_data    = lsu0_seg_count_tmp;
  assign ff_lsu0_seg_count_enq_valid   = lsu0_enqueue;
  assign ff_lsu0_len_enq_data          = lsu0_len_tmp;
  assign ff_lsu0_len_enq_valid         = lsu0_enqueue;
  assign ff_lsu0_mode_enq_data         = lsu0_mode_tmp;
  assign ff_lsu0_mode_enq_valid        = lsu0_enqueue;

`ifndef SOCKET_S
  assign ff_lsu1_ram_start_idx_enq_data      = lsu1_ram_start_idx_tmp;
  assign ff_lsu1_ram_start_idx_enq_valid     = lsu1_enqueue;
  assign ff_lsu1_ram_block_factor_enq_data   = lsu1_ram_block_factor_tmp;
  assign ff_lsu1_ram_block_factor_enq_valid  = lsu1_enqueue;
  assign ff_lsu1_ram_cyclic_factor_enq_data  = lsu1_ram_cyclic_factor_tmp;
  assign ff_lsu1_ram_cyclic_factor_enq_valid = lsu1_enqueue;
  assign ff_lsu1_ram_stride_enq_data         = lsu1_ram_stride_tmp;
  assign ff_lsu1_ram_stride_enq_valid        = lsu1_enqueue;
  assign ff_lsu1_ram_seg_stride_enq_data     = lsu1_ram_seg_stride_tmp;
  assign ff_lsu1_ram_seg_stride_enq_valid    = lsu1_enqueue;
  assign ff_lsu1_ram_addr_offset_enq_data    = lsu1_ram_addr_offset_tmp;
  assign ff_lsu1_ram_addr_offset_enq_valid   = lsu1_enqueue;

  assign ff_lsu1_m_offset_lo_enq_data  = lsu1_m_offset_lo_tmp;
  assign ff_lsu1_m_offset_lo_enq_valid = lsu1_enqueue;
  assign ff_lsu1_m_offset_hi_enq_data  = lsu1_m_offset_hi_tmp;
  assign ff_lsu1_m_offset_hi_enq_valid = lsu1_enqueue;
  assign ff_lsu1_seg_stride_enq_data   = lsu1_seg_stride_tmp;
  assign ff_lsu1_seg_stride_enq_valid  = lsu1_enqueue;
  assign ff_lsu1_seg_count_enq_data    = lsu1_seg_count_tmp;
  assign ff_lsu1_seg_count_enq_valid   = lsu1_enqueue;
  assign ff_lsu1_len_enq_data          = lsu1_len_tmp;
  assign ff_lsu1_len_enq_valid         = lsu1_enqueue;
  assign ff_lsu1_mode_enq_data         = lsu1_mode_tmp;
  assign ff_lsu1_mode_enq_valid        = lsu1_enqueue;
`endif

  REGISTER_CE #(.N(32)) lsu0_ram_start_idx_reg (
    .clk(clk),
    .ce(ff_lsu0_ram_start_idx_deq_valid & ff_lsu0_ram_start_idx_deq_ready),
    .d(ff_lsu0_ram_start_idx_deq_data),
    .q(lsu0_ram_start_idx)
  );
  REGISTER_CE #(.N(32)) lsu0_ram_block_factor_reg (
    .clk(clk),
    .ce(ff_lsu0_ram_block_factor_deq_valid & ff_lsu0_ram_block_factor_deq_ready),
    .d(ff_lsu0_ram_block_factor_deq_data),
    .q(lsu0_ram_block_factor)
  );
  REGISTER_CE #(.N(32)) lsu0_ram_cyclic_factor_reg (
    .clk(clk),
    .ce(ff_lsu0_ram_cyclic_factor_deq_valid & ff_lsu0_ram_cyclic_factor_deq_ready),
    .d(ff_lsu0_ram_cyclic_factor_deq_data),
    .q(lsu0_ram_cyclic_factor)
  );
  REGISTER_CE #(.N(32)) lsu0_ram_stride_reg (
    .clk(clk),
    .ce(ff_lsu0_ram_stride_deq_valid & ff_lsu0_ram_stride_deq_ready),
    .d(ff_lsu0_ram_stride_deq_data),
    .q(lsu0_ram_stride)
  );
  REGISTER_CE #(.N(32)) lsu0_ram_seg_stride_reg (
    .clk(clk),
    .ce(ff_lsu0_ram_seg_stride_deq_valid & ff_lsu0_ram_seg_stride_deq_ready),
    .d(ff_lsu0_ram_seg_stride_deq_data),
    .q(lsu0_ram_seg_stride)
  );
  REGISTER_CE #(.N(32)) lsu0_ram_addr_offset_reg (
    .clk(clk),
    .ce(ff_lsu0_ram_addr_offset_deq_valid & ff_lsu0_ram_addr_offset_deq_ready),
    .d(ff_lsu0_ram_addr_offset_deq_data),
    .q(lsu0_ram_addr_offset)
  );

  REGISTER_CE #(.N(32)) lsu0_m_offset_lo_reg (
    .clk(clk),
    .ce(ff_lsu0_m_offset_lo_deq_valid & ff_lsu0_m_offset_lo_deq_ready),
    .d(ff_lsu0_m_offset_lo_deq_data),
    .q(lsu0_m_offset_lo)
  );
  REGISTER_CE #(.N(32)) lsu0_m_offset_hi_reg (
    .clk(clk),
    .ce(ff_lsu0_m_offset_hi_deq_valid & ff_lsu0_m_offset_hi_deq_ready),
    .d(ff_lsu0_m_offset_hi_deq_data),
    .q(lsu0_m_offset_hi)
  );
  REGISTER_CE #(.N(32)) lsu0_seg_stride_reg (
    .clk(clk),
    .ce(ff_lsu0_seg_stride_deq_valid & ff_lsu0_seg_stride_deq_ready),
    .d(ff_lsu0_seg_stride_deq_data),
    .q(lsu0_seg_stride)
  );
  REGISTER_CE #(.N(32)) lsu0_seg_count_reg (
    .clk(clk),
    .ce(ff_lsu0_seg_count_deq_valid & ff_lsu0_seg_count_deq_ready),
    .d(ff_lsu0_seg_count_deq_data),
    .q(lsu0_seg_count)
  );
  REGISTER_CE #(.N(32)) lsu0_len_reg (
    .clk(clk),
    .ce(ff_lsu0_len_deq_valid & ff_lsu0_len_deq_ready),
    .d(ff_lsu0_len_deq_data),
    .q(lsu0_len)
  );
  REGISTER_CE #(.N(32)) lsu0_mode_reg (
    .clk(clk),
    .ce(ff_lsu0_mode_deq_valid & ff_lsu0_mode_deq_ready),
    .d(ff_lsu0_mode_deq_data),
    .q(lsu0_mode)
  );

`ifndef SOCKET_S
  REGISTER_CE #(.N(32)) lsu1_ram_start_idx_reg (
    .clk(clk),
    .ce(ff_lsu1_ram_start_idx_deq_valid & ff_lsu1_ram_start_idx_deq_ready),
    .d(ff_lsu1_ram_start_idx_deq_data),
    .q(lsu1_ram_start_idx)
  );
  REGISTER_CE #(.N(32)) lsu1_ram_block_factor_reg (
    .clk(clk),
    .ce(ff_lsu1_ram_block_factor_deq_valid & ff_lsu1_ram_block_factor_deq_ready),
    .d(ff_lsu1_ram_block_factor_deq_data),
    .q(lsu1_ram_block_factor)
  );
  REGISTER_CE #(.N(32)) lsu1_ram_cyclic_factor_reg (
    .clk(clk),
    .ce(ff_lsu1_ram_cyclic_factor_deq_valid & ff_lsu1_ram_cyclic_factor_deq_ready),
    .d(ff_lsu1_ram_cyclic_factor_deq_data),
    .q(lsu1_ram_cyclic_factor)
  );
  REGISTER_CE #(.N(32)) lsu1_ram_stride_reg (
    .clk(clk),
    .ce(ff_lsu1_ram_stride_deq_valid & ff_lsu1_ram_stride_deq_ready),
    .d(ff_lsu1_ram_stride_deq_data),
    .q(lsu1_ram_stride)
  );
  REGISTER_CE #(.N(32)) lsu1_ram_seg_stride_reg (
    .clk(clk),
    .ce(ff_lsu1_ram_seg_stride_deq_valid & ff_lsu1_ram_seg_stride_deq_ready),
    .d(ff_lsu1_ram_seg_stride_deq_data),
    .q(lsu1_ram_seg_stride)
  );
  REGISTER_CE #(.N(32)) lsu1_ram_addr_offset_reg (
    .clk(clk),
    .ce(ff_lsu1_ram_addr_offset_deq_valid & ff_lsu1_ram_addr_offset_deq_ready),
    .d(ff_lsu1_ram_addr_offset_deq_data),
    .q(lsu1_ram_addr_offset)
  );

  REGISTER_CE #(.N(32)) lsu1_m_offset_lo_reg (
    .clk(clk),
    .ce(ff_lsu1_m_offset_lo_deq_valid & ff_lsu1_m_offset_lo_deq_ready),
    .d(ff_lsu1_m_offset_lo_deq_data),
    .q(lsu1_m_offset_lo)
  );
  REGISTER_CE #(.N(32)) lsu1_m_offset_hi_reg (
    .clk(clk),
    .ce(ff_lsu1_m_offset_hi_deq_valid & ff_lsu1_m_offset_hi_deq_ready),
    .d(ff_lsu1_m_offset_hi_deq_data),
    .q(lsu1_m_offset_hi)
  );
  REGISTER_CE #(.N(32)) lsu1_seg_stride_reg (
    .clk(clk),
    .ce(ff_lsu1_seg_stride_deq_valid & ff_lsu1_seg_stride_deq_ready),
    .d(ff_lsu1_seg_stride_deq_data),
    .q(lsu1_seg_stride)
  );
  REGISTER_CE #(.N(32)) lsu1_seg_count_reg (
    .clk(clk),
    .ce(ff_lsu1_seg_count_deq_valid & ff_lsu1_seg_count_deq_ready),
    .d(ff_lsu1_seg_count_deq_data),
    .q(lsu1_seg_count)
  );
  REGISTER_CE #(.N(32)) lsu1_len_reg (
    .clk(clk),
    .ce(ff_lsu1_len_deq_valid & ff_lsu1_len_deq_ready),
    .d(ff_lsu1_len_deq_data),
    .q(lsu1_len)
  );
  REGISTER_CE #(.N(32)) lsu1_mode_reg (
    .clk(clk),
    .ce(ff_lsu1_mode_deq_valid & ff_lsu1_mode_deq_ready),
    .d(ff_lsu1_mode_deq_data),
    .q(lsu1_mode)
  );
`endif

  assign ff_lsu0_ram_start_idx_deq_ready     = lsu0_start_tmp;
  assign ff_lsu0_ram_block_factor_deq_ready  = lsu0_start_tmp;
  assign ff_lsu0_ram_cyclic_factor_deq_ready = lsu0_start_tmp;
  assign ff_lsu0_ram_stride_deq_ready        = lsu0_start_tmp;
  assign ff_lsu0_ram_seg_stride_deq_ready    = lsu0_start_tmp;
  assign ff_lsu0_ram_addr_offset_deq_ready   = lsu0_start_tmp;

  assign ff_lsu0_m_offset_lo_deq_ready = lsu0_start_tmp;
  assign ff_lsu0_m_offset_hi_deq_ready = lsu0_start_tmp;
  assign ff_lsu0_seg_stride_deq_ready  = lsu0_start_tmp;
  assign ff_lsu0_seg_count_deq_ready   = lsu0_start_tmp;
  assign ff_lsu0_len_deq_ready         = lsu0_start_tmp;
  assign ff_lsu0_mode_deq_ready        = lsu0_start_tmp;

`ifndef SOCKET_S
  assign ff_lsu1_ram_start_idx_deq_ready     = lsu1_start_tmp;
  assign ff_lsu1_ram_block_factor_deq_ready  = lsu1_start_tmp;
  assign ff_lsu1_ram_cyclic_factor_deq_ready = lsu1_start_tmp;
  assign ff_lsu1_ram_stride_deq_ready        = lsu1_start_tmp;
  assign ff_lsu1_ram_seg_stride_deq_ready    = lsu1_start_tmp;
  assign ff_lsu1_ram_addr_offset_deq_ready   = lsu1_start_tmp;

  assign ff_lsu1_m_offset_lo_deq_ready = lsu1_start_tmp;
  assign ff_lsu1_m_offset_hi_deq_ready = lsu1_start_tmp;
  assign ff_lsu1_seg_stride_deq_ready  = lsu1_start_tmp;
  assign ff_lsu1_seg_count_deq_ready   = lsu1_start_tmp;
  assign ff_lsu1_len_deq_ready         = lsu1_start_tmp;
  assign ff_lsu1_mode_deq_ready        = lsu1_start_tmp;
`endif

  reg [31:0] lsu0_cycle_cnt;
  always @(posedge clk) begin
    if (resetn === 1'b0)
      lsu0_cycle_cnt <= 0;
    else begin
      if (lsu0_done === 1'b1)
        lsu0_cycle_cnt <= 0;
      else if (lsu0_start === 1'b1 || lsu0_cycle_cnt !== 0)
        lsu0_cycle_cnt <= lsu0_cycle_cnt + 1;
    end
  end

`ifndef SOCKET_S
  reg [31:0] lsu1_cycle_cnt;
  always @(posedge clk) begin
    if (resetn === 1'b0)
      lsu1_cycle_cnt <= 0;
    else begin
      if (lsu1_done === 1'b1)
        lsu1_cycle_cnt <= 0;
      else if (lsu1_start === 1'b1 || lsu1_cycle_cnt !== 0)
        lsu1_cycle_cnt <= lsu1_cycle_cnt + 1;
    end
  end
`endif

  reg [31:0] cl_cycle_cnt;
  always @(posedge clk) begin
    if (resetn === 1'b0)
      cl_cycle_cnt <= 0;
    else begin
      if (cl_done === 1'b0 && cl_running === 1'b1)
        cl_cycle_cnt <= cl_cycle_cnt + 1;
      else if (cl_done === 1'b1 && cl_running === 1'b1)
        cl_cycle_cnt <= 0;
    end
  end

  always @(posedge clk) begin
    if (lsu0_start === 1'b1)
      $display("[%t] [%m] task lsu0 started, cfg = [%h %h %h %h %h %h %h %h %h %h %h %h]",
        $time, lsu0_ram_start_idx, lsu0_ram_block_factor, lsu0_ram_cyclic_factor,
        lsu0_ram_stride, lsu0_ram_seg_stride, lsu0_ram_addr_offset,
        lsu0_m_offset_lo, lsu0_m_offset_hi, lsu0_seg_stride, lsu0_seg_count,
        lsu0_len, lsu0_mode
      );
    if (lsu0_done === 1'b1)
      $display("[%t] [%m] task lsu0 done, cycle_cnt=%d", $time, lsu0_cycle_cnt);

`ifndef SOCKET_S
    if (lsu1_start === 1'b1)
      $display("[%t] [%m] task lsu1 started, cfg = [%h %h %h %h %h %h %h %h %h %h %h %h]",
        $time, lsu1_ram_start_idx, lsu1_ram_block_factor, lsu1_ram_cyclic_factor,
        lsu1_ram_stride, lsu1_ram_seg_stride, lsu1_ram_addr_offset,
        lsu1_m_offset_lo, lsu1_m_offset_hi, lsu1_seg_stride, lsu1_seg_count,
        lsu1_len, lsu1_mode
      );
    if (lsu1_done === 1'b1)
      $display("[%t] [%m] task lsu1 done, cycle_cnt=%d", $time, lsu1_cycle_cnt);
`endif

    if (cl_start === 1'b1) begin
      $display("[%t] [%m] task cl started", $time);
    end
    if (cl_done === 1'b1 && cl_running === 1'b1) begin
      $display("[%t] [%m] task cl done, cycle_cnt=%d", $time, cl_cycle_cnt);
    end
  end

endmodule

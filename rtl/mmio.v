
`timescale 1ns/1ps
`include "socket_config.vh"

// This MMIO control block only handles the DMA (and sync points)
// The kernel block should have its own S-AXI lite interface
module mmio #(
  parameter DMEM_AWIDTH = 32,
  parameter DMEM_DWIDTH = 32,
  parameter NUM_SYNCS = 16
) (
  input clk,
  input resetn,

  input  [31:0] mmio_addr,
  input  [31:0] mmio_din,
  output [31:0] mmio_dout,
  input         mmio_wen,
  input         mmio_ren,

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

  output [31:0] comm0_mode,

`ifndef SOCKET_S
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

  output [31:0] comm1_mode,

  output  lsu1_start,
  input   lsu1_done,
`endif

  output [31:0] tq_wdata,
  input         tq_empty_n,
  input         tq_full_n,
  input         tq_enq_fire,
  input         ff_cl_scalar_full_n,
  input task_empty,

  input [NUM_SYNCS-1:0] sync_en,

  output [31:0] squeue_out_data,
  output        squeue_out_valid,
  input         squeue_out_ready,

  input [31:0] socket_inbox,

  output socket_done
);

  wire [NUM_SYNCS-1:0] sync_next, sync_value;
  wire [NUM_SYNCS-1:0] sync_ce, sync_rst;

  genvar i;
  generate
    for (i = 0; i < NUM_SYNCS; i = i + 1) begin
      REGISTER_R_CE #(.N(1), .INIT(0)) sync_reg (
        .clk(clk),
        .rst(sync_rst[i]),
        .ce(sync_ce[i]),
        .d(sync_next[i]),
        .q(sync_value[i])
      );
    end
  endgenerate

  wire [31:0] raddr_pipe0;

  REGISTER_CE #(.N(32)) raddr_pipe0_reg (
    .clk(clk),
    .d(mmio_addr),
    .q(raddr_pipe0),
    .ce(mmio_ren)
  );

  wire [31:0] mem_unit_ctrl_next, mem_unit_ctrl_value;
  wire mem_unit_ctrl_ce, mem_unit_ctrl_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) mem_unit_ctrl_reg (
    .clk(clk),
    .rst(mem_unit_ctrl_rst),
    .ce(mem_unit_ctrl_ce),
    .d(mem_unit_ctrl_next),
    .q(mem_unit_ctrl_value)
  );

  wire [31:0] mem_unit_addr_next, mem_unit_addr_value;
  wire mem_unit_addr_ce, mem_unit_addr_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) mem_unit_addr_reg (
    .clk(clk),
    .rst(mem_unit_addr_rst),
    .ce(mem_unit_addr_ce),
    .d(mem_unit_addr_next),
    .q(mem_unit_addr_value)
  );

  wire [31:0] mem_unit_wdata_next, mem_unit_wdata_value;
  wire mem_unit_wdata_ce, mem_unit_wdata_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) mem_unit_wdata_reg (
    .clk(clk),
    .rst(mem_unit_wdata_rst),
    .ce(mem_unit_wdata_ce),
    .d(mem_unit_wdata_next),
    .q(mem_unit_wdata_value)
  );

  wire [31:0] mem_unit_rdata_next, mem_unit_rdata_value;
  wire mem_unit_rdata_ce, mem_unit_rdata_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) mem_unit_rdata_reg (
    .clk(clk),
    .rst(mem_unit_rdata_rst),
    .ce(mem_unit_rdata_ce),
    .d(mem_unit_rdata_next),
    .q(mem_unit_rdata_value)
  );

  wire [31:0] cpu_status_next, cpu_status_value;
  wire cpu_status_ce, cpu_status_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) cpu_status_reg (
    .clk(clk),
    .rst(cpu_status_rst),
    .d(cpu_status_next),
    .q(cpu_status_value),
    .ce(cpu_status_ce)
  );

  wire [31:0] ctrl_maxi_read_next, ctrl_maxi_read_value;
  wire ctrl_maxi_read_ce, ctrl_maxi_read_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) ctrl_maxi_read_reg (
    .clk(clk),
    .rst(ctrl_maxi_read_rst),
    .d(ctrl_maxi_read_next),
    .q(ctrl_maxi_read_value),
    .ce(ctrl_maxi_read_ce)
  );

  wire [31:0] ctrl_maxi_write_next, ctrl_maxi_write_value;
  wire ctrl_maxi_write_ce, ctrl_maxi_write_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) ctrl_maxi_write_reg (
    .clk(clk),
    .rst(ctrl_maxi_write_rst),
    .d(ctrl_maxi_write_next),
    .q(ctrl_maxi_write_value),
    .ce(ctrl_maxi_write_ce)
  );

  wire [31:0] ctrl_maxi_wdata_next, ctrl_maxi_wdata_value;
  wire ctrl_maxi_wdata_ce, ctrl_maxi_wdata_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) ctrl_maxi_wdata_reg (
    .clk(clk),
    .rst(ctrl_maxi_wdata_rst),
    .d(ctrl_maxi_wdata_next),
    .q(ctrl_maxi_wdata_value),
    .ce(ctrl_maxi_wdata_ce)
  );

  wire [31:0] ctrl_maxi_socket_offset_lo_next, ctrl_maxi_socket_offset_lo_value;
  wire ctrl_maxi_socket_offset_lo_ce, ctrl_maxi_socket_offset_lo_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) ctrl_maxi_socket_offset_lo_reg (
    .clk(clk),
    .rst(ctrl_maxi_socket_offset_lo_rst),
    .d(ctrl_maxi_socket_offset_lo_next),
    .q(ctrl_maxi_socket_offset_lo_value),
    .ce(ctrl_maxi_socket_offset_lo_ce)
  );

  wire [31:0] ctrl_maxi_socket_offset_hi_next, ctrl_maxi_socket_offset_hi_value;
  wire ctrl_maxi_socket_offset_hi_ce, ctrl_maxi_socket_offset_hi_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) ctrl_maxi_socket_offset_hi_reg (
    .clk(clk),
    .rst(ctrl_maxi_socket_offset_hi_rst),
    .d(ctrl_maxi_socket_offset_hi_next),
    .q(ctrl_maxi_socket_offset_hi_value),
    .ce(ctrl_maxi_socket_offset_hi_ce)
  );

  wire [31:0] lsu0_csr_next, lsu0_csr_value;
  wire lsu0_csr_ce, lsu0_csr_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu0_csr_reg (
    .clk(clk),
    .rst(lsu0_csr_rst),
    .d(lsu0_csr_next),
    .q(lsu0_csr_value),
    .ce(lsu0_csr_ce)
  );

  wire [31:0] lsu0_ram_start_idx_next, lsu0_ram_start_idx_value;
  wire lsu0_ram_start_idx_ce, lsu0_ram_start_idx_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu0_ram_start_idx_reg (
    .clk(clk),
    .rst(lsu0_ram_start_idx_rst),
    .d(lsu0_ram_start_idx_next),
    .q(lsu0_ram_start_idx_value),
    .ce(lsu0_ram_start_idx_ce)
  );

  wire [31:0] lsu0_ram_block_factor_next, lsu0_ram_block_factor_value;
  wire lsu0_ram_block_factor_ce, lsu0_ram_block_factor_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu0_ram_block_factor_reg (
    .clk(clk),
    .rst(lsu0_ram_block_factor_rst),
    .d(lsu0_ram_block_factor_next),
    .q(lsu0_ram_block_factor_value),
    .ce(lsu0_ram_block_factor_ce)
  );

  wire [31:0] lsu0_ram_cyclic_factor_next, lsu0_ram_cyclic_factor_value;
  wire lsu0_ram_cyclic_factor_ce, lsu0_ram_cyclic_factor_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu0_ram_cyclic_factor_reg (
    .clk(clk),
    .rst(lsu0_ram_cyclic_factor_rst),
    .d(lsu0_ram_cyclic_factor_next),
    .q(lsu0_ram_cyclic_factor_value),
    .ce(lsu0_ram_cyclic_factor_ce)
  );

  wire [31:0] lsu0_ram_stride_next, lsu0_ram_stride_value;
  wire lsu0_ram_stride_ce, lsu0_ram_stride_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu0_ram_stride_reg (
    .clk(clk),
    .rst(lsu0_ram_stride_rst),
    .d(lsu0_ram_stride_next),
    .q(lsu0_ram_stride_value),
    .ce(lsu0_ram_stride_ce)
  );

  wire [31:0] lsu0_ram_seg_stride_next, lsu0_ram_seg_stride_value;
  wire lsu0_ram_seg_stride_ce, lsu0_ram_seg_stride_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu0_ram_seg_stride_reg (
    .clk(clk),
    .rst(lsu0_ram_seg_stride_rst),
    .d(lsu0_ram_seg_stride_next),
    .q(lsu0_ram_seg_stride_value),
    .ce(lsu0_ram_seg_stride_ce)
  );

  wire [31:0] lsu0_ram_addr_offset_next, lsu0_ram_addr_offset_value;
  wire lsu0_ram_addr_offset_ce, lsu0_ram_addr_offset_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu0_ram_addr_offset_reg (
    .clk(clk),
    .rst(lsu0_ram_addr_offset_rst),
    .d(lsu0_ram_addr_offset_next),
    .q(lsu0_ram_addr_offset_value),
    .ce(lsu0_ram_addr_offset_ce)
  );

  wire [31:0] lsu0_m_offset_lo_next, lsu0_m_offset_lo_value;
  wire lsu0_m_offset_lo_ce, lsu0_m_offset_lo_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu0_m_offset_lo_reg (
    .clk(clk),
    .rst(lsu0_m_offset_lo_rst),
    .d(lsu0_m_offset_lo_next),
    .q(lsu0_m_offset_lo_value),
    .ce(lsu0_m_offset_lo_ce)
  );

  wire [31:0] lsu0_m_offset_hi_next, lsu0_m_offset_hi_value;
  wire lsu0_m_offset_hi_ce, lsu0_m_offset_hi_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu0_m_offset_hi_reg (
    .clk(clk),
    .rst(lsu0_m_offset_hi_rst),
    .d(lsu0_m_offset_hi_next),
    .q(lsu0_m_offset_hi_value),
    .ce(lsu0_m_offset_hi_ce)
  );

  wire [31:0] lsu0_seg_stride_next, lsu0_seg_stride_value;
  wire lsu0_seg_stride_ce, lsu0_seg_stride_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu0_seg_stride_reg (
    .clk(clk),
    .rst(lsu0_seg_stride_rst),
    .d(lsu0_seg_stride_next),
    .q(lsu0_seg_stride_value),
    .ce(lsu0_seg_stride_ce)
  );

  wire [31:0] lsu0_seg_count_next, lsu0_seg_count_value;
  wire lsu0_seg_count_ce, lsu0_seg_count_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu0_seg_count_reg (
    .clk(clk),
    .rst(lsu0_seg_count_rst),
    .d(lsu0_seg_count_next),
    .q(lsu0_seg_count_value),
    .ce(lsu0_seg_count_ce)
  );

  wire [31:0] lsu0_len_next, lsu0_len_value;
  wire lsu0_len_ce, lsu0_len_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu0_len_reg (
    .clk(clk),
    .rst(lsu0_len_rst),
    .d(lsu0_len_next),
    .q(lsu0_len_value),
    .ce(lsu0_len_ce)
  );

  wire [31:0] lsu0_mode_next, lsu0_mode_value;
  wire lsu0_mode_ce, lsu0_mode_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu0_mode_reg (
    .clk(clk),
    .rst(lsu0_mode_rst),
    .d(lsu0_mode_next),
    .q(lsu0_mode_value),
    .ce(lsu0_mode_ce)
  );

`ifndef SOCKET_S
  wire [31:0] lsu1_csr_next, lsu1_csr_value;
  wire lsu1_csr_ce, lsu1_csr_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu1_csr_reg (
    .clk(clk),
    .rst(lsu1_csr_rst),
    .d(lsu1_csr_next),
    .q(lsu1_csr_value),
    .ce(lsu1_csr_ce)
  );

  wire [31:0] lsu1_ram_start_idx_next, lsu1_ram_start_idx_value;
  wire lsu1_ram_start_idx_ce, lsu1_ram_start_idx_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu1_ram_start_idx_reg (
    .clk(clk),
    .rst(lsu1_ram_start_idx_rst),
    .d(lsu1_ram_start_idx_next),
    .q(lsu1_ram_start_idx_value),
    .ce(lsu1_ram_start_idx_ce)
  );

  wire [31:0] lsu1_ram_block_factor_next, lsu1_ram_block_factor_value;
  wire lsu1_ram_block_factor_ce, lsu1_ram_block_factor_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu1_ram_block_factor_reg (
    .clk(clk),
    .rst(lsu1_ram_block_factor_rst),
    .d(lsu1_ram_block_factor_next),
    .q(lsu1_ram_block_factor_value),
    .ce(lsu1_ram_block_factor_ce)
  );

  wire [31:0] lsu1_ram_cyclic_factor_next, lsu1_ram_cyclic_factor_value;
  wire lsu1_ram_cyclic_factor_ce, lsu1_ram_cyclic_factor_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu1_ram_cyclic_factor_reg (
    .clk(clk),
    .rst(lsu1_ram_cyclic_factor_rst),
    .d(lsu1_ram_cyclic_factor_next),
    .q(lsu1_ram_cyclic_factor_value),
    .ce(lsu1_ram_cyclic_factor_ce)
  );

  wire [31:0] lsu1_ram_stride_next, lsu1_ram_stride_value;
  wire lsu1_ram_stride_ce, lsu1_ram_stride_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu1_ram_stride_reg (
    .clk(clk),
    .rst(lsu1_ram_stride_rst),
    .d(lsu1_ram_stride_next),
    .q(lsu1_ram_stride_value),
    .ce(lsu1_ram_stride_ce)
  );

  wire [31:0] lsu1_ram_seg_stride_next, lsu1_ram_seg_stride_value;
  wire lsu1_ram_seg_stride_ce, lsu1_ram_seg_stride_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu1_ram_seg_stride_reg (
    .clk(clk),
    .rst(lsu1_ram_seg_stride_rst),
    .d(lsu1_ram_seg_stride_next),
    .q(lsu1_ram_seg_stride_value),
    .ce(lsu1_ram_seg_stride_ce)
  );

  wire [31:0] lsu1_ram_addr_offset_next, lsu1_ram_addr_offset_value;
  wire lsu1_ram_addr_offset_ce, lsu1_ram_addr_offset_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu1_ram_addr_offset_reg (
    .clk(clk),
    .rst(lsu1_ram_addr_offset_rst),
    .d(lsu1_ram_addr_offset_next),
    .q(lsu1_ram_addr_offset_value),
    .ce(lsu1_ram_addr_offset_ce)
  );

  wire [31:0] lsu1_m_offset_lo_next, lsu1_m_offset_lo_value;
  wire lsu1_m_offset_lo_ce, lsu1_m_offset_lo_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu1_m_offset_lo_reg (
    .clk(clk),
    .rst(lsu1_m_offset_lo_rst),
    .d(lsu1_m_offset_lo_next),
    .q(lsu1_m_offset_lo_value),
    .ce(lsu1_m_offset_lo_ce)
  );

  wire [31:0] lsu1_m_offset_hi_next, lsu1_m_offset_hi_value;
  wire lsu1_m_offset_hi_ce, lsu1_m_offset_hi_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu1_m_offset_hi_reg (
    .clk(clk),
    .rst(lsu1_m_offset_hi_rst),
    .d(lsu1_m_offset_hi_next),
    .q(lsu1_m_offset_hi_value),
    .ce(lsu1_m_offset_hi_ce)
  );

  wire [31:0] lsu1_seg_stride_next, lsu1_seg_stride_value;
  wire lsu1_seg_stride_ce, lsu1_seg_stride_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu1_seg_stride_reg (
    .clk(clk),
    .rst(lsu1_seg_stride_rst),
    .d(lsu1_seg_stride_next),
    .q(lsu1_seg_stride_value),
    .ce(lsu1_seg_stride_ce)
  );

  wire [31:0] lsu1_seg_count_next, lsu1_seg_count_value;
  wire lsu1_seg_count_ce, lsu1_seg_count_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu1_seg_count_reg (
    .clk(clk),
    .rst(lsu1_seg_count_rst),
    .d(lsu1_seg_count_next),
    .q(lsu1_seg_count_value),
    .ce(lsu1_seg_count_ce)
  );

  wire [31:0] lsu1_len_next, lsu1_len_value;
  wire lsu1_len_ce, lsu1_len_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu1_len_reg (
    .clk(clk),
    .rst(lsu1_len_rst),
    .d(lsu1_len_next),
    .q(lsu1_len_value),
    .ce(lsu1_len_ce)
  );

  wire [31:0] lsu1_mode_next, lsu1_mode_value;
  wire lsu1_mode_ce, lsu1_mode_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) lsu1_mode_reg (
    .clk(clk),
    .rst(lsu1_mode_rst),
    .d(lsu1_mode_next),
    .q(lsu1_mode_value),
    .ce(lsu1_mode_ce)
  );
`endif

  wire [31:0] comm0_mode_next, comm0_mode_value;
  wire comm0_mode_ce, comm0_mode_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) comm0_mode_reg (
    .clk(clk),
    .rst(comm0_mode_rst),
    .d(comm0_mode_next),
    .q(comm0_mode_value),
    .ce(comm0_mode_ce)
  );

  wire [31:0] comm1_mode_next, comm1_mode_value;
  wire comm1_mode_ce, comm1_mode_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) comm1_mode_reg (
    .clk(clk),
    .rst(comm1_mode_rst),
    .d(comm1_mode_next),
    .q(comm1_mode_value),
    .ce(comm1_mode_ce)
  );

  wire [31:0] tq_wdata_next, tq_wdata_value;
  wire tq_wdata_ce, tq_wdata_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) tq_wdata_reg (
    .clk(clk),
    .rst(tq_wdata_rst),
    .d(tq_wdata_next),
    .q(tq_wdata_value),
    .ce(tq_wdata_ce)
  );

  wire [31:0] squeue_in_data;
  wire squeue_in_valid, squeue_in_ready;

  fifo #(
    .WIDTH(32),
    .LOGDEPTH(4)
  ) ff_squeue (
    .clk(clk),
    .rst(~resetn),

    .enq_data(squeue_in_data),
    .enq_valid(squeue_in_valid),
    .enq_ready(squeue_in_ready),

    .deq_data(squeue_out_data),
    .deq_valid(squeue_out_valid),
    .deq_ready(squeue_out_ready)
  );

  assign squeue_in_data = mmio_din;
  assign squeue_in_valid = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_SQUEUE & {`MMIO_AW{1'b1}})) & mmio_wen;

//  always @(posedge clk) begin
//    $display("[%t] [%m] ff_squeue enq [%b %b %h], deq [%b %b %h]",
//      $time, squeue_in_valid, squeue_in_ready, squeue_in_data,
//      squeue_out_valid, squeue_out_ready, squeue_out_data);
//  end

  assign mmio_dout =
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_CTRL_MAXI_READ & {`MMIO_AW{1'b1}}))  ? ctrl_maxi_read_value     :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_CTRL_MAXI_WRITE & {`MMIO_AW{1'b1}})) ? ctrl_maxi_write_value    :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_CTRL_MAXI_RDATA & {`MMIO_AW{1'b1}})) ? ctrl_maxi_rdata          :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SOCKET_INBOX & {`MMIO_AW{1'b1}}))   ? socket_inbox              :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC0 & {`MMIO_AW{1'b1}}))          ? sync_value[0]             :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC1 & {`MMIO_AW{1'b1}}))          ? sync_value[1]             :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC2 & {`MMIO_AW{1'b1}}))          ? sync_value[2]             :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC3 & {`MMIO_AW{1'b1}}))          ? sync_value[3]             :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC4 & {`MMIO_AW{1'b1}}))          ? sync_value[4]             :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC5 & {`MMIO_AW{1'b1}}))          ? sync_value[5]             :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC6 & {`MMIO_AW{1'b1}}))          ? sync_value[6]             :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC7 & {`MMIO_AW{1'b1}}))          ? sync_value[7]             :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC8 & {`MMIO_AW{1'b1}}))          ? sync_value[8]             :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC9 & {`MMIO_AW{1'b1}}))          ? sync_value[9]             :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC10 & {`MMIO_AW{1'b1}}))         ? sync_value[10]            :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC11 & {`MMIO_AW{1'b1}}))         ? sync_value[11]            :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC12 & {`MMIO_AW{1'b1}}))         ? sync_value[12]            :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC13 & {`MMIO_AW{1'b1}}))         ? sync_value[13]            :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC14 & {`MMIO_AW{1'b1}}))         ? sync_value[14]            :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SYNC15 & {`MMIO_AW{1'b1}}))         ? sync_value[15]            :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_MEM_UNIT_RDATA & {`MMIO_AW{1'b1}})) ? mem_unit_rdata_value      :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_SQUEUE_FULL & {`MMIO_AW{1'b1}}))    ? ~squeue_in_ready          :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_DMA0_WRITE_IDLE & {`MMIO_AW{1'b1}})) ? dma0_write_idle          :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_DMA1_WRITE_IDLE & {`MMIO_AW{1'b1}})) ? dma1_write_idle          :

    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU0_CSR & {`MMIO_AW{1'b1}}))               ? lsu0_csr_value               :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU0_RAM_START_IDX & {`MMIO_AW{1'b1}}))     ? lsu0_ram_start_idx_value     :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU0_RAM_BLOCK_FACTOR & {`MMIO_AW{1'b1}}))  ? lsu0_ram_block_factor_value  :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU0_RAM_CYCLIC_FACTOR & {`MMIO_AW{1'b1}})) ? lsu0_ram_cyclic_factor_value :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU0_RAM_STRIDE & {`MMIO_AW{1'b1}}))        ? lsu0_ram_stride_value        :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU0_RAM_SEG_STRIDE & {`MMIO_AW{1'b1}}))    ? lsu0_ram_seg_stride_value    :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU0_RAM_ADDR_OFFSET & {`MMIO_AW{1'b1}}))   ? lsu0_ram_addr_offset_value   :

    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU0_M_OFFSET_LO & {`MMIO_AW{1'b1}})) ? lsu0_m_offset_lo_value :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU0_M_OFFSET_HI & {`MMIO_AW{1'b1}})) ? lsu0_m_offset_hi_value :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU0_SEG_STRIDE & {`MMIO_AW{1'b1}}))  ? lsu0_seg_stride_value  :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU0_SEG_COUNT & {`MMIO_AW{1'b1}}))   ? lsu0_seg_count_value   :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU0_LEN & {`MMIO_AW{1'b1}}))         ? lsu0_len_value         :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU0_MODE & {`MMIO_AW{1'b1}}))        ? lsu0_mode_value        :

`ifndef SOCKET_S
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU1_CSR & {`MMIO_AW{1'b1}}))               ? lsu1_csr_value               :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU1_RAM_START_IDX & {`MMIO_AW{1'b1}}))     ? lsu1_ram_start_idx_value     :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU1_RAM_BLOCK_FACTOR & {`MMIO_AW{1'b1}}))  ? lsu1_ram_block_factor_value  :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU1_RAM_CYCLIC_FACTOR & {`MMIO_AW{1'b1}})) ? lsu1_ram_cyclic_factor_value :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU1_RAM_STRIDE & {`MMIO_AW{1'b1}}))        ? lsu1_ram_stride_value        :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU1_RAM_SEG_STRIDE & {`MMIO_AW{1'b1}}))    ? lsu1_ram_seg_stride_value    :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU1_RAM_ADDR_OFFSET & {`MMIO_AW{1'b1}}))   ? lsu1_ram_addr_offset_value   :

    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU1_M_OFFSET_LO & {`MMIO_AW{1'b1}})) ? lsu1_m_offset_lo_value :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU1_M_OFFSET_HI & {`MMIO_AW{1'b1}})) ? lsu1_m_offset_hi_value :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU1_SEG_STRIDE & {`MMIO_AW{1'b1}}))  ? lsu1_seg_stride_value  :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU1_SEG_COUNT & {`MMIO_AW{1'b1}}))   ? lsu1_seg_count_value   :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU1_LEN & {`MMIO_AW{1'b1}}))         ? lsu1_len_value         :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_LSU1_MODE & {`MMIO_AW{1'b1}}))        ? lsu1_mode_value        :
`endif

    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_COMM0_MODE & {`MMIO_AW{1'b1}}))       ? comm0_mode_value       :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_COMM1_MODE & {`MMIO_AW{1'b1}}))       ? comm1_mode_value       :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_TQ_WDATA & {`MMIO_AW{1'b1}}))         ? tq_wdata_value         :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_TQ_EMPTY_N & {`MMIO_AW{1'b1}}))       ? tq_empty_n             :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_TQ_FULL_N & {`MMIO_AW{1'b1}}))        ? tq_full_n              :
    (raddr_pipe0[`MMIO_AW-1:0] == (`MMIO_TASK_EMPTY & {`MMIO_AW{1'b1}}))       ? {31'b0, task_empty}    : 0;

  generate
    for (i = 0; i < NUM_SYNCS; i = i + 1) begin
      assign sync_next[i] = sync_en[i] ? 1'b1 : mmio_din[0];
      assign sync_ce[i]   = sync_en[i] | ((mmio_addr[`MMIO_AW-1:0] == (`MMIO_SYNC(i) & {`MMIO_AW{1'b1}})) & mmio_wen);
      assign sync_rst[i]  = ~resetn;
    end
  endgenerate

  assign cpu_status_next = mmio_din;
  assign cpu_status_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_CPU_STATUS & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign cpu_status_rst  = ~resetn | socket_done;

  assign socket_done = (cpu_status_value == 1);

  assign ctrl_maxi_read_next = ctrl_maxi_rdone ? {ctrl_maxi_read_value[31:2], 1'b1, ctrl_maxi_read_value[0]} : mmio_din;
  assign ctrl_maxi_read_ce   = ((mmio_addr[`MMIO_AW-1:0] == (`MMIO_CTRL_MAXI_READ & {`MMIO_AW{1'b1}})) & mmio_wen) | ctrl_maxi_rdone;
  assign ctrl_maxi_read_rst  = ~resetn | ctrl_maxi_read_value[0];

  assign ctrl_maxi_write_next = ctrl_maxi_wdone ? {ctrl_maxi_write_value[31:2], 1'b1, ctrl_maxi_write_value[0]} : mmio_din;
  assign ctrl_maxi_write_ce   = ((mmio_addr[`MMIO_AW-1:0] == (`MMIO_CTRL_MAXI_WRITE & {`MMIO_AW{1'b1}})) & mmio_wen) | ctrl_maxi_wdone;
  assign ctrl_maxi_write_rst  = ~resetn | ctrl_maxi_write_value[0];

  assign ctrl_maxi_wdata_next = mmio_din;
  assign ctrl_maxi_wdata_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_CTRL_MAXI_WDATA & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign ctrl_maxi_wdata_rst  = ~resetn | socket_done;

  assign ctrl_maxi_socket_offset_lo_next = mmio_din;
  assign ctrl_maxi_socket_offset_lo_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_CTRL_MAXI_SOCKET_OFFSET_LO & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign ctrl_maxi_socket_offset_lo_rst  = ~resetn | socket_done;

  assign ctrl_maxi_socket_offset_hi_next = mmio_din;
  assign ctrl_maxi_socket_offset_hi_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_CTRL_MAXI_SOCKET_OFFSET_HI & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign ctrl_maxi_socket_offset_hi_rst  = ~resetn | socket_done;

  assign ctrl_maxi_rstart = ctrl_maxi_read_value[0];
  assign ctrl_maxi_wstart = ctrl_maxi_write_value[0];
  assign ctrl_maxi_wdata = ctrl_maxi_wdata_value;
  assign ctrl_maxi_socket_offset = {ctrl_maxi_socket_offset_hi_value[31:0],
                                    ctrl_maxi_socket_offset_lo_value[31:0]};

  assign lsu0_csr_next = lsu0_done ? {lsu0_csr_value[31:2], 1'b1, lsu0_csr_value[0]} : mmio_din;
  assign lsu0_csr_ce   = ((mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU0_CSR & {`MMIO_AW{1'b1}})) & mmio_wen) | lsu0_done;
  assign lsu0_csr_rst  = ~resetn | lsu0_csr_value[0];

  assign lsu0_ram_start_idx_next = mmio_din;
  assign lsu0_ram_start_idx_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU0_RAM_START_IDX & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu0_ram_start_idx_rst  = ~resetn | socket_done;

  assign lsu0_ram_block_factor_next = mmio_din;
  assign lsu0_ram_block_factor_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU0_RAM_BLOCK_FACTOR & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu0_ram_block_factor_rst  = ~resetn | socket_done;

  assign lsu0_ram_cyclic_factor_next = mmio_din;
  assign lsu0_ram_cyclic_factor_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU0_RAM_CYCLIC_FACTOR & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu0_ram_cyclic_factor_rst  = ~resetn | socket_done;

  assign lsu0_ram_stride_next = mmio_din;
  assign lsu0_ram_stride_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU0_RAM_STRIDE & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu0_ram_stride_rst  = ~resetn | socket_done;

  assign lsu0_ram_seg_stride_next = mmio_din;
  assign lsu0_ram_seg_stride_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU0_RAM_SEG_STRIDE & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu0_ram_seg_stride_rst  = ~resetn | socket_done;

  assign lsu0_ram_addr_offset_next = mmio_din;
  assign lsu0_ram_addr_offset_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU0_RAM_ADDR_OFFSET & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu0_ram_addr_offset_rst  = ~resetn | socket_done;

  assign lsu0_m_offset_lo_next = mmio_din;
  assign lsu0_m_offset_lo_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU0_M_OFFSET_LO & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu0_m_offset_lo_rst  = ~resetn | socket_done;

  assign lsu0_m_offset_hi_next = mmio_din;
  assign lsu0_m_offset_hi_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU0_M_OFFSET_HI & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu0_m_offset_hi_rst  = ~resetn | socket_done;

  assign lsu0_seg_count_next = mmio_din;
  assign lsu0_seg_count_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU0_SEG_COUNT & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu0_seg_count_rst  = ~resetn | socket_done;

  assign lsu0_seg_stride_next = mmio_din;
  assign lsu0_seg_stride_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU0_SEG_STRIDE & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu0_seg_stride_rst  = ~resetn | socket_done;

  assign lsu0_len_next = mmio_din;
  assign lsu0_len_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU0_LEN & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu0_len_rst  = ~resetn | socket_done;

  assign lsu0_mode_next = mmio_din;
  assign lsu0_mode_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU0_MODE & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu0_mode_rst  = ~resetn | socket_done;

`ifndef SOCKET_S
  assign lsu1_csr_next = lsu1_done ? {lsu1_csr_value[31:2], 1'b1, lsu1_csr_value[0]} : mmio_din;
  assign lsu1_csr_ce   = ((mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU1_CSR & {`MMIO_AW{1'b1}})) & mmio_wen) | lsu1_done;
  assign lsu1_csr_rst  = ~resetn | lsu1_csr_value[0];

  assign lsu1_ram_start_idx_next = mmio_din;
  assign lsu1_ram_start_idx_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU1_RAM_START_IDX & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu1_ram_start_idx_rst  = ~resetn | socket_done;

  assign lsu1_ram_block_factor_next = mmio_din;
  assign lsu1_ram_block_factor_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU1_RAM_BLOCK_FACTOR & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu1_ram_block_factor_rst  = ~resetn | socket_done;

  assign lsu1_ram_cyclic_factor_next = mmio_din;
  assign lsu1_ram_cyclic_factor_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU1_RAM_CYCLIC_FACTOR & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu1_ram_cyclic_factor_rst  = ~resetn | socket_done;

  assign lsu1_ram_stride_next = mmio_din;
  assign lsu1_ram_stride_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU1_RAM_STRIDE & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu1_ram_stride_rst  = ~resetn | socket_done;

  assign lsu1_ram_seg_stride_next = mmio_din;
  assign lsu1_ram_seg_stride_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU1_RAM_SEG_STRIDE & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu1_ram_seg_stride_rst  = ~resetn | socket_done;

  assign lsu1_ram_addr_offset_next = mmio_din;
  assign lsu1_ram_addr_offset_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU1_RAM_ADDR_OFFSET & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu1_ram_addr_offset_rst  = ~resetn | socket_done;

  assign lsu1_m_offset_lo_next = mmio_din;
  assign lsu1_m_offset_lo_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU1_M_OFFSET_LO & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu1_m_offset_lo_rst  = ~resetn | socket_done;

  assign lsu1_m_offset_hi_next = mmio_din;
  assign lsu1_m_offset_hi_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU1_M_OFFSET_HI & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu1_m_offset_hi_rst  = ~resetn | socket_done;

  assign lsu1_seg_count_next = mmio_din;
  assign lsu1_seg_count_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU1_SEG_COUNT & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu1_seg_count_rst  = ~resetn | socket_done;

  assign lsu1_seg_stride_next = mmio_din;
  assign lsu1_seg_stride_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU1_SEG_STRIDE & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu1_seg_stride_rst  = ~resetn | socket_done;

  assign lsu1_len_next = mmio_din;
  assign lsu1_len_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU1_LEN & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu1_len_rst  = ~resetn | socket_done;

  assign lsu1_mode_next = mmio_din;
  assign lsu1_mode_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_LSU1_MODE & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign lsu1_mode_rst  = ~resetn | socket_done;
`endif

  assign comm0_mode_next = mmio_din;
  assign comm0_mode_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_COMM0_MODE & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign comm0_mode_rst  = ~resetn | socket_done;

  assign comm1_mode_next = mmio_din;
  assign comm1_mode_ce   = (mmio_addr[`MMIO_AW-1:0] == (`MMIO_COMM1_MODE & {`MMIO_AW{1'b1}})) & mmio_wen;
  assign comm1_mode_rst  = ~resetn | socket_done;

  assign tq_wdata_next = ((mmio_addr[`MMIO_AW-1:0] == (`MMIO_TQ_WDATA & {`MMIO_AW{1'b1}})) & mmio_wen & tq_full_n & ff_cl_scalar_full_n) ? mmio_din : {tq_wdata_value[31:1], 1'b0};
  assign tq_wdata_ce   = ((mmio_addr[`MMIO_AW-1:0] == (`MMIO_TQ_WDATA & {`MMIO_AW{1'b1}})) & mmio_wen & tq_full_n & ff_cl_scalar_full_n) | tq_enq_fire;
  assign tq_wdata_rst  = ~resetn | socket_done;

  assign lsu0_start             = lsu0_csr_value[0];
  assign lsu0_ram_start_idx     = lsu0_ram_start_idx_value;
  assign lsu0_ram_block_factor  = lsu0_ram_block_factor_value;
  assign lsu0_ram_cyclic_factor = lsu0_ram_cyclic_factor_value;
  assign lsu0_ram_seg_stride    = lsu0_ram_seg_stride_value;
  assign lsu0_ram_stride        = lsu0_ram_stride_value;
  assign lsu0_ram_addr_offset   = lsu0_ram_addr_offset_value;
  assign lsu0_m_offset_lo       = lsu0_m_offset_lo_value;
  assign lsu0_m_offset_hi       = lsu0_m_offset_hi_value;
  assign lsu0_seg_count         = lsu0_seg_count_value;
  assign lsu0_seg_stride        = lsu0_seg_stride_value;
  assign lsu0_len               = lsu0_len_value;
  assign lsu0_mode              = lsu0_mode_value;

`ifndef SOCKET_S
  assign lsu1_start             = lsu1_csr_value[0];
  assign lsu1_ram_start_idx     = lsu1_ram_start_idx_value;
  assign lsu1_ram_block_factor  = lsu1_ram_block_factor_value;
  assign lsu1_ram_cyclic_factor = lsu1_ram_cyclic_factor_value;
  assign lsu1_ram_seg_stride    = lsu1_ram_seg_stride_value;
  assign lsu1_ram_stride        = lsu1_ram_stride_value;
  assign lsu1_ram_addr_offset   = lsu1_ram_addr_offset_value;
  assign lsu1_m_offset_lo       = lsu1_m_offset_lo_value;
  assign lsu1_m_offset_hi       = lsu1_m_offset_hi_value;
  assign lsu1_seg_count         = lsu1_seg_count_value;
  assign lsu1_seg_stride        = lsu1_seg_stride_value;
  assign lsu1_len               = lsu1_len_value;
  assign lsu1_mode              = lsu1_mode_value;
`endif
  assign comm0_mode             = comm0_mode_value;
  assign comm1_mode             = comm1_mode_value;

  assign tq_wdata               = tq_wdata_value;


`ifdef DEBUG
  always @(posedge clk) begin
    if (mmio_wen === 1'b1) begin
      $display("[At %t] [%m] MMIO_WEN mmio_addr=%h, mmio_din=%h", $time, mmio_addr,mmio_din);
    end
  end
`endif
endmodule

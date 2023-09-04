
module ff_bridge(cl_ctrl_addr, cl_ctrl_addr_ff, cl_ctrl_ce, cl_ctrl_ce_ff, cl_ctrl_d, cl_ctrl_d_ff, cl_ctrl_q, cl_ctrl_q_ff, cl_ctrl_we, cl_ctrl_we_ff, cl_done, cl_done_ff, clk0, clk1, lsu0_dp_mode, lsu0_dp_mode_ff, lsu0_port0_addr, lsu0_port0_addr_ff, lsu0_port0_ce, lsu0_port0_ce_ff, lsu0_port0_d, lsu0_port0_d_ff, lsu0_port0_q, lsu0_port0_q_ff, lsu0_port0_we, lsu0_port0_we_ff, lsu0_port1_addr, lsu0_port1_addr_ff, lsu0_port1_ce, lsu0_port1_ce_ff, lsu0_port1_d, lsu0_port1_d_ff, lsu0_port1_q, lsu0_port1_q_ff, lsu0_port1_we, lsu0_port1_we_ff, lsu0_port2_addr, lsu0_port2_addr_ff, lsu0_port2_ce, lsu0_port2_ce_ff, lsu0_port2_d, lsu0_port2_d_ff, lsu0_port2_q, lsu0_port2_q_ff, lsu0_port2_we, lsu0_port2_we_ff, lsu0_port3_addr, lsu0_port3_addr_ff, lsu0_port3_ce, lsu0_port3_ce_ff, lsu0_port3_d, lsu0_port3_d_ff, lsu0_port3_q, lsu0_port3_q_ff, lsu0_port3_we, lsu0_port3_we_ff, lsu0_ram_en, lsu0_ram_en_ff, lsu1_dp_mode, lsu1_dp_mode_ff, lsu1_port0_addr, lsu1_port0_addr_ff, lsu1_port0_ce, lsu1_port0_ce_ff, lsu1_port0_d, lsu1_port0_d_ff, lsu1_port0_q, lsu1_port0_q_ff, lsu1_port0_we, lsu1_port0_we_ff, lsu1_port1_addr, lsu1_port1_addr_ff, lsu1_port1_ce, lsu1_port1_ce_ff, lsu1_port1_d, lsu1_port1_d_ff, lsu1_port1_q, lsu1_port1_q_ff, lsu1_port1_we, lsu1_port1_we_ff, lsu1_port2_addr, lsu1_port2_addr_ff, lsu1_port2_ce, lsu1_port2_ce_ff, lsu1_port2_d, lsu1_port2_d_ff, lsu1_port2_q, lsu1_port2_q_ff, lsu1_port2_we, lsu1_port2_we_ff, lsu1_port3_addr, lsu1_port3_addr_ff, lsu1_port3_ce, lsu1_port3_ce_ff, lsu1_port3_d, lsu1_port3_d_ff, lsu1_port3_q, lsu1_port3_q_ff, lsu1_port3_we, lsu1_port3_we_ff, lsu1_ram_en, lsu1_ram_en_ff, socket_reset, socket_reset_ff);
  input [11:0]cl_ctrl_addr;
  output [11:0]cl_ctrl_addr_ff;
  input cl_ctrl_ce;
  output cl_ctrl_ce_ff;
  input [31:0]cl_ctrl_d;
  output [31:0]cl_ctrl_d_ff;
  output [31:0]cl_ctrl_q;
  input [31:0]cl_ctrl_q_ff;
  input cl_ctrl_we;
  output cl_ctrl_we_ff;
  output cl_done;
  input cl_done_ff;
  input clk0;
  input clk1;
  input lsu0_dp_mode;
  output lsu0_dp_mode_ff;
  input [11:0]lsu0_port0_addr;
  output [11:0]lsu0_port0_addr_ff;
  input lsu0_port0_ce;
  output lsu0_port0_ce_ff;
  input [63:0]lsu0_port0_d;
  output [63:0]lsu0_port0_d_ff;
  output [63:0]lsu0_port0_q;
  input [63:0]lsu0_port0_q_ff;
  input lsu0_port0_we;
  output lsu0_port0_we_ff;
  input [11:0]lsu0_port1_addr;
  output [11:0]lsu0_port1_addr_ff;
  input lsu0_port1_ce;
  output lsu0_port1_ce_ff;
  input [63:0]lsu0_port1_d;
  output [63:0]lsu0_port1_d_ff;
  output [63:0]lsu0_port1_q;
  input [63:0]lsu0_port1_q_ff;
  input lsu0_port1_we;
  output lsu0_port1_we_ff;
  input [11:0]lsu0_port2_addr;
  output [11:0]lsu0_port2_addr_ff;
  input lsu0_port2_ce;
  output lsu0_port2_ce_ff;
  input [63:0]lsu0_port2_d;
  output [63:0]lsu0_port2_d_ff;
  output [63:0]lsu0_port2_q;
  input [63:0]lsu0_port2_q_ff;
  input lsu0_port2_we;
  output lsu0_port2_we_ff;
  input [11:0]lsu0_port3_addr;
  output [11:0]lsu0_port3_addr_ff;
  input lsu0_port3_ce;
  output lsu0_port3_ce_ff;
  input [63:0]lsu0_port3_d;
  output [63:0]lsu0_port3_d_ff;
  output [63:0]lsu0_port3_q;
  input [63:0]lsu0_port3_q_ff;
  input lsu0_port3_we;
  output lsu0_port3_we_ff;
  input [4:0]lsu0_ram_en;
  output [4:0]lsu0_ram_en_ff;
  input lsu1_dp_mode;
  output lsu1_dp_mode_ff;
  input [11:0]lsu1_port0_addr;
  output [11:0]lsu1_port0_addr_ff;
  input lsu1_port0_ce;
  output lsu1_port0_ce_ff;
  input [63:0]lsu1_port0_d;
  output [63:0]lsu1_port0_d_ff;
  output [63:0]lsu1_port0_q;
  input [63:0]lsu1_port0_q_ff;
  input lsu1_port0_we;
  output lsu1_port0_we_ff;
  input [11:0]lsu1_port1_addr;
  output [11:0]lsu1_port1_addr_ff;
  input lsu1_port1_ce;
  output lsu1_port1_ce_ff;
  input [63:0]lsu1_port1_d;
  output [63:0]lsu1_port1_d_ff;
  output [63:0]lsu1_port1_q;
  input [63:0]lsu1_port1_q_ff;
  input lsu1_port1_we;
  output lsu1_port1_we_ff;
  input [11:0]lsu1_port2_addr;
  output [11:0]lsu1_port2_addr_ff;
  input lsu1_port2_ce;
  output lsu1_port2_ce_ff;
  input [63:0]lsu1_port2_d;
  output [63:0]lsu1_port2_d_ff;
  output [63:0]lsu1_port2_q;
  input [63:0]lsu1_port2_q_ff;
  input lsu1_port2_we;
  output lsu1_port2_we_ff;
  input [11:0]lsu1_port3_addr;
  output [11:0]lsu1_port3_addr_ff;
  input lsu1_port3_ce;
  output lsu1_port3_ce_ff;
  input [63:0]lsu1_port3_d;
  output [63:0]lsu1_port3_d_ff;
  output [63:0]lsu1_port3_q;
  input [63:0]lsu1_port3_q_ff;
  input lsu1_port3_we;
  output lsu1_port3_we_ff;
  input [4:0]lsu1_ram_en;
  output [4:0]lsu1_ram_en_ff;
  input socket_reset;
  output socket_reset_ff;

  wire lsu0_dp_mode_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_dp_mode_pb (
    .clk(clk0),
    .d(lsu0_dp_mode),
    .q(lsu0_dp_mode_ff)
  );
  wire lsu1_dp_mode_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_dp_mode_pb (
    .clk(clk0),
    .d(lsu1_dp_mode),
    .q(lsu1_dp_mode_ff)
  );

  wire [11:0] lsu0_port0_addr_ff;
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu0_port0_addr_pb (
    .clk(clk0),
    .d(lsu0_port0_addr),
    .q(lsu0_port0_addr_ff)
  );
  wire [63:0] lsu0_port0_d_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port0_d_pb (
    .clk(clk0),
    .d(lsu0_port0_d),
    .q(lsu0_port0_d_ff)
  );
  wire [63:0] lsu0_port0_q_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port0_q_pb (
    .clk(clk0),
    .d(lsu0_port0_q_ff),
    .q(lsu0_port0_q)
  );
  wire lsu0_port0_ce_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port0_ce_pb (
    .clk(clk0),
    .d(lsu0_port0_ce),
    .q(lsu0_port0_ce_ff)
  );
  wire lsu0_port0_we_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port0_we_pb (
    .clk(clk0),
    .d(lsu0_port0_we),
    .q(lsu0_port0_we_ff)
  );

  wire [11:0] lsu0_port1_addr_ff;
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu0_port1_addr_pb (
    .clk(clk0),
    .d(lsu0_port1_addr),
    .q(lsu0_port1_addr_ff)
  );
  wire [63:0] lsu0_port1_d_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port1_d_pb (
    .clk(clk0),
    .d(lsu0_port1_d),
    .q(lsu0_port1_d_ff)
  );
  wire [63:0] lsu0_port1_q_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port1_q_pb (
    .clk(clk0),
    .d(lsu0_port1_q_ff),
    .q(lsu0_port1_q)
  );
  wire lsu0_port1_ce_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port1_ce_pb (
    .clk(clk0),
    .d(lsu0_port1_ce),
    .q(lsu0_port1_ce_ff)
  );
  wire lsu0_port1_we_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port1_we_pb (
    .clk(clk0),
    .d(lsu0_port1_we),
    .q(lsu0_port1_we_ff)
  );

  wire [11:0] lsu0_port2_addr_ff;
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu0_port2_addr_pb (
    .clk(clk0),
    .d(lsu0_port2_addr),
    .q(lsu0_port2_addr_ff)
  );
  wire [63:0] lsu0_port2_d_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port2_d_pb (
    .clk(clk0),
    .d(lsu0_port2_d),
    .q(lsu0_port2_d_ff)
  );
  wire [63:0] lsu0_port2_q_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port2_q_pb (
    .clk(clk0),
    .d(lsu0_port2_q_ff),
    .q(lsu0_port2_q)
  );
  wire lsu0_port2_ce_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port2_ce_pb (
    .clk(clk0),
    .d(lsu0_port2_ce),
    .q(lsu0_port2_ce_ff)
  );
  wire lsu0_port2_we_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port2_we_pb (
    .clk(clk0),
    .d(lsu0_port2_we),
    .q(lsu0_port2_we_ff)
  );

  wire [11:0] lsu0_port3_addr_ff;
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu0_port3_addr_pb (
    .clk(clk0),
    .d(lsu0_port3_addr),
    .q(lsu0_port3_addr_ff)
  );
  wire [63:0] lsu0_port3_d_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port3_d_pb (
    .clk(clk0),
    .d(lsu0_port3_d),
    .q(lsu0_port3_d_ff)
  );
  wire [63:0] lsu0_port3_q_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port3_q_pb (
    .clk(clk0),
    .d(lsu0_port3_q_ff),
    .q(lsu0_port3_q)
  );
  wire lsu0_port3_ce_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port3_ce_pb (
    .clk(clk0),
    .d(lsu0_port3_ce),
    .q(lsu0_port3_ce_ff)
  );
  wire lsu0_port3_we_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port3_we_pb (
    .clk(clk0),
    .d(lsu0_port3_we),
    .q(lsu0_port3_we_ff)
  );

  wire [11:0] lsu1_port0_addr_ff;
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu1_port0_addr_pb (
    .clk(clk0),
    .d(lsu1_port0_addr),
    .q(lsu1_port0_addr_ff)
  );
  wire [63:0] lsu1_port0_d_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port0_d_pb (
    .clk(clk0),
    .d(lsu1_port0_d),
    .q(lsu1_port0_d_ff)
  );
  wire [63:0] lsu1_port0_q_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port0_q_pb (
    .clk(clk0),
    .d(lsu1_port0_q_ff),
    .q(lsu1_port0_q)
  );
  wire lsu1_port0_ce_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port0_ce_pb (
    .clk(clk0),
    .d(lsu1_port0_ce),
    .q(lsu1_port0_ce_ff)
  );
  wire lsu1_port0_we_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port0_we_pb (
    .clk(clk0),
    .d(lsu1_port0_we),
    .q(lsu1_port0_we_ff)
  );

  wire [11:0] lsu1_port1_addr_ff;
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu1_port1_addr_pb (
    .clk(clk0),
    .d(lsu1_port1_addr),
    .q(lsu1_port1_addr_ff)
  );
  wire [63:0] lsu1_port1_d_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port1_d_pb (
    .clk(clk0),
    .d(lsu1_port1_d),
    .q(lsu1_port1_d_ff)
  );
  wire [63:0] lsu1_port1_q_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port1_q_pb (
    .clk(clk0),
    .d(lsu1_port1_q_ff),
    .q(lsu1_port1_q)
  );
  wire lsu1_port1_ce_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port1_ce_pb (
    .clk(clk0),
    .d(lsu1_port1_ce),
    .q(lsu1_port1_ce_ff)
  );
  wire lsu1_port1_we_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port1_we_pb (
    .clk(clk0),
    .d(lsu1_port1_we),
    .q(lsu1_port1_we_ff)
  );

  wire [11:0] lsu1_port2_addr_ff;
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu1_port2_addr_pb (
    .clk(clk0),
    .d(lsu1_port2_addr),
    .q(lsu1_port2_addr_ff)
  );
  wire [63:0] lsu1_port2_d_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port2_d_pb (
    .clk(clk0),
    .d(lsu1_port2_d),
    .q(lsu1_port2_d_ff)
  );
  wire [63:0] lsu1_port2_q_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port2_q_pb (
    .clk(clk0),
    .d(lsu1_port2_q_ff),
    .q(lsu1_port2_q)
  );
  wire lsu1_port2_ce_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port2_ce_pb (
    .clk(clk0),
    .d(lsu1_port2_ce),
    .q(lsu1_port2_ce_ff)
  );
  wire lsu1_port2_we_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port2_we_pb (
    .clk(clk0),
    .d(lsu1_port2_we),
    .q(lsu1_port2_we_ff)
  );

  wire [11:0] lsu1_port3_addr_ff;
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu1_port3_addr_pb (
    .clk(clk0),
    .d(lsu1_port3_addr),
    .q(lsu1_port3_addr_ff)
  );
  wire [63:0] lsu1_port3_d_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port3_d_pb (
    .clk(clk0),
    .d(lsu1_port3_d),
    .q(lsu1_port3_d_ff)
  );
  wire [63:0] lsu1_port3_q_ff;
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port3_q_pb (
    .clk(clk0),
    .d(lsu1_port3_q_ff),
    .q(lsu1_port3_q)
  );
  wire lsu1_port3_ce_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port3_ce_pb (
    .clk(clk0),
    .d(lsu1_port3_ce),
    .q(lsu1_port3_ce_ff)
  );
  wire lsu1_port3_we_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port3_we_pb (
    .clk(clk0),
    .d(lsu1_port3_we),
    .q(lsu1_port3_we_ff)
  );

  wire [4:0] lsu0_ram_en_ff;
  pipe_block #(.WIDTH(5), .NUM_STAGES(1)) lsu0_ram_en_pb (
    .clk(clk0),
    .d(lsu0_ram_en),
    .q(lsu0_ram_en_ff)
  );

  wire [4:0] lsu1_ram_en_ff;
  pipe_block #(.WIDTH(5), .NUM_STAGES(1)) lsu1_ram_en_pb (
    .clk(clk0),
    .d(lsu1_ram_en),
    .q(lsu1_ram_en_ff)
  );

  wire cl_done_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) cl_done_pb (
    .clk(clk0),
    .d(cl_done_ff),
    .q(cl_done)
  );
  wire [11:0] cl_ctrl_addr_ff;
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) cl_ctrl_addr_pb (
    .clk(clk0),
    .d(cl_ctrl_addr),
    .q(cl_ctrl_addr_ff)
  );
  wire [31:0] cl_ctrl_d_ff;
  pipe_block #(.WIDTH(32), .NUM_STAGES(1)) cl_ctrl_d_pb (
    .clk(clk0),
    .d(cl_ctrl_d),
    .q(cl_ctrl_d_ff)
  );
  wire [31:0] cl_ctrl_q_ff;
  pipe_block #(.WIDTH(32), .NUM_STAGES(1)) cl_ctrl_q_pb (
    .clk(clk0),
    .d(cl_ctrl_q_ff),
    .q(cl_ctrl_q)
  );
  wire cl_ctrl_ce_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) cl_ctrl_ce_pb (
    .clk(clk0),
    .d(cl_ctrl_ce),
    .q(cl_ctrl_ce_ff)
  );
  wire cl_ctrl_we_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) cl_ctrl_we_pb (
    .clk(clk0),
    .d(cl_ctrl_we),
    .q(cl_ctrl_we_ff)
  );

  wire socket_reset_ff;
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) socket_reset_pb (
    .clk(clk0),
    .d(socket_reset),
    .q(socket_reset_ff)
  );

endmodule

import sys
import math
import os
import xml.etree.ElementTree as ET
import benchmark_config

def main(argv):
  #64b data requires 2x RAMB36

  # Num. ports == Group size
  num_ports = 4
  num_lsus = 2
  lsu_rg_map = {}
  for i in range(num_lsus):
    lsu_rg_map[i] = []

  ram_map = {}
  xml_files = []

  if argv[0] == "matmul":
    f = benchmark_config.setup_matmul(lsu_rg_map, num_ports, num_lsus, ram_map, xml_files)
  elif argv[0] == "jacobi_2d":
    f = benchmark_config.setup_jacobi_2d(lsu_rg_map, num_ports, num_lsus, ram_map, xml_files)
  elif argv[0] == "cholesky":
    f = benchmark_config.setup_cholesky(lsu_rg_map, num_ports, num_lsus, ram_map, xml_files)
  elif argv[0] == "spmv":
    f = benchmark_config.setup_spmv(lsu_rg_map, num_ports, num_lsus, ram_map, xml_files)
  elif argv[0] == "matmul_32b":
    f = benchmark_config.setup_matmul_32b(lsu_rg_map, num_ports, num_lsus, ram_map, xml_files)
  elif argv[0] == "matmul_32b_fp":
    f = benchmark_config.setup_matmul_32b_fp(lsu_rg_map, num_ports, num_lsus, ram_map, xml_files)
  elif argv[0] == "conv2d":
    f = benchmark_config.setup_conv2d(lsu_rg_map, num_ports, num_lsus, ram_map, xml_files)
  elif argv[0] == "conv3d":
    f = benchmark_config.setup_conv3d(lsu_rg_map, num_ports, num_lsus, ram_map, xml_files)
  elif argv[0] == "linear":
    f = benchmark_config.setup_linear(lsu_rg_map, num_ports, num_lsus, ram_map, xml_files)

  num_ram_groups_bram,\
  num_ram_groups_lutram,\
  num_ram_groups_uram,\
  lut_ram_depth, dp_mode = f

  num_ram_groups = num_ram_groups_bram + num_ram_groups_lutram + num_ram_groups_uram

  stream_map = {}

  task_name = None
  bram_ports = {}
  ss_ports = {}
  axis_ports = {}
  scalar_ports = {}
  scalars = []

  pointer_ports = {}

  for xml_file in xml_files:
    tree = ET.parse(xml_file)
    root = tree.getroot()
    for t in root.iter("TopModelName"):
      #task_name = kernel_name + "_" + t.text
      task_name = t.text

    for t in root.iter("RtlPorts"):
      if t.find("IOProtocol").text == "ap_memory":
        objName = t.find("Object").text
        if objName not in bram_ports.keys():
          bram_ports[objName] = [];
        bram_ports[objName].append((t.find("name").text, t.find("Dir").text, int(t.find("Bits").text)))

      if t.find("IOProtocol").text == "ap_fifo":
        objName = t.find("Object").text
        if (objName, task_name) not in ss_ports.keys():
          ss_ports[(objName, task_name)] = [];
        ss_ports[(objName, task_name)].append((t.find("name").text, t.find("Dir").text, int(t.find("Bits").text)))

      if t.find("IOProtocol").text == "axis":
        objName = t.find("Object").text
        if (objName, task_name) not in axis_ports.keys():
          axis_ports[(objName, task_name)] = [];
        axis_ports[(objName, task_name)].append((t.find("name").text, t.find("Dir").text, int(t.find("Bits").text)))

      if t.find("IOProtocol").text == "ap_none" and t.find("Type").text == "scalar":
        objName = t.find("Object").text
        if (objName, task_name) not in scalar_ports.keys():
          scalar_ports[(objName, task_name)] = [];
        scalar_ports[(objName, task_name)].append((t.find("name").text, t.find("Dir").text, int(t.find("Bits").text)))
        scalars.append("{0}_{1}".format(task_name, (t.find("name").text)))

      if t.find("Type").text == "pointer" and t.find("IOProtocol").text == "ap_ovld":
        objName = t.find("Object").text
        if (objName, task_name) not in pointer_ports.keys():
          pointer_ports[(objName, task_name)] = []
          #scalars.append("{0}_{1}".format(task_name, (t.find("Object").text)))
        pointer_ports[(objName, task_name)].append((t.find("name").text, t.find("Dir").text, int(t.find("Bits").text)))


  #print(scalar_ports)
  #print(pointer_ports)
  #print(scalars)
  #exit(0)

  code = "`include \"socket_config.vh\"\n"
  code += "module custom_logic (\n"
  code += """
  input  [255:0] cl_ss0_in_data,
  input          cl_ss0_in_valid,
  output         cl_ss0_in_ready,
  output [255:0] cl_ss0_out_data,
  output         cl_ss0_out_valid,
  input          cl_ss0_out_ready,

  input  [255:0] cl_ss1_in_data,
  input          cl_ss1_in_valid,
  output         cl_ss1_in_ready,
  output [255:0] cl_ss1_out_data,
  output         cl_ss1_out_valid,
  input          cl_ss1_out_ready,
"""

  for i in range(21): # default
  #for i in range(num_ram_groups):
    for j in range(num_ports):
      code += """
  output [11:0] cl_rg_{0}_{1}_addr0,
  output [63:0] cl_rg_{0}_{1}_d0,
  input  [63:0] cl_rg_{0}_{1}_q0,
  output        cl_rg_{0}_{1}_ce0,
  output        cl_rg_{0}_{1}_we0,
  output [11:0] cl_rg_{0}_{1}_addr1,
  output [63:0] cl_rg_{0}_{1}_d1,
  input  [63:0] cl_rg_{0}_{1}_q1,
  output        cl_rg_{0}_{1}_ce1,
  output        cl_rg_{0}_{1}_we1,
""".format(i, j)

  #code += "  input [31:0] cl_ram_sel,\n"

  code += """
`ifndef NO_AXIS
  output [256-1:0]   m_axis_tdata,
  output             m_axis_tvalid,
  input              m_axis_tready,
  output             m_axis_tlast,
  output [256/8-1:0] m_axis_tkeep,
  output [256/8-1:0] m_axis_tstrb,
  output [1-1:0]     m_axis_tdest,

  input [256-1:0]   s_axis_tdata,
  input             s_axis_tvalid,
  output            s_axis_tready,
  input             s_axis_tlast,
  input [256/8-1:0] s_axis_tkeep,
  input [256/8-1:0] s_axis_tstrb,
  input [1-1:0]     s_axis_tdest,
`endif
"""

  code += """
  output        cl_done,
  input  [11:0] cl_ctrl_addr,
  input  [31:0] cl_ctrl_d,
  output [31:0] cl_ctrl_q,
  input         cl_ctrl_ce,
  input         cl_ctrl_we,
"""
#  code += """
#  // AXI-Lite slave interface (for control)
#  input [31:0]  s_ctrl_awaddr,
#  input         s_ctrl_awvalid,
#  output        s_ctrl_awready,
#  input [31:0]  s_ctrl_wdata,
#  input         s_ctrl_wvalid,
#  output        s_ctrl_wready,
#  input [3:0]   s_ctrl_wstrb,
#  output [1:0]  s_ctrl_bresp,
#  output        s_ctrl_bvalid,
#  input         s_ctrl_bready,
#  input [31:0]  s_ctrl_araddr,
#  input         s_ctrl_arvalid,
#  output        s_ctrl_arready,
#  output [31:0] s_ctrl_rdata,
#  output        s_ctrl_rvalid,
#  input         s_ctrl_rready,
#  output [1:0]  s_ctrl_rresp,
#"""

  code += """
  input clk,
  input rst
);
"""

  for k, v in bram_ports.items():
    for port_name, pdir, bitwidth in v:
      code += "  wire [{0}-1:0] {1}_{2};\n".format(bitwidth, task_name, port_name)

  for k, v in ss_ports.items():
    for port_name, pdir, bitwidth in v:
      code += "  wire [{0}-1:0] {1}_{2};\n".format(bitwidth, task_name, port_name)

  for k, v in axis_ports.items():
    for port_name, pdir, bitwidth in v:
      code += "  wire [{0}-1:0] {1}_{2};\n".format(bitwidth, task_name, port_name)

  for (k, task_name), v in scalar_ports.items():
    for port_name, pdir, bitwidth in v:
      code += "  wire [{0}-1:0] {1}_{2};\n".format(bitwidth, task_name, port_name)

  for (k, task_name), v in pointer_ports.items():
    for port_name, pdir, bitwidth in v:
      code += "  wire [{0}-1:0] {1}_{2};\n".format(bitwidth, task_name, port_name)

  code += "  wire [31:0] cl_ram_sel;\n"

  code += "  wire cl_ap_start;\n"
  code += "  wire cl_ap_done;\n"
  code += "  wire cl_ap_ready;\n"

  code += "  {0} custom_logic_inst (\n".format(task_name)

  for k, v in bram_ports.items():
    for port_name, pdir, bitwidth in v:
      code += "    .{0}({1}_{0}),\n".format(port_name, task_name)
      #code += "    .{1}_{0}({1}_{0}),\n".format(port_name, task_name)

  for (k, task_name), v in ss_ports.items():
    for port_name, pdir, bitwidth in v:
      code += "    .{0}({1}_{0}),\n".format(port_name, task_name)

  for (k, task_name), v in axis_ports.items():
    for port_name, pdir, bitwidth in v:
      code += "    .{0}({1}_{0}),\n".format(port_name, task_name)

  for (k, task_name), v in scalar_ports.items():
    for port_name, pdir, bitwidth in v:
      code += "    .{0}({1}_{0}),\n".format(port_name, task_name)

  for (k, task_name), v in pointer_ports.items():
    for port_name, pdir, bitwidth in v:
      code += "    .{0}({1}_{0}),\n".format(port_name, task_name)

#  code += "    .cl_ram_sel(cl_ram_sel),\n"

#  code += """
#    .s_axi_control_AWVALID(s_ctrl_awvalid),
#    .s_axi_control_AWREADY(s_ctrl_awready),
#    .s_axi_control_AWADDR(s_ctrl_awaddr),
#    .s_axi_control_WVALID(s_ctrl_wvalid),
#    .s_axi_control_WREADY(s_ctrl_wready),
#    .s_axi_control_WDATA(s_ctrl_wdata),
#    .s_axi_control_WSTRB(s_ctrl_wstrb),
#    .s_axi_control_ARVALID(s_ctrl_arvalid),
#    .s_axi_control_ARREADY(s_ctrl_arready),
#    .s_axi_control_ARADDR(s_ctrl_araddr),
#    .s_axi_control_RVALID(s_ctrl_rvalid),
#    .s_axi_control_RREADY(s_ctrl_rready),
#    .s_axi_control_RDATA(s_ctrl_rdata),
#    .s_axi_control_RRESP(s_ctrl_rresp),
#    .s_axi_control_BVALID(s_ctrl_bvalid),
#    .s_axi_control_BREADY(s_ctrl_bready),
#    .s_axi_control_BRESP(s_ctrl_bresp),
#"""
  code += """
    .ap_start(cl_ap_start),
    .ap_ready(cl_ap_ready),
    .ap_done(cl_ap_done),
"""

#  code += "    .ap_rst_n(~rst),\n"
  code += "    .ap_rst(rst),\n"
  code += "    .ap_clk(clk)\n"
  code += "  );\n"

  if "{0}_pp".format(task_name) in scalars:
    code += "  assign cl_ram_sel = {0}_pp;\n".format(task_name)


  for (k, task_name), v in axis_ports.items():
    for port_name, pdir, bitwidth in v:
      if pdir == "out":
        if "TDATA" in port_name:
          code += "  assign m_axis_tdata = {1}_{0};\n".format(port_name, task_name)
        if "TVALID" in port_name:
          code += "  assign m_axis_tvalid = {1}_{0};\n".format(port_name, task_name)
        if "TKEEP" in port_name:
          code += "  assign m_axis_tkeep = {1}_{0};\n".format(port_name, task_name)
        if "TSTRB" in port_name:
          code += "  assign m_axis_tstrb = {1}_{0};\n".format(port_name, task_name)
        if "TDEST" in port_name:
          code += "  assign m_axis_tdest = {1}_{0};\n".format(port_name, task_name)
        if "TLAST" in port_name:
          code += "  assign m_axis_tlast = {1}_{0};\n".format(port_name, task_name)
        if "READY" in port_name:
          code += "  assign s_axis_tready = {1}_{0};\n".format(port_name, task_name)
      elif pdir == "in":
        if "TDATA" in port_name:
          code += "  assign {1}_{0} = s_axis_tdata;\n".format(port_name, task_name)
        if "TVALID" in port_name:
          code += "  assign {1}_{0} = s_axis_tvalid;\n".format(port_name, task_name)
        if "TKEEP" in port_name:
          code += "  assign {1}_{0} = s_axis_tkeep;\n".format(port_name, task_name)
        if "TSTRB" in port_name:
          code += "  assign {1}_{0} = s_axis_tstrb;\n".format(port_name, task_name)
        if "TDEST" in port_name:
          code += "  assign {1}_{0} = s_axis_tdest;\n".format(port_name, task_name)
        if "TLAST" in port_name:
          code += "  assign {1}_{0} = s_axis_tlast;\n".format(port_name, task_name)

        if "READY" in port_name:
          code += "  assign {1}_{0} = m_axis_tready;\n".format(port_name, task_name)

  # Stream port setup
  for (ss_port_name, task_name), v in ss_ports.items():
    #for port_name, pdir, bitwidth in v:
    (cl_port_num, pdir) = stream_map[ss_port_name]
    if pdir == 0:
      code += "  assign {0}_{1}_dout = cl_ss{2}_in_data;\n".format(task_name, ss_port_name, cl_port_num)
      code += "  assign {0}_{1}_empty_n = cl_ss{2}_in_valid;\n".format(task_name, ss_port_name, cl_port_num)
      code += "  assign cl_ss{2}_in_ready = {0}_{1}_read;\n".format(task_name, ss_port_name, cl_port_num)
    else:
      code += "  assign cl_ss{2}_out_data = {0}_{1}_din;\n".format(task_name, ss_port_name, cl_port_num)
      code += "  assign cl_ss{2}_out_valid = {0}_{1}_full_n;\n".format(task_name, ss_port_name, cl_port_num)
      code += "  assign {0}_{1}_write = cl_ss{2}_in_ready;\n".format(task_name, ss_port_name, cl_port_num)

  # RAM port1 setup
  for i in range(num_ram_groups):
    for j in range(num_ports):
      code += "  assign cl_rg_{0}_{1}_addr1 = ".format(i, j, t)
      # integrate custom_logic ports
      if (i, j, 1) in ram_map.keys():
        for (cl_port_name, cl_port_num, cl_ram_sel) in ram_map[(i, j, 1)]:
          for (port, _, _) in bram_ports[cl_port_name]:
            if "{0}_address{1}".format(cl_port_name, cl_port_num) in port:
              if cl_ram_sel is None:
                code += "{0}_{1}_ce{2} ? {0}_{1}_address{2} : ".format(task_name, cl_port_name, cl_port_num)
              else:
                code += "cl_ram_sel[{3}] ? {0}_{1}_address{2} : ".format(task_name, cl_port_name, cl_port_num, cl_ram_sel)
      code += "0;\n"

  for i in range(num_ram_groups):
    for j in range(num_ports):
      code += "  assign cl_rg_{0}_{1}_d1 = ".format(i, j, t)

      # integrate custom_logic ports
      if (i, j, 1) in ram_map.keys():
        for (cl_port_name, cl_port_num, cl_ram_sel) in ram_map[(i, j, 1)]:
          for (port, _, _) in bram_ports[cl_port_name]:
            if "{0}_d{1}".format(cl_port_name, cl_port_num) in port:
              if cl_ram_sel is None:
                code += "{0}_{1}_ce{2} ? {0}_{1}_d{2} : ".format(task_name, cl_port_name, cl_port_num)
              else:
                code += "cl_ram_sel[{3}] ? {0}_{1}_d{2} : ".format(task_name, cl_port_name, cl_port_num, cl_ram_sel)
      code += "0;\n"

  for i in range(num_ram_groups):
    for j in range(num_ports):
      code += "  assign cl_rg_{0}_{1}_ce1 = ".format(i, j)

      # integrate custom_logic ports
      if (i, j, 1) in ram_map.keys():
        for (cl_port_name, cl_port_num, cl_ram_sel) in ram_map[(i, j, 1)]:
          for (port, _, _) in bram_ports[cl_port_name]:
            if "{0}_ce{1}".format(cl_port_name, cl_port_num) in port:
              if cl_ram_sel is None:
                code += "{0}_{1}_ce{2} | ".format(task_name, cl_port_name, cl_port_num)
              else:
                code += "(cl_ram_sel[{3}] & {0}_{1}_ce{2}) | ".format(task_name, cl_port_name, cl_port_num, cl_ram_sel)
      code += "0;\n"

  for i in range(num_ram_groups):
    for j in range(num_ports):
      code += "  assign cl_rg_{0}_{1}_we1 = ".format(i, j)

      # integrate custom_logic ports
      if (i, j, 1) in ram_map.keys():
        for (cl_port_name, cl_port_num, cl_ram_sel) in ram_map[(i, j, 1)]:
          for (port, _, _) in bram_ports[cl_port_name]:
            if "{0}_we{1}".format(cl_port_name, cl_port_num) in port:
              if cl_ram_sel is None:
                code += "{0}_{1}_we{2} | ".format(task_name, cl_port_name, cl_port_num)
              else:
                code += "(cl_ram_sel[{3}] & {0}_{1}_we{2}) | ".format(task_name, cl_port_name, cl_port_num, cl_ram_sel)
      code += "0;\n"

  # RAM port0 setup
  for i in range(num_ram_groups):
    for j in range(num_ports):
      code += "  assign cl_rg_{0}_{1}_addr0 = ".format(i, j, t)
      # integrate custom_logic ports
      if (i, j, 0) in ram_map.keys():
        for (cl_port_name, cl_port_num, cl_ram_sel) in ram_map[(i, j, 0)]:
          for (port, _, _) in bram_ports[cl_port_name]:
            if "{0}_address{1}".format(cl_port_name, cl_port_num) in port:
              if cl_ram_sel is None:
                code += "{0}_{1}_ce{2} ? {0}_{1}_address{2} : ".format(task_name, cl_port_name, cl_port_num)
              else:
                code += "cl_ram_sel[{3}] ? {0}_{1}_address{2} : ".format(task_name, cl_port_name, cl_port_num, cl_ram_sel)
      code += "0;\n"

  for i in range(num_ram_groups):
    for j in range(num_ports):
      code += "  assign cl_rg_{0}_{1}_ce0 = ".format(i, j)
      # integrate custom_logic ports
      if (i, j, 0) in ram_map.keys():
        for (cl_port_name, cl_port_num, cl_ram_sel) in ram_map[(i, j, 0)]:
          for (port, _, _) in bram_ports[cl_port_name]:
            if "{0}_ce{1}".format(cl_port_name, cl_port_num) in port:
              if cl_ram_sel is None:
                code += "{0}_{1}_ce{2} | ".format(task_name, cl_port_name, cl_port_num)
              else:
                code += "(cl_ram_sel[{3}] & {0}_{1}_ce{2}) | ".format(task_name, cl_port_name, cl_port_num, cl_ram_sel)
      code += "0;\n"


  for i in range(num_ram_groups):
    for j in range(num_ports):
      if (i, j, 0) in ram_map.keys():
        code += "  assign cl_rg_{0}_{1}_we0 = ".format(i, j)
        for (cl_port_name, cl_port_num, cl_ram_sel) in ram_map[(i, j, 0)]:
          for (port, _, _) in bram_ports[cl_port_name]:
            if "{0}_we{1}".format(cl_port_name, cl_port_num) in port:
              if cl_ram_sel is None:
                code += "{0}_{1}_we{2} | ".format(task_name, cl_port_name, cl_port_num)
              else:
                code += "(cl_ram_sel[{3}] & {0}_{1}_we{2}) | ".format(task_name, cl_port_name, cl_port_num, cl_ram_sel)
        code += "0;\n"

  for i in range(num_ram_groups):
    for j in range(num_ports):
      if (i, j, 0) in ram_map.keys():
        code += "  assign cl_rg_{0}_{1}_d0 = ".format(i, j)
        for (cl_port_name, cl_port_num, cl_ram_sel) in ram_map[(i, j, 0)]:
          for (port, _, _) in bram_ports[cl_port_name]:
            if "{0}_d{1}".format(cl_port_name, cl_port_num) in port:
              if cl_ram_sel is None:
                code += "{0}_{1}_ce{2} ? {0}_{1}_d{2} : ".format(task_name, cl_port_name, cl_port_num)
              else:
                code += "cl_ram_sel[{3}] ? {0}_{1}_d{2} : ".format(task_name, cl_port_name, cl_port_num, cl_ram_sel)
        code += "0;\n"

  for (i, j, port_num) in ram_map.keys():
    for (cl_port_name, cl_port_num, cl_ram_sel) in ram_map[(i, j, port_num)]:
      if cl_ram_sel is not None:
        continue

      for (port, _, _) in bram_ports[cl_port_name]:
        if "{0}_q{1}".format(cl_port_name, cl_port_num) in port:
          code += "  assign {0}_{1}_q{2} = cl_rg_{3}_{4}_q{5};\n".format(
            task_name, cl_port_name, cl_port_num, i, j, port_num)

  ram_map_rev = {}
  for (i, j, port_num) in ram_map.keys():
    for (cl_port_name, cl_port_num, cl_ram_sel) in ram_map[(i, j, port_num)]:
      if cl_ram_sel is None:
        continue
      if (cl_port_name, cl_port_num) not in ram_map_rev.keys():
        ram_map_rev[(cl_port_name, cl_port_num)] = []
      ram_map_rev[(cl_port_name, cl_port_num)].append((i, j, port_num, cl_ram_sel))

  for (cl_port_name, cl_port_num) in ram_map_rev.keys():
    for (port, _, _) in bram_ports[cl_port_name]:
      if "{0}_q{1}".format(cl_port_name, cl_port_num) in port:
        code += "  assign {0}_{1}_q{2} = ".format(
          task_name, cl_port_name, cl_port_num)
        for (i, j, port_num, cl_ram_sel) in ram_map_rev[(cl_port_name, cl_port_num)]:
          code += "cl_ram_sel[{3}] ? cl_rg_{0}_{1}_q{2} : ".format(
            i, j, port_num, cl_ram_sel)
        code += "0;\n"

  # MMIO for custom logic control
  offset_val = 0
  code += "  localparam OFFSET_CL_CSR = 32'h{0};\n".format(f'{offset_val:x}')
  offset_val += 4

  for scalar in scalars:
    code += "  localparam OFFSET_{0} = 32'h{1};\n".format(scalar.upper(), f'{offset_val:x}')
    offset_val += 4

  for (pointer_name, task_name) in pointer_ports.keys():
    name = "{0}_{1}".format(task_name, pointer_name)
    code += "  localparam OFFSET_{0} = 32'h{1};\n".format(name.upper(), f'{offset_val:x}')
    offset_val += 4


  code += "  wire [31:0] cl_csr_next, cl_csr_value;\n"
  code += "  wire cl_csr_ce, cl_csr_rst;\n"
  code += "  REGISTER_R_CE #(.N(32), .INIT(0)) cl_csr_reg (\n"
  code += "    .clk(clk),\n"
  code += "    .rst(cl_csr_rst),\n"
  code += "    .ce(cl_csr_ce),\n"
  code += "    .d(cl_csr_next),\n"
  code += "    .q(cl_csr_value)\n"
  code += "  );\n"

  for scalar in scalars:
    code += "  wire [31:0] {0}_next, {0}_value;\n".format(scalar)
    code += "  wire {0}_ce;\n".format(scalar)
    code += "  REGISTER_R_CE #(.N(32), .INIT(0)) {0}_reg (\n".format(scalar)
    code += "    .clk(clk),\n"
    code += "    .rst(rst),\n"
    code += "    .ce({0}_ce),\n".format(scalar)
    code += "    .d({0}_next),\n".format(scalar)
    code += "    .q({0}_value)\n".format(scalar)
    code += "  );\n"

  for (pointer_name, task_name) in pointer_ports.keys():
    name = "{0}_{1}".format(task_name, pointer_name)
    code += "  wire [31:0] {0}_next, {0}_value;\n".format(name)
    code += "  wire {0}_ce;\n".format(name)
    code += "  REGISTER_R_CE #(.N(32), .INIT(0)) {0}_reg (\n".format(name)
    code += "    .clk(clk),\n"
    code += "    .rst(rst),\n"
    code += "    .ce({0}_ce),\n".format(name)
    code += "    .d({0}_next),\n".format(name)
    code += "    .q({0}_value)\n".format(name)
    code += "  );\n"

  code += """
  wire [11:0] cl_ctrl_addr_pipe0;
  REGISTER_CE #(.N(12)) cl_ctrl_addr_pipe0_reg (
    .clk(clk),
    .ce(cl_ctrl_ce & ~cl_ctrl_we),
    .d(cl_ctrl_addr),
    .q(cl_ctrl_addr_pipe0)
  );

  wire cl_ap_done_pipe0;
  REGISTER #(.N(1)) cl_ap_done_reg (
    .clk(clk),
    .d(cl_ap_done),
    .q(cl_ap_done_pipe0)
  );

  wire cl_ap_ready_pipe0;
  REGISTER #(.N(1)) cl_ap_ready_reg (
    .clk(clk),
    .d(cl_ap_ready),
    .q(cl_ap_ready_pipe0)
  );

  assign cl_done = cl_csr_value[1];
"""
  code += "  assign cl_ctrl_q = (cl_ctrl_addr_pipe0[`MMIO_AW-1:0] == (OFFSET_CL_CSR & {`MMIO_AW{1'b1}})) ? cl_csr_value :\n"
  for (pointer_name, task_name) in pointer_ports.keys():
    name = "{0}_{1}".format(task_name, pointer_name)
    code += "    (cl_ctrl_addr_pipe0[`MMIO_AW-1:0] == OFFSET_{1}) ? {0}_value :\n".format(name, name.upper())
  code += "    0;\n"

  code += "  wire cl_csr_read = (cl_ctrl_addr[`MMIO_AW-1:0] == (OFFSET_CL_CSR & {`MMIO_AW{1'b1}})) & (cl_ctrl_ce & ~cl_ctrl_we);\n"
  code += "  assign cl_csr_next = cl_ap_done ? {cl_csr_value[31:2], 1'b1, 1'b0} : cl_ap_ready_pipe0 ? {cl_csr_value[31:1], 1'b0} : cl_ctrl_d;\n"
  code += "  assign cl_csr_ce   = (cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_CSR)) | cl_ap_done | cl_ap_ready_pipe0;\n"
  code += "  assign cl_csr_rst  = rst;\n"
  code += "  assign cl_ap_start = cl_csr_value[0] & (~cl_ap_ready_pipe0);\n"

  for scalar in scalars:
    code += "  assign {0}_next = cl_ctrl_d;\n".format(scalar)
    code += "  assign {0}_ce   = cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_{1});\n".format(scalar, scalar.upper())
    code += "  assign {0} = {0}_value;\n".format(scalar)

  for (pointer_name, task_name) in pointer_ports.keys():
    name = "{0}_{1}".format(task_name, pointer_name)
    for (pname, pdir, pwidth) in pointer_ports[(pointer_name, task_name)]:
      if pdir == "out" and pwidth > 1:
        code += "  assign {2}_next = {1}_{0}_ap_vld ? {1}_{0} : cl_ctrl_d;\n".format(pname, task_name, name)
        code += "  assign {2}_ce   = {1}_{0}_ap_vld | (cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_{3}));\n".format(pname, task_name, name, name.upper())

    for (pname, pdir, _) in pointer_ports[(pointer_name, task_name)]:
      if pdir == "in":
        code += "  assign {1}_{0} = {2}_value;\n".format(pname, task_name, name)

  code += "endmodule"

  print(code)

if __name__ == '__main__':
  main(sys.argv[1:])


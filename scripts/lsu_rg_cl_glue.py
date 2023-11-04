import sys
import math
import os
import xml.etree.ElementTree as ET

import benchmark_config

def main(argv):
  #64b data requires 2x RAMB36

  #num_rams      = int(argv[0])
  #ram_depth     = int(argv[1])

  #num_lsus = int(argv[0])
  num_lsus = 2
  # Num. ports == Group size
  num_ports = 4;

  # Mapping between lsu and ram_group (4 RAMs each)
  lsu_rg_map = {}
  for i in range(num_lsus):
    lsu_rg_map[i] = []

  if argv[0] == "matmul":
    f = benchmark_config.matmul_rg_config(lsu_rg_map, num_lsus)
  elif argv[0] == "jacobi_2d":
    f = benchmark_config.jacobi_2d_rg_config(lsu_rg_map, num_lsus)
  elif argv[0] == "cholesky":
    f = benchmark_config.cholesky_rg_config(lsu_rg_map, num_lsus)
  elif argv[0] == "spmv":
    f = benchmark_config.spmv_rg_config(lsu_rg_map, num_lsus)
  elif argv[0] == "matmul_32b":
    f = benchmark_config.matmul_32b_rg_config(lsu_rg_map, num_lsus)
  elif argv[0] == "matmul_32b_fp":
    f = benchmark_config.matmul_32b_fp_rg_config(lsu_rg_map, num_lsus)
  elif argv[0] == "conv2d":
    f = benchmark_config.conv2d_rg_config(lsu_rg_map, num_lsus)
  elif argv[0] == "conv3d":
    f = benchmark_config.conv3d_rg_config(lsu_rg_map, num_lsus)
  elif argv[0] == "linear":
    f = benchmark_config.linear_rg_config(lsu_rg_map, num_lsus)

  num_ram_groups_bram,\
  num_ram_groups_lutram,\
  num_ram_groups_uram,\
  lut_ram_depth, dp_mode = f

  num_ram_groups = num_ram_groups_bram + num_ram_groups_lutram + num_ram_groups_uram
  num_rams  = num_ram_groups * num_ports

  rg_list = []
  for i in lsu_rg_map[0]:
    if i not in rg_list:
      rg_list.append(i)

  for i in lsu_rg_map[1]:
    if i not in rg_list:
      rg_list.append(i)

  num_lsus = len(lsu_rg_map.keys())

  code = ""
  code += "module lsu_rg_cl_glue #(\n"
  code += "  parameter NUM_RAMS = {0}\n".format(num_rams)
  code += ") (\n"
  for t in range(num_lsus):
    for i in range(num_ports):
      code += """
  input  [12-1:0] lsu{1}_port{0}_addr,
  input  [64-1:0] lsu{1}_port{0}_d,
  output [64-1:0] lsu{1}_port{0}_q,
  input           lsu{1}_port{0}_ce,
  input           lsu{1}_port{0}_we,
""".format(i, t)

    code += "  input lsu{0}_dp_mode,\n".format(t)
    code += "  input [4:0] lsu{1}_ram_en,\n".format(num_rams, t)

  for i in range(21): # default
#  for i in range(num_ram_groups):
    for j in range(num_ports):
      code += """
  input [11:0] cl_rg_{0}_{1}_addr0,
  input [63:0] cl_rg_{0}_{1}_d0,
  output [63:0] cl_rg_{0}_{1}_q0,
  input cl_rg_{0}_{1}_ce0,
  input cl_rg_{0}_{1}_we0,
  input [11:0] cl_rg_{0}_{1}_addr1,
  input [63:0] cl_rg_{0}_{1}_d1,
  output [63:0] cl_rg_{0}_{1}_q1,
  input cl_rg_{0}_{1}_ce1,
  input cl_rg_{0}_{1}_we1,
""".format(i, j)

  code += """
  input clk,
  input rst
"""

  code += ");\n"

  for i in range(num_ram_groups):
    if i not in rg_list:
      continue
    for j in range(num_ports):
      if i < num_ram_groups_bram:
        code += """
  wire [9:0] rg_{0}_{1}_addr0;
  wire [63:0] rg_{0}_{1}_d0;
  wire [63:0] rg_{0}_{1}_q0;
  wire rg_{0}_{1}_ce0;
  wire rg_{0}_{1}_we0;
  wire [9:0] rg_{0}_{1}_addr1;
  wire [63:0] rg_{0}_{1}_d1;
  wire [63:0] rg_{0}_{1}_q1;
  wire rg_{0}_{1}_ce1;
  wire rg_{0}_{1}_we1;
""".format(i, j)
      elif i < num_ram_groups_bram + num_ram_groups_lutram:
        code += """
  wire [6:0] rg_{0}_{1}_addr0;
  wire [63:0] rg_{0}_{1}_d0;
  wire [63:0] rg_{0}_{1}_q0;
  wire rg_{0}_{1}_ce0;
  wire rg_{0}_{1}_we0;
  wire [6:0] rg_{0}_{1}_addr1;
  wire [63:0] rg_{0}_{1}_d1;
  wire [63:0] rg_{0}_{1}_q1;
  wire rg_{0}_{1}_ce1;
  wire rg_{0}_{1}_we1;
""".format(i, j)
      else:
        code += """
  wire [11:0] rg_{0}_{1}_addr0;
  wire [63:0] rg_{0}_{1}_d0;
  wire [63:0] rg_{0}_{1}_q0;
  wire rg_{0}_{1}_ce0;
  wire rg_{0}_{1}_we0;
  wire [11:0] rg_{0}_{1}_addr1;
  wire [63:0] rg_{0}_{1}_d1;
  wire [63:0] rg_{0}_{1}_q1;
  wire rg_{0}_{1}_ce1;
  wire rg_{0}_{1}_we1;
""".format(i, j)

    if i < num_ram_groups_bram:
      code += "  ram_group #(.AWIDTH(10), .DWIDTH(64)) rg_{0} (".format(i)
    elif i < num_ram_groups_bram + num_ram_groups_lutram:
      code += "  ram_group_lutram #(.AWIDTH(7), .DWIDTH(64), .DEPTH({1})) rg_{0} (".format(i, lut_ram_depth)
    else:
      code += "  ram_group_uram #(.AWIDTH(12), .DWIDTH(64)) rg_{0} (".format(i)

    for j in range(num_ports):
      code += """
    .ram_{1}_addr0(rg_{0}_{1}_addr0),
    .ram_{1}_d0(rg_{0}_{1}_d0),
    .ram_{1}_q0(rg_{0}_{1}_q0),
    .ram_{1}_ce0(rg_{0}_{1}_ce0),
    .ram_{1}_we0(rg_{0}_{1}_we0),
    .ram_{1}_addr1(rg_{0}_{1}_addr1),
    .ram_{1}_d1(rg_{0}_{1}_d1),
    .ram_{1}_q1(rg_{0}_{1}_q1),
    .ram_{1}_ce1(rg_{0}_{1}_ce1),
    .ram_{1}_we1(rg_{0}_{1}_we1),
""".format(i, j)

    code += """
    .clk(clk),
    .rst(rst)
  );
"""
  # RAM port1 setup
  for i in range(num_ram_groups):
    if i not in rg_list:
      continue
    for j in range(num_ports):
      code += "  assign rg_{0}_{1}_addr1 = cl_rg_{0}_{1}_ce1 ? cl_rg_{0}_{1}_addr1 : ".format(i, j, t)

      for t in range(num_lsus):
        if i not in lsu_rg_map[t]:
          continue
        code += "1'b1 ? lsu{1}_port{0}_addr : ".format(j, t, i)
      code += "0;\n"

  for i in range(num_ram_groups):
    if i not in rg_list:
      continue
    for j in range(num_ports):
      code += "  assign rg_{0}_{1}_d1 = cl_rg_{0}_{1}_ce1 ? cl_rg_{0}_{1}_d1 : ".format(i, j, t)

      for t in range(num_lsus):
        if i not in lsu_rg_map[t]:
          continue
        code += "1'b1 ? lsu{1}_port{0}_d : ".format(j, t, i)
      code += "0;\n"

  for i in range(num_ram_groups):
    if i not in rg_list:
      continue
    for j in range(num_ports):
      code += "  assign rg_{0}_{1}_ce1 = cl_rg_{0}_{1}_ce1 | ".format(i, j)

      for t in range(num_lsus):
        if i not in lsu_rg_map[t]:
          continue
        code += "((lsu{1}_ram_en[4:0] == {2}) & lsu{1}_port{0}_ce) | ".format(j, t, i)
      code += "0;\n"

  for i in range(num_ram_groups):
    if i not in rg_list:
      continue
    for j in range(num_ports):
      code += "  assign rg_{0}_{1}_we1 = (cl_rg_{0}_{1}_we1 & cl_rg_{0}_{1}_ce1) | ".format(i, j)

      for t in range(num_lsus):
        if i not in lsu_rg_map[t]:
          continue
        code += "((lsu{1}_ram_en[4:0] == {2}) & lsu{1}_port{0}_we) | ".format(j, t, i)
      code += "0;\n"

  # RAM port0 setup
  for i in range(num_ram_groups):
    if i not in rg_list:
      continue
    for j in range(num_ports):
      # URAM is read on port0
      if i >= num_ram_groups_bram + num_ram_groups_lutram:
        code += "  assign rg_{0}_{1}_addr0 = cl_rg_{0}_{1}_ce0 ? cl_rg_{0}_{1}_addr0 : ".format(i, j, t)

        for t in range(num_lsus):
          if i not in lsu_rg_map[t]:
            continue
          code += "1'b1 ? lsu{1}_port{0}_addr : ".format(j, t, i)
        code += "0;\n"
      else:
        code += "  assign rg_{0}_{1}_addr0 = cl_rg_{0}_{1}_ce0 ? cl_rg_{0}_{1}_addr0 : ".format(i, j, t)

        for t in range(num_lsus):
          if i not in lsu_rg_map[t]:
            continue
          code += "1'b1 ? lsu{1}_port{0}_addr : ".format((j + 2) % 4, t, i)
        code += "0;\n"


  for i in range(num_ram_groups):
    if i not in rg_list:
      continue
    for j in range(num_ports):
      # URAM is read on port0
      if i >= num_ram_groups_bram + num_ram_groups_lutram:
        code += "  assign rg_{0}_{1}_ce0 = cl_rg_{0}_{1}_ce0 | ".format(i, j, t)
        for t in range(num_lsus):
          if i not in lsu_rg_map[t]:
            continue
          code += "((lsu{1}_ram_en[4:0] == {2}) & lsu{1}_port{0}_ce) | ".format(j, t, i)
        code += "0;\n"
      else:
        code += "  assign rg_{0}_{1}_ce0 = cl_rg_{0}_{1}_ce0 | ".format(i, j, t)

        if dp_mode is True:
          for t in range(num_lsus):
            if i not in lsu_rg_map[t]:
              continue
            code += "((lsu{1}_ram_en[4:0] == {2}) & lsu{1}_port{0}_ce & lsu{1}_dp_mode) | ".format(j, t, i)
        code += "0;\n"


  for i in range(num_ram_groups):
    if i not in rg_list:
      continue
    for j in range(num_ports):
      code += "  assign rg_{0}_{1}_we0 = (cl_rg_{0}_{1}_we0 & cl_rg_{0}_{1}_ce0) | ".format(i, j)

      if dp_mode is True:
        for t in range(num_lsus):
          if i not in lsu_rg_map[t]:
            continue
          code += "((lsu{1}_ram_en[4:0] == {2}) & lsu{1}_port{0}_we & lsu{1}_dp_mode) | ".format(j, t, i)
      code += "0;\n"

  for i in range(num_ram_groups):
    if i not in rg_list:
      continue
    for j in range(num_ports):
      code += "  assign rg_{0}_{1}_d0 = cl_rg_{0}_{1}_ce0 ? cl_rg_{0}_{1}_d0 : ".format(i, j, t)

      if dp_mode is True:
        for t in range(num_lsus):
          if i not in lsu_rg_map[t]:
            continue
          code += "1'b1 ? lsu{1}_port{0}_d : ".format((j + 2) % 4, t, i)
      code += "0;\n"

  for t in range(num_lsus):
    code += "  wire [4:0] lsu{0}_ram_en_pipe;\n".format(t)
    code += "  pipe_block #(.NUM_STAGES(3), .WIDTH(5)) lsu{0}_ram_en_pipe_block (\n".format(t)
    code += "    .clk(clk),\n"
    code += "    .d(lsu{0}_ram_en),\n".format(t)
    code += "    .q(lsu{0}_ram_en_pipe));\n".format(t)

    for j in range(num_ports):
      code += "  wire lsu{0}_port{1}_ce_pipe;\n".format(t, j)
      code += "  pipe_block #(.NUM_STAGES(3), .WIDTH(1)) lsu{0}_port{1}_ce_pipe_block (\n".format(t, j)
      code += "    .clk(clk),\n"
      code += "    .d(lsu{0}_port{1}_ce),\n".format(t, j)
      code += "    .q(lsu{0}_port{1}_ce_pipe));\n".format(t, j)

  for t in range(num_lsus):
    code += "  assign lsu{0}_port0_q =\n".format(t)
    for i in range(num_ram_groups):
      if i not in lsu_rg_map[t]:
        continue
      if i < num_ram_groups_bram + num_ram_groups_lutram:
        if dp_mode is True:
          code += "    (lsu{2}_ram_en_pipe[4:0] == {0} & lsu{2}_port2_ce_pipe & lsu{2}_dp_mode) ? rg_{1}_2_q0 : (lsu{2}_ram_en_pipe[4:0] == {0}) ? rg_{1}_0_q1 :\n".format(i, i, t)
        else:
          code += "    (lsu{2}_ram_en_pipe[4:0] == {0}) ? rg_{1}_0_q1 :\n".format(i, i, t)
      else:
        code += "    (lsu{2}_ram_en_pipe[4:0] == {0}) ? rg_{1}_0_q0 :\n".format(i, i, t)
    code += "    0;\n"
    code += "  assign lsu{0}_port1_q =\n".format(t)
    for i in range(num_ram_groups):
      if i not in lsu_rg_map[t]:
        continue
      if i < num_ram_groups_bram + num_ram_groups_lutram:
        if dp_mode is True:
          code += "    (lsu{2}_ram_en_pipe[4:0] == {0} & lsu{2}_port3_ce_pipe & lsu{2}_dp_mode) ? rg_{1}_3_q0 : (lsu{2}_ram_en_pipe[4:0] == {0}) ? rg_{1}_1_q1 :\n".format(i, i, t)
        else:
          code += "    (lsu{2}_ram_en_pipe[4:0] == {0}) ? rg_{1}_1_q1 :\n".format(i, i, t)
      else:
        code += "    (lsu{2}_ram_en_pipe[4:0] == {0}) ? rg_{1}_1_q0 :\n".format(i, i, t)
    code += "    0;\n"

    code += "  assign lsu{0}_port2_q =\n".format(t)
    for i in range(num_ram_groups):
      if i not in lsu_rg_map[t]:
        continue
      if i < num_ram_groups_bram + num_ram_groups_lutram:
        if dp_mode is True:
          code += "    (lsu{2}_ram_en_pipe[4:0] == {0} & lsu{2}_port0_ce_pipe & lsu{2}_dp_mode) ? rg_{1}_0_q0 : (lsu{2}_ram_en_pipe[4:0] == {0}) ? rg_{1}_2_q1 :\n".format(i, i, t)
        else:
          code += "    (lsu{2}_ram_en_pipe[4:0] == {0}) ? rg_{1}_2_q1 :\n".format(i, i, t)
      else:
        code += "    (lsu{2}_ram_en_pipe[4:0] == {0}) ? rg_{1}_2_q0 :\n".format(i, i, t)
    code += "    0;\n"

    code += "  assign lsu{0}_port3_q =\n".format(t)
    for i in range(num_ram_groups):
      if i not in lsu_rg_map[t]:
        continue
      if i < num_ram_groups_bram + num_ram_groups_lutram:
        if dp_mode is True:
          code += "    (lsu{2}_ram_en_pipe[4:0] == {0} & lsu{2}_port1_ce_pipe & lsu{2}_dp_mode) ? rg_{1}_1_q0 : (lsu{2}_ram_en_pipe[4:0] == {0}) ? rg_{1}_3_q1 :\n".format(i, i, t)
        else:
          code += "    (lsu{2}_ram_en_pipe[4:0] == {0}) ? rg_{1}_3_q1 :\n".format(i, i, t)
      else:
        code += "    (lsu{2}_ram_en_pipe[4:0] == {0}) ? rg_{1}_3_q0 :\n".format(i, i, t)
    code += "    0;\n"

  for i in range(num_ram_groups):
    if i not in rg_list:
      continue
    for j in range(num_ports):
      code += "  assign cl_rg_{0}_{1}_q0 = rg_{0}_{1}_q0;\n".format(i, j)
      code += "  assign cl_rg_{0}_{1}_q1 = rg_{0}_{1}_q1;\n".format(i, j)

  code += "endmodule\n"

  print(code)

if __name__ == '__main__':
  main(sys.argv[1:])


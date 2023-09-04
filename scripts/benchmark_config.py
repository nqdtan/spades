import math

def matmul_rg_config(lsu_rg_map, num_lsus):
  num_ram_groups_bram = 8
  num_ram_groups_lutram = 4

  num_ram_groups_uram = 1

  lsu_rg_map[0].extend([0, 1, 2, 3, 4, 5, 12])
  lsu_rg_map[1].extend([6, 7, 8, 9, 10, 11])

  lut_ram_depth = 128
  dp_mode = False
  return num_ram_groups_bram, num_ram_groups_lutram, num_ram_groups_uram,\
         lut_ram_depth, dp_mode

def matmul_ram_map_config(ram_map):
  for i in range(0, 3*4):
    group = int(i / 4)
    port  = i % 4
    ram_map[(group, port, 0)] = [("local_a{0}".format(i), 0, 0)] # ram_sel == 0
    ram_map[(group, port, 1)] = [("local_a{0}".format(i), 1, 0)] # ram_sel == 0
  for i in range(3*4, 6*4):
    group = int(i / 4)
    port  = i % 4
    ram_map[(group, port, 0)] = [("local_a{0}".format(i-3*4), 0, 1)] # ram_sel == 1
    ram_map[(group, port, 1)] = [("local_a{0}".format(i-3*4), 1, 1)] # ram_sel == 1

  for i in range(6*4, 9*4):
    group = int(i / 4)
    port  = i % 4
    ram_map[(group, port, 0)] = [("local_b{0}".format(i-6*4), 0, 0)] # ram_sel == 0
    ram_map[(group, port, 1)] = [("local_b{0}".format(i-6*4), 1, 0)] # ram_sel == 0
  for i in range(9*4, 12*4):
    group = int(i / 4)
    port  = i % 4
    ram_map[(group, port, 0)] = [("local_b{0}".format(i-9*4), 0, 1)] # ram_sel == 1
    ram_map[(group, port, 1)] = [("local_b{0}".format(i-9*4), 1, 1)] # ram_sel == 1

  ram_map[(12, 0, 0)] = [("local_c0", 1, None)] # rg_12_0 port0
  ram_map[(12, 0, 1)] = [("local_c0", 0, None)] # rg_12_0 port1
  ram_map[(12, 1, 0)] = [("local_c1", 1, None)] # rg_12_1 port0
  ram_map[(12, 1, 1)] = [("local_c1", 0, None)] # rg_12_1 port1
  ram_map[(12, 2, 0)] = [("local_c2", 1, None)] # rg_12_2 port0
  ram_map[(12, 2, 1)] = [("local_c2", 0, None)] # rg_12_2 port1
  ram_map[(12, 3, 0)] = [("local_c3", 1, None)] # rg_12_3 port0
  ram_map[(12, 3, 1)] = [("local_c3", 0, None)] # rg_12_3 port1

def setup_matmul(lsu_rg_map, num_ports, num_lsus, ram_map, xml_files):
  num_ram_groups_bram,\
  num_ram_groups_lutram,\
  num_ram_groups_uram,\
  lut_ram_depth, dp_mode = matmul_rg_config(lsu_rg_map, num_lsus)

  num_ram_groups = num_ram_groups_bram + num_ram_groups_lutram + num_ram_groups_uram
  num_rams  = num_ram_groups * num_ports

  # Manual RAM mapping
  matmul_ram_map_config(ram_map)

  xml_files.append("../benchmarks/hls_kernel/matmul/proj/solution_cl_matmul/syn/report/cl_matmul_csynth.xml")

  return num_ram_groups_bram, num_ram_groups_lutram, num_ram_groups_uram,\
         lut_ram_depth, dp_mode

def cholesky_rg_config(lsu_rg_map, num_lsus):
  num_ram_groups_bram = 8
  num_ram_groups_lutram = 0
  num_ram_groups_uram = 2

  lsu_rg_map[0].append(8)
  lsu_rg_map[0].append(9)

  for i in range(0, 4):
    lsu_rg_map[0].append(i)

  for i in range(4, 8):
    lsu_rg_map[1].append(i)

  lut_ram_depth = 128
  dp_mode = False
  return num_ram_groups_bram, num_ram_groups_lutram, num_ram_groups_uram,\
         lut_ram_depth, dp_mode

def cholesky_ram_map_config(ram_map):
  ram_map[(8, 0, 0)] = [("local_c", 0, None)]
  ram_map[(8, 0, 1)] = [("local_c", 1, None)]

  ram_map[(9, 0, 0)] = [("local_d0", 0, None)]
  ram_map[(9, 0, 1)] = [("local_d0", 1, None)]
  ram_map[(9, 1, 0)] = [("local_d1", 0, None)]
  ram_map[(9, 1, 1)] = [("local_d1", 1, None)]
  ram_map[(9, 2, 0)] = [("local_d2", 0, None)]
  ram_map[(9, 2, 1)] = [("local_d2", 1, None)]
  ram_map[(9, 3, 0)] = [("local_d3", 0, None)]
  ram_map[(9, 3, 1)] = [("local_d3", 1, None)]

  for i in range(0, 0+8):
    group = int(i / 4)
    port  = i % 4
    ram_map[(group, port, 0)] = [("local_a{0}".format(i-0), 0, 0)]
    ram_map[(group, port, 1)] = [("local_a{0}".format(i-0), 1, 0)]

  for i in range(8, 8+8):
    group = int(i / 4)
    port  = i % 4
    ram_map[(group, port, 0)] = [("local_a{0}".format(i-8), 0, 1)]
    ram_map[(group, port, 1)] = [("local_a{0}".format(i-8), 1, 1)]

  for i in range(8, 8+8):
    group = int(i / 4)
    port  = i % 4
    ram_map[(group, port, 0)].append(("local_a{0}".format(i), 0, None))
    ram_map[(group, port, 1)].append(("local_a{0}".format(i), 1, None))

  for i in range(16, 16+8):
    group = int(i / 4)
    port  = i % 4
    ram_map[(group, port, 0)] = [("local_b{0}".format(i-16), 0, 0)]
    ram_map[(group, port, 1)] = [("local_b{0}".format(i-16), 1, 0)]

  for i in range(24, 24+8):
    group = int(i / 4)
    port  = i % 4
    ram_map[(group, port, 0)] = [("local_b{0}".format(i-24), 0, 1)]
    ram_map[(group, port, 1)] = [("local_b{0}".format(i-24), 1, 1)]

def setup_cholesky(lsu_rg_map, num_ports, num_lsus, ram_map, xml_files):
  num_ram_groups_bram,\
  num_ram_groups_lutram,\
  num_ram_groups_uram,\
  lut_ram_depth, dp_mode = cholesky_rg_config(lsu_rg_map, num_lsus)

  num_ram_groups = num_ram_groups_bram + num_ram_groups_lutram + num_ram_groups_uram
  num_rams  = num_ram_groups * num_ports

  # Manual RAM mapping
  cholesky_ram_map_config(ram_map)

  xml_files.append("../benchmarks/hls_kernel/cholesky/proj/solution_cl_cholesky/syn/report/cl_cholesky_csynth.xml")

  return num_ram_groups_bram, num_ram_groups_lutram, num_ram_groups_uram,\
         lut_ram_depth, dp_mode

def jacobi_2d_rg_config(lsu_rg_map, num_lsus):
  num_ram_groups_bram = 6
  num_ram_groups_lutram = 0
  num_ram_groups_uram = 0

  for i in range(0, 3):
    lsu_rg_map[0].append(i)
  for i in range(3, 6):
    lsu_rg_map[1].append(i)

  lut_ram_depth = 128
  dp_mode = True
  return num_ram_groups_bram, num_ram_groups_lutram, num_ram_groups_uram,\
         lut_ram_depth, dp_mode

def jacobi_2d_ram_map_config(ram_map):
  ram_map[(0, 0, 0)] = [("local_a0", 0, 0)]
  ram_map[(0, 0, 1)] = [("local_a0", 1, 0)]
  ram_map[(0, 1, 0)] = [("local_a1", 0, 0)]
  ram_map[(0, 1, 1)] = [("local_a1", 1, 0)]
  ram_map[(0, 2, 0)] = [("local_b0", 0, 0)]
  ram_map[(0, 2, 1)] = [("local_b0", 1, 0)]
  ram_map[(0, 3, 0)] = [("local_b1", 0, 0)]
  ram_map[(0, 3, 1)] = [("local_b1", 1, 0)]

  ram_map[(1, 0, 0)] = [("local_a0", 0, 1)]
  ram_map[(1, 0, 1)] = [("local_a0", 1, 1)]
  ram_map[(1, 1, 0)] = [("local_a1", 0, 1)]
  ram_map[(1, 1, 1)] = [("local_a1", 1, 1)]
  ram_map[(1, 2, 0)] = [("local_b0", 0, 1)]
  ram_map[(1, 2, 1)] = [("local_b0", 1, 1)]
  ram_map[(1, 3, 0)] = [("local_b1", 0, 1)]
  ram_map[(1, 3, 1)] = [("local_b1", 1, 1)]

  ram_map[(2, 0, 0)] = [("local_c0", 0, 0)]
  ram_map[(2, 0, 1)] = [("local_c0", 1, 0)]
  ram_map[(2, 1, 0)] = [("local_c1", 0, 0)]
  ram_map[(2, 1, 1)] = [("local_c1", 1, 0)]

  ram_map[(2, 2, 0)] = [("local_c0", 0, 1)]
  ram_map[(2, 2, 1)] = [("local_c0", 1, 1)]
  ram_map[(2, 3, 0)] = [("local_c1", 0, 1)]
  ram_map[(2, 3, 1)] = [("local_c1", 1, 1)]

  ram_map[(3, 0, 0)] = [("local_a2", 0, 0)]
  ram_map[(3, 0, 1)] = [("local_a2", 1, 0)]
  ram_map[(3, 1, 0)] = [("local_a3", 0, 0)]
  ram_map[(3, 1, 1)] = [("local_a3", 1, 0)]
  ram_map[(3, 2, 0)] = [("local_b2", 0, 0)]
  ram_map[(3, 2, 1)] = [("local_b2", 1, 0)]
  ram_map[(3, 3, 0)] = [("local_b3", 0, 0)]
  ram_map[(3, 3, 1)] = [("local_b3", 1, 0)]

  ram_map[(4, 0, 0)] = [("local_a2", 0, 1)]
  ram_map[(4, 0, 1)] = [("local_a2", 1, 1)]
  ram_map[(4, 1, 0)] = [("local_a3", 0, 1)]
  ram_map[(4, 1, 1)] = [("local_a3", 1, 1)]
  ram_map[(4, 2, 0)] = [("local_b2", 0, 1)]
  ram_map[(4, 2, 1)] = [("local_b2", 1, 1)]
  ram_map[(4, 3, 0)] = [("local_b3", 0, 1)]
  ram_map[(4, 3, 1)] = [("local_b3", 1, 1)]

  ram_map[(5, 0, 0)] = [("local_c2", 0, 0)]
  ram_map[(5, 0, 1)] = [("local_c2", 1, 0)]
  ram_map[(5, 1, 0)] = [("local_c3", 0, 0)]
  ram_map[(5, 1, 1)] = [("local_c3", 1, 0)]

  ram_map[(5, 2, 0)] = [("local_c2", 0, 1)]
  ram_map[(5, 2, 1)] = [("local_c2", 1, 1)]
  ram_map[(5, 3, 0)] = [("local_c3", 0, 1)]
  ram_map[(5, 3, 1)] = [("local_c3", 1, 1)]

def setup_jacobi_2d(lsu_rg_map, num_ports, num_lsus, ram_map, xml_files):
  num_ram_groups_bram,\
  num_ram_groups_lutram,\
  num_ram_groups_uram,\
  lut_ram_depth, dp_mode = jacobi_2d_rg_config(lsu_rg_map, num_lsus)

  num_ram_groups = num_ram_groups_bram + num_ram_groups_lutram + num_ram_groups_uram
  num_rams  = num_ram_groups * num_ports

  # Manual RAM mapping
  jacobi_2d_ram_map_config(ram_map)

  xml_files.append("../benchmarks/hls_kernel/jacobi_2d/proj/solution_cl_jacobi_2d/syn/report/cl_jacobi_2d_csynth.xml")

  return num_ram_groups_bram, num_ram_groups_lutram, num_ram_groups_uram,\
         lut_ram_depth, dp_mode

def spmv_rg_config(lsu_rg_map, num_lsus):
  num_ram_groups_bram = 6
  num_ram_groups_lutram = 0

  num_ram_groups_uram = 4

  lsu_rg_map[0].extend([0, 1, 2, 5, 6, 8])
  lsu_rg_map[1].extend([3, 4, 7, 9])

  lut_ram_depth = 128
  dp_mode = False
  return num_ram_groups_bram, num_ram_groups_lutram, num_ram_groups_uram,\
         lut_ram_depth, dp_mode

def spmv_ram_map_config(ram_map):
  ram_map[(0, 0, 0)] = [("local_y0", 0, None)]
  ram_map[(0, 0, 1)] = [("local_y0", 1, None)]
  ram_map[(0, 1, 0)] = [("local_y1", 0, None)]
  ram_map[(0, 1, 1)] = [("local_y1", 1, None)]
  ram_map[(0, 2, 0)] = [("local_ptr0", 0, None)]
  ram_map[(0, 2, 1)] = [("local_ptr1", 0, None)]

  ram_map[(1, 0, 0)] = [("local_x00", 0, 0)]
  ram_map[(1, 0, 1)] = [("local_x00", 1, 0)]
  ram_map[(1, 1, 0)] = [("local_x10", 0, 0)]
  ram_map[(1, 1, 1)] = [("local_x10", 1, 0)]
  ram_map[(1, 2, 0)] = [("local_x20", 0, 0)]
  ram_map[(1, 2, 1)] = [("local_x20", 1, 0)]
  ram_map[(1, 3, 0)] = [("local_x30", 0, 0)]
  ram_map[(1, 3, 1)] = [("local_x30", 1, 0)]

  ram_map[(2, 0, 0)] = [("local_x00", 0, 1)]
  ram_map[(2, 0, 1)] = [("local_x00", 1, 1)]
  ram_map[(2, 1, 0)] = [("local_x10", 0, 1)]
  ram_map[(2, 1, 1)] = [("local_x10", 1, 1)]
  ram_map[(2, 2, 0)] = [("local_x20", 0, 1)]
  ram_map[(2, 2, 1)] = [("local_x20", 1, 1)]
  ram_map[(2, 3, 0)] = [("local_x30", 0, 1)]
  ram_map[(2, 3, 1)] = [("local_x30", 1, 1)]

  ram_map[(3, 0, 0)] = [("local_x01", 0, 0)]
  ram_map[(3, 0, 1)] = [("local_x01", 1, 0)]
  ram_map[(3, 1, 0)] = [("local_x11", 0, 0)]
  ram_map[(3, 1, 1)] = [("local_x11", 1, 0)]
  ram_map[(3, 2, 0)] = [("local_x21", 0, 0)]
  ram_map[(3, 2, 1)] = [("local_x21", 1, 0)]
  ram_map[(3, 3, 0)] = [("local_x31", 0, 0)]
  ram_map[(3, 3, 1)] = [("local_x31", 1, 0)]

  ram_map[(4, 0, 0)] = [("local_x01", 0, 1)]
  ram_map[(4, 0, 1)] = [("local_x01", 1, 1)]
  ram_map[(4, 1, 0)] = [("local_x11", 0, 1)]
  ram_map[(4, 1, 1)] = [("local_x11", 1, 1)]
  ram_map[(4, 2, 0)] = [("local_x21", 0, 1)]
  ram_map[(4, 2, 1)] = [("local_x21", 1, 1)]
  ram_map[(4, 3, 0)] = [("local_x31", 0, 1)]
  ram_map[(4, 3, 1)] = [("local_x31", 1, 1)]

  ram_map[(5, 0, 0)] = [("last_ind0", 0, None)]
  ram_map[(5, 0, 1)] = [("last_ind0", 1, None)]
  ram_map[(5, 1, 0)] = [("last_ind1", 0, None)]
  ram_map[(5, 1, 1)] = [("last_ind1", 1, None)]

  ram_map[(6, 0, 0)] = [("local_val00", 0, None)]
  ram_map[(6, 0, 1)] = [("local_val00", 1, None)]
  ram_map[(6, 1, 0)] = [("local_val10", 0, None)]
  ram_map[(6, 1, 1)] = [("local_val10", 1, None)]
  ram_map[(6, 2, 0)] = [("local_val20", 0, None)]
  ram_map[(6, 2, 1)] = [("local_val20", 1, None)]
  ram_map[(6, 3, 0)] = [("local_val30", 0, None)]
  ram_map[(6, 3, 1)] = [("local_val30", 1, None)]

  ram_map[(7, 0, 0)] = [("local_ind00", 0, None)]
  ram_map[(7, 0, 1)] = [("local_ind00", 1, None)]
  ram_map[(7, 1, 0)] = [("local_ind10", 0, None)]
  ram_map[(7, 1, 1)] = [("local_ind10", 1, None)]
  ram_map[(7, 2, 0)] = [("local_ind20", 0, None)]
  ram_map[(7, 2, 1)] = [("local_ind20", 1, None)]
  ram_map[(7, 3, 0)] = [("local_ind30", 0, None)]
  ram_map[(7, 3, 1)] = [("local_ind30", 1, None)]

  ram_map[(8, 0, 0)] = [("local_val01", 0, None)]
  ram_map[(8, 0, 1)] = [("local_val01", 1, None)]
  ram_map[(8, 1, 0)] = [("local_val11", 0, None)]
  ram_map[(8, 1, 1)] = [("local_val11", 1, None)]
  ram_map[(8, 2, 0)] = [("local_val21", 0, None)]
  ram_map[(8, 2, 1)] = [("local_val21", 1, None)]
  ram_map[(8, 3, 0)] = [("local_val31", 0, None)]
  ram_map[(8, 3, 1)] = [("local_val31", 1, None)]

  ram_map[(9, 0, 0)] = [("local_ind01", 0, None)]
  ram_map[(9, 0, 1)] = [("local_ind01", 1, None)]
  ram_map[(9, 1, 0)] = [("local_ind11", 0, None)]
  ram_map[(9, 1, 1)] = [("local_ind11", 1, None)]
  ram_map[(9, 2, 0)] = [("local_ind21", 0, None)]
  ram_map[(9, 2, 1)] = [("local_ind21", 1, None)]
  ram_map[(9, 3, 0)] = [("local_ind31", 0, None)]
  ram_map[(9, 3, 1)] = [("local_ind31", 1, None)]

def setup_spmv(lsu_rg_map, num_ports, num_lsus, ram_map, xml_files):
  num_ram_groups_bram,\
  num_ram_groups_lutram,\
  num_ram_groups_uram,\
  lut_ram_depth, dp_mode = spmv_rg_config(lsu_rg_map, num_lsus)

  num_ram_groups = num_ram_groups_bram + num_ram_groups_lutram + num_ram_groups_uram
  num_rams  = num_ram_groups * num_ports

  # Manual RAM mapping
  spmv_ram_map_config(ram_map)

  xml_files.append("../benchmarks/hls_kernel/spmv/proj/solution_cl_spmv/syn/report/cl_spmv_csynth.xml")

  return num_ram_groups_bram, num_ram_groups_lutram, num_ram_groups_uram,\
         lut_ram_depth, dp_mode

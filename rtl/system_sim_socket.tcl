set rootdir /path/to/spades

set num_sockets [lindex $argv 0]
# number of m ram ports per core
set num_m_ram_ports_pc [lindex $argv 1]

set verify_len [lindex $argv 2]

set num_noc_si [expr {$num_sockets * $num_m_ram_ports_pc + 2}]
set num_noc_mi [expr {$num_sockets + 1}]

set project_name [lindex $argv 3]

set app [lindex $argv 4]

create_project -force ${project_name} ${project_name} -part xcvc1902-vsvd1760-2MP-e-S
set_property board_part xilinx.com:vck5000:part0:1.0 [current_project]

create_bd_design "design_1"
update_compile_order -fileset sources_1
#create_bd_port -dir I -type clk -freq_hz 500000000 top_clk

#create_bd_port -dir I -type rst top_rstn
set_property ip_repo_paths { } [current_project]

update_ip_catalog

add_files -norecurse [glob *.v *.vh *.mif]
add_files -norecurse [glob riscv/*.v riscv/*.vh riscv/*.mif]
add_files -norecurse [glob ../socket_cc_flow/ff_bridge/ff_bridge_bb.v]
add_files -norecurse [glob ../benchmarks/hls_kernel/${app}/proj/solution_cl_${app}/syn/verilog/*.v]

check_syntax

create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard:1.0 clk_wizard_0
set_property -dict [list CONFIG.USE_LOCKED {true} CONFIG.USE_RESET {true} CONFIG.CLKOUT_USED {true,false,false,false,false,false,false} CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {500,100.000,100.000,100.000,100.000,100.000,100.000} CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} CONFIG.CLKOUT_DRIVES {MBUFGCE,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} CONFIG.CLKOUT1_DIVIDE {6.000000}] [get_bd_cells clk_wizard_0]

make_bd_pins_external  [get_bd_pins clk_wizard_0/clk_in1]
make_bd_pins_external  [get_bd_pins clk_wizard_0/reset]
make_bd_pins_external  [get_bd_pins clk_wizard_0/clk_out1_ce]
make_bd_pins_external  [get_bd_pins clk_wizard_0/clk_out1_clr_n]
make_bd_pins_external  [get_bd_pins clk_wizard_0/clk_out1_o1]

set_property name clkwiz_reset [get_bd_ports reset_0]
set_property name clkwiz_clk_out1_ce [get_bd_ports clk_out1_ce_0]
set_property name clkwiz_clk_out1_clr_n [get_bd_ports clk_out1_clr_n_0]
set_property name clkwiz_clk_in1 [get_bd_ports clk_in1_0]
set_property name user_clk [get_bd_ports clk_out1_o1_0]

update_compile_order -fileset sources_1
create_bd_cell -type module -reference axi_data_generator axi_data_generator_0
connect_bd_net [get_bd_pins clk_wizard_0/clk_out1_o1] [get_bd_pins axi_data_generator_0/clk]
#connect_bd_net [get_bd_ports top_rstn] [get_bd_pins axi_data_generator_0/resetn]

make_bd_pins_external [get_bd_pins axi_data_generator_0/mem_len]
make_bd_pins_external [get_bd_pins axi_data_generator_0/ddr_addr]
make_bd_pins_external [get_bd_pins axi_data_generator_0/ram_addr]
make_bd_pins_external [get_bd_pins axi_data_generator_0/start_write]
make_bd_pins_external [get_bd_pins axi_data_generator_0/done_write]
make_bd_pins_external [get_bd_pins axi_data_generator_0/start_read]
make_bd_pins_external [get_bd_pins axi_data_generator_0/done_read]
make_bd_pins_external [get_bd_pins axi_data_generator_0/dump_mem]

set_property name mem_len [get_bd_ports mem_len_0]
set_property name ddr_addr [get_bd_ports ddr_addr_0]
set_property name ram_addr [get_bd_ports ram_addr_0]
set_property name start_write [get_bd_ports start_write_0]
set_property name done_write [get_bd_ports done_write_0]
set_property name start_read [get_bd_ports start_read_0]
set_property name done_read [get_bd_ports done_read_0]
set_property name dump_mem [get_bd_ports dump_mem_0]

set_property -dict [list CONFIG.MEM_INIT_FILE {dmem_data.mif}] [get_bd_cells axi_data_generator_0]
set_property -dict [list CONFIG.MEM_LEN ${verify_len}] [get_bd_cells axi_data_generator_0]
set_property -dict [list CONFIG.DMEM_AWIDTH 30] [get_bd_cells axi_data_generator_0]

#0x201_0000_0000
create_bd_cell -type module -reference socket_manager socket_manager_0
connect_bd_net [get_bd_pins clk_wizard_0/clk_out1_o1] [get_bd_pins socket_manager_0/clk]
#connect_bd_net [get_bd_ports top_rstn] [get_bd_pins socket_manager_0/resetn]
make_bd_intf_pins_external [get_bd_intf_pins socket_manager_0/s_axi_control]
set_property name s_axi_control [get_bd_intf_ports s_axi_control_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
connect_bd_net [get_bd_pins clk_wizard_0/clk_out1_o1] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_data_generator_0/resetn]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins socket_manager_0/resetn]
make_bd_pins_external  [get_bd_pins proc_sys_reset_0/ext_reset_in]
set_property name resetn [get_bd_ports ext_reset_in_0]

set socket_base_addr 0x020100000000
for {set c 0} {$c < $num_sockets} {incr c} {
  create_bd_cell -type module -reference socket_top socket_top_$c
  connect_bd_net [get_bd_pins clk_wizard_0/clk_out1_o1] [get_bd_pins socket_top_$c/f_clk]
  connect_bd_net [get_bd_pins clk_wizard_0/clk_out1_o2] [get_bd_pins socket_top_$c/clk]

  set_property -dict [list CONFIG.SOCKET_BASE_ADDR [format 0x%x [expr ${socket_base_addr}]]] [get_bd_cells socket_top_$c]
  set socket_base_addr [expr {$socket_base_addr + 0x40000000}]

#  make_bd_intf_pins_external [get_bd_intf_pins socket_top_$c/s_axi_control]
#  if {$c > 0} {
#    set_property name s_axi_control_$c [get_bd_intf_ports s_axi_control_$c]
#  }
  set_property -dict [list CONFIG.IMEM_MIF_HEX ${rootdir}/controller_software/${app}/control${c}.mif] [get_bd_cells socket_top_$c]
}

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.0 axi_noc_0
connect_bd_net [get_bd_pins clk_wizard_0/clk_out1_o1] [get_bd_pins axi_noc_0/aclk0]
set_property -dict [list CONFIG.NUM_MI ${num_noc_mi} CONFIG.NUM_SI ${num_noc_si} CONFIG.NUM_MC {1} CONFIG.NUM_MCP {4} CONFIG.LOGO_FILE {data/noc_mc.png}] [get_bd_cells axi_noc_0]
make_bd_intf_pins_external [get_bd_intf_pins axi_noc_0/CH0_DDR4_0]
make_bd_intf_pins_external [get_bd_intf_pins axi_noc_0/sys_clk0]
set_property name sys_clk [get_bd_intf_ports sys_clk0_0]
set_property -dict [list CONFIG.FREQ_HZ {200000000}] [get_bd_intf_ports sys_clk]

set_property name CH0_DDR4 [get_bd_intf_ports CH0_DDR4_0_0]
set_property -dict [list CONFIG.MC_IP_TIMEPERIOD0_FOR_OP {5000} CONFIG.MC_FREQ_SEL {MEMORY_CLK_FROM_SYS_CLK} CONFIG.MC_INPUT_FREQUENCY0 {200.000} CONFIG.MC_COMPONENT_WIDTH {x16} CONFIG.MC_MEM_DEVICE_WIDTH {x16} CONFIG.MC_MEMORY_DENSITY {4GB} CONFIG.MC_TFAW {30000} CONFIG.MC_TRRD_S {9} CONFIG.MC_TRRD_L {11} CONFIG.MC_BG_WIDTH {1} CONFIG.MC_USER_DEFINED_ADDRESS_MAP {16RA-2BA-1BG-10CA} CONFIG.MC_TFAWMIN {30000} CONFIG.MC_TRRD_S_MIN {9} CONFIG.MC_EN_INTR_RESP {TRUE} CONFIG.MC_F1_TFAW {30000} CONFIG.MC_F1_TFAWMIN {30000} CONFIG.MC_F1_TRRD_S {9} CONFIG.MC_F1_TRRD_S_MIN {9} CONFIG.MC_F1_TRRD_L {11} CONFIG.MC_F1_TRRD_L_MIN {11} CONFIG.MC_F1_LPDDR4_MR1 {0x000} CONFIG.MC_F1_LPDDR4_MR2 {0x000} CONFIG.MC_F1_LPDDR4_MR3 {0x000} CONFIG.MC_F1_LPDDR4_MR13 {0x000} CONFIG.MC_ECC_SCRUB_SIZE {4096} CONFIG.MC_DDR_INIT_TIMEOUT {0x000408B7}] [get_bd_cells axi_noc_0]

connect_bd_intf_net [get_bd_intf_pins axi_data_generator_0/m] [get_bd_intf_pins axi_noc_0/S00_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X0Y0}] [get_bd_intf_pins axi_noc_0/S00_AXI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} }] [get_bd_intf_pins /axi_noc_0/S00_AXI]

set_property SIM_ATTRIBUTE.MARK_SIM true [get_bd_intf_nets axi_data_generator_0_m]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 axi_register_slice_0
connect_bd_intf_net [get_bd_intf_pins axi_noc_0/M00_AXI] [get_bd_intf_pins axi_register_slice_0/S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_register_slice_0/M_AXI] [get_bd_intf_pins socket_manager_0/s]
connect_bd_net [get_bd_pins axi_register_slice_0/aclk] [get_bd_pins clk_wizard_0/clk_out1_o1]
connect_bd_net [get_bd_pins axi_register_slice_0/aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]

connect_bd_intf_net [get_bd_intf_pins socket_manager_0/m0] [get_bd_intf_pins axi_noc_0/S01_AXI]
#connect_bd_intf_net [get_bd_intf_pins axi_noc_0/M00_AXI] [get_bd_intf_pins socket_manager_0/s]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X0Y1}] [get_bd_intf_pins axi_noc_0/S01_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NSU512_X0Y1}] [get_bd_intf_pins axi_noc_0/M00_AXI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} }] [get_bd_intf_pins /axi_noc_0/S01_AXI]

set_property SIM_ATTRIBUTE.MARK_SIM true [get_bd_intf_nets socket_manager_0_m0]

set_property -dict [list CONFIG.PHYSICAL_LOC {DDRMC_X2Y0}] [get_bd_intf_pins axi_noc_0/CH0_DDR4_0]

set m_noc_config ""
set mc_port_id 2

set m_noc_config_for_socket0 "MC_$mc_port_id { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}}"

for {set c 0} {$c < $num_sockets} {incr c} {
  set c1 [expr {$c + 1}]
  if {$c1 < 10} {
    append m_noc_config_for_socket0 " M0${c1}_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} "
  } else {
    append m_noc_config_for_socket0 " M${c1}_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} "
  }
}

for {set c 0} {$c < $num_sockets} {incr c} {
  set c1 [expr {$c + 1}]
  if {$c1 < 10} {
    append m_noc_config " M0${c1}_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} "
    connect_bd_intf_net [get_bd_intf_pins axi_noc_0/M0${c1}_AXI] [get_bd_intf_pins socket_top_${c}/s0]
  } else {
    append m_noc_config " M${c1}_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} "
    connect_bd_intf_net [get_bd_intf_pins axi_noc_0/M${c1}_AXI] [get_bd_intf_pins socket_top_${c}/s0]
  }

  for {set i 0} {$i < $num_m_ram_ports_pc} {incr i} {
    set port_id [expr {$c * $num_m_ram_ports_pc + $i + 2}]
#    if {$port_id < 10} {
#      connect_bd_intf_net [get_bd_intf_pins socket_top_${c}/m${i}] [get_bd_intf_pins axi_noc_0/S0${port_id}_AXI]
#      set_property -dict [list CONFIG.CONNECTIONS [list MC_$mc_port_id { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} ]] [get_bd_intf_pins /axi_noc_0/S0${port_id}_AXI]
#    } else {
#      connect_bd_intf_net [get_bd_intf_pins socket_top_${c}/m${i}] [get_bd_intf_pins axi_noc_0/S${port_id}_AXI]
#      set_property -dict [list CONFIG.CONNECTIONS [list MC_$mc_port_id { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} ]] [get_bd_intf_pins /axi_noc_0/S${port_id}_AXI]
#    }
    if {$c == 0} {
      connect_bd_intf_net [get_bd_intf_pins socket_top_${c}/m${i}] [get_bd_intf_pins axi_noc_0/S0${port_id}_AXI]
      if {$port_id % 2 == 0} {
      set_property -dict [list CONFIG.CONNECTIONS ${m_noc_config_for_socket0}] [get_bd_intf_pins /axi_noc_0/S0${port_id}_AXI]
      } else {
      set_property -dict [list CONFIG.CONNECTIONS [list MC_$mc_port_id { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} ]] [get_bd_intf_pins /axi_noc_0/S0${port_id}_AXI]
      }
    } elseif {$port_id < 10} {
      connect_bd_intf_net [get_bd_intf_pins socket_top_${c}/m${i}] [get_bd_intf_pins axi_noc_0/S0${port_id}_AXI]
      if {$port_id % 2 == 0} {
      set_property -dict [list CONFIG.CONNECTIONS [list MC_$mc_port_id { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M01_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} ]] [get_bd_intf_pins /axi_noc_0/S0${port_id}_AXI]
      } else {
      set_property -dict [list CONFIG.CONNECTIONS [list MC_$mc_port_id { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} ]] [get_bd_intf_pins /axi_noc_0/S0${port_id}_AXI]
      }
    } else {
      connect_bd_intf_net [get_bd_intf_pins socket_top_${c}/m${i}] [get_bd_intf_pins axi_noc_0/S${port_id}_AXI]
      if {$port_id % 2 == 0} {
      set_property -dict [list CONFIG.CONNECTIONS [list MC_$mc_port_id { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M01_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}}]] [get_bd_intf_pins /axi_noc_0/S${port_id}_AXI]
      } else {
      set_property -dict [list CONFIG.CONNECTIONS [list MC_$mc_port_id { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} ]] [get_bd_intf_pins /axi_noc_0/S${port_id}_AXI]
      }
    }

    set mc_port_id [expr $mc_port_id + 1]
    if {$mc_port_id == 4} {
      set mc_port_id 2
    }
    set_property SIM_ATTRIBUTE.MARK_SIM true [get_bd_intf_nets socket_top_${c}_m${i}]
  }
}

set_property -dict [list CONFIG.CONNECTIONS ${m_noc_config}] [get_bd_intf_pins /axi_noc_0/S01_AXI]
set_property CONFIG.ASSOCIATED_BUSIF {s_axi_control} [get_bd_ports /user_clk]

set_property -dict [list CONFIG.NUM_CLKS {2}] [get_bd_cells axi_noc_0]
set_property -dict [list CONFIG.ASSOCIATED_BUSIF {S00_AXI:S01_AXI}] [get_bd_pins /axi_noc_0/aclk0]
set_property -dict [list CONFIG.ASSOCIATED_BUSIF {S03_AXI:S02_AXI:M00_AXI}] [get_bd_pins /axi_noc_0/aclk1]
connect_bd_net [get_bd_pins axi_noc_0/aclk1] [get_bd_pins clk_wizard_0/clk_out1_o2]

#set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X2Y1}] [get_bd_intf_pins axi_noc_0/S03_AXI]
#set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X2Y0}] [get_bd_intf_pins axi_noc_0/S02_AXI]
#set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NSU512_X2Y0}] [get_bd_intf_pins axi_noc_0/M00_AXI]

if {$num_sockets >= 1} {
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X1Y0}] [get_bd_intf_pins axi_noc_0/S02_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X1Y1}] [get_bd_intf_pins axi_noc_0/S03_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NSU512_X1Y0}] [get_bd_intf_pins axi_noc_0/M01_AXI]
}
if {$num_sockets >= 2} {
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X2Y0}] [get_bd_intf_pins axi_noc_0/S04_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X2Y1}] [get_bd_intf_pins axi_noc_0/S05_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NSU512_X2Y0}] [get_bd_intf_pins axi_noc_0/M02_AXI]
}
if {$num_sockets >= 3} {
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X3Y0}] [get_bd_intf_pins axi_noc_0/S06_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X3Y1}] [get_bd_intf_pins axi_noc_0/S07_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NSU512_X3Y0}] [get_bd_intf_pins axi_noc_0/M03_AXI]
}
if {$num_sockets >= 4} {
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X1Y2}] [get_bd_intf_pins axi_noc_0/S08_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X1Y3}] [get_bd_intf_pins axi_noc_0/S09_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NSU512_X1Y2}] [get_bd_intf_pins axi_noc_0/M04_AXI]
}
if {$num_sockets >= 5} {
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X2Y2}] [get_bd_intf_pins axi_noc_0/S10_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X2Y3}] [get_bd_intf_pins axi_noc_0/S11_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NSU512_X2Y2}] [get_bd_intf_pins axi_noc_0/M05_AXI]
}
if {$num_sockets >= 6} {
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X3Y2}] [get_bd_intf_pins axi_noc_0/S12_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X3Y3}] [get_bd_intf_pins axi_noc_0/S13_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NSU512_X3Y2}] [get_bd_intf_pins axi_noc_0/M06_AXI]
}
if {$num_sockets >= 7} {
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X1Y4}] [get_bd_intf_pins axi_noc_0/S14_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X1Y5}] [get_bd_intf_pins axi_noc_0/S15_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NSU512_X1Y4}] [get_bd_intf_pins axi_noc_0/M07_AXI]
}
if {$num_sockets >= 8} {
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X2Y4}] [get_bd_intf_pins axi_noc_0/S16_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X2Y5}] [get_bd_intf_pins axi_noc_0/S17_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NSU512_X2Y4}] [get_bd_intf_pins axi_noc_0/M08_AXI]
}
if {$num_sockets >= 9} {
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X3Y4}] [get_bd_intf_pins axi_noc_0/S18_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NMU512_X3Y5}] [get_bd_intf_pins axi_noc_0/S19_AXI]
set_property -dict [list CONFIG.PHYSICAL_LOC {NOC_NSU512_X3Y4}] [get_bd_intf_pins axi_noc_0/M09_AXI]
}

set rd_bw [expr round(10000 / $num_sockets)]
set wr_bw [expr round(10000 / $num_sockets)]

if {$num_sockets >= 1} {
set_property -dict [list CONFIG.CONNECTIONS [subst {M01_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} MC_2 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}}} ]] [get_bd_intf_pins /axi_noc_0/S02_AXI]
set_property -dict [list CONFIG.CONNECTIONS [subst {MC_3 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S03_AXI]
}
if {$num_sockets >= 2} {
set_property -dict [list CONFIG.CONNECTIONS [subst {M02_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M01_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} MC_2 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}}} ]] [get_bd_intf_pins /axi_noc_0/S02_AXI]
set_property -dict [list CONFIG.CONNECTIONS [subst {M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M01_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} MC_2 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S04_AXI]
set_property -dict [list CONFIG.CONNECTIONS [subst {MC_3 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S05_AXI]
}
if {$num_sockets >= 3} {
set_property -dict [list CONFIG.CONNECTIONS [subst {M03_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M02_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M01_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} MC_2 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}}} ]] [get_bd_intf_pins /axi_noc_0/S02_AXI]
set_property -dict [list CONFIG.CONNECTIONS [subst {M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M01_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} MC_2 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S06_AXI]
set_property -dict [list CONFIG.CONNECTIONS [subst {MC_3 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S07_AXI]
}
if {$num_sockets >= 4} {
set_property -dict [list CONFIG.CONNECTIONS [subst {M04_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M03_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M02_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M01_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} MC_2 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}}} ]] [get_bd_intf_pins /axi_noc_0/S02_AXI]
set_property -dict [list CONFIG.CONNECTIONS [subst {M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M01_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} MC_2 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S08_AXI]
set_property -dict [list CONFIG.CONNECTIONS [subst {MC_3 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S09_AXI]
}
if {$num_sockets >= 5} {
set_property -dict [list CONFIG.CONNECTIONS [subst {M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} MC_2 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S10_AXI]
set_property -dict [list CONFIG.CONNECTIONS [subst {MC_3 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S11_AXI]
}
if {$num_sockets >= 6} {
set_property -dict [list CONFIG.CONNECTIONS [subst {M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} MC_2 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S12_AXI]
set_property -dict [list CONFIG.CONNECTIONS [subst {MC_3 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S13_AXI]
}
if {$num_sockets >= 7} {
set_property -dict [list CONFIG.CONNECTIONS [subst {M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} MC_2 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S14_AXI]
set_property -dict [list CONFIG.CONNECTIONS [subst {MC_3 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S15_AXI]
}
if {$num_sockets >= 8} {
set_property -dict [list CONFIG.CONNECTIONS [subst {M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} MC_2 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S16_AXI]
set_property -dict [list CONFIG.CONNECTIONS [subst {MC_3 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S17_AXI]
}
if {$num_sockets >= 9} {
set_property -dict [list CONFIG.CONNECTIONS [subst {M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} MC_2 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S18_AXI]
set_property -dict [list CONFIG.CONNECTIONS [subst {MC_3 { read_bw {$rd_bw} write_bw {$wr_bw} read_avg_burst {4} write_avg_burst {4}} }]] [get_bd_intf_pins /axi_noc_0/S19_AXI]
}

save_bd_design
assign_bd_address

make_wrapper -files [get_files ${project_name}/${project_name}.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse ${project_name}/${project_name}.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v
validate_bd_design
set_property top design_1_wrapper [current_fileset]
generate_target Simulation [get_files ${project_name}/${project_name}.srcs/sources_1/bd/design_1/design_1.bd]
save_bd_design
#exit

add_files -norecurse testbenches/system_socket_tb.v
set_property top system_socket_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
export_ip_user_files -of_objects [get_files ${project_name}/${project_name}.srcs/sources_1/bd/design_1/design_1.bd] -no_script -sync -force -quiet
launch_simulation
save_wave_config ${project_name}/system_socket_tb_behav.wcfg
add_files -fileset sim_1 -norecurse ${project_name}/system_socket_tb_behav.wcfg
set_property xsim.view ${project_name}/system_socket_tb_behav.wcfg [get_filesets sim_1]
run all

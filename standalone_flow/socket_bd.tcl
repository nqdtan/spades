
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2022.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvc1902-vsvd1760-2MP-e-S
   set_property BOARD_PART xilinx.com:vck5000:part0:1.0 [current_project]
}

set_property ip_repo_paths [concat [glob ../ulp_design/kernel_pack_*]] [current_project]

# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:RTLKernel:mbufgce_primitive:1.0\
xilinx.com:ip:axi_noc:1.0\
xilinx.com:RTLKernel:lut1_primitive:1.0\
xilinx.com:RTLKernel:socket_top:1.0\
xilinx.com:ip:xlconstant:1.1\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: socket
proc create_hier_cell_socket { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_socket() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M01_INI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 S00_INI


  # Create pins
  create_bd_pin -dir I -type clk f_clk
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I lut1_in
  create_bd_pin -dir O mbufgce_clr_n

  # Create instance: axi_noc_0, and set properties
  set axi_noc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.0 axi_noc_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_NMI {2} \
   CONFIG.NUM_NSI {1} \
   CONFIG.NUM_SI {2} \
 ] $axi_noc_0

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.PHYSICAL_LOC {NOC_NSU512_X0Y2} \
   CONFIG.APERTURES {{0x201_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /socket/axi_noc_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.PHYSICAL_LOC {NOC_NMU512_X1Y2} \
   CONFIG.CONNECTIONS {M00_INI { read_bw {5} write_bw {5}} } \
   CONFIG.DEST_IDS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /socket/axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
 ] [get_bd_intf_pins /socket/axi_noc_0/S00_INI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.PHYSICAL_LOC {NOC_NMU512_X1Y3} \
   CONFIG.CONNECTIONS {M01_INI { read_bw {5} write_bw {5}} } \
   CONFIG.DEST_IDS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /socket/axi_noc_0/S01_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI:S00_AXI:S01_AXI} \
 ] [get_bd_pins /socket/axi_noc_0/aclk0]

  # Create instance: lut1_primitive_0, and set properties
  set lut1_primitive_0 [ create_bd_cell -type ip -vlnv xilinx.com:RTLKernel:lut1_primitive:1.0 lut1_primitive_0 ]

  # Create instance: socket_top_0, and set properties
  set socket_top_0 [ create_bd_cell -type ip -vlnv xilinx.com:RTLKernel:socket_top:1.0 socket_top_0 ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins M00_INI] [get_bd_intf_pins axi_noc_0/M00_INI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins M01_INI] [get_bd_intf_pins axi_noc_0/M01_INI]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins S00_INI] [get_bd_intf_pins axi_noc_0/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_0_M00_AXI [get_bd_intf_pins axi_noc_0/M00_AXI] [get_bd_intf_pins socket_top_0/s0]
  connect_bd_intf_net -intf_net socket_top_0_m0 [get_bd_intf_pins axi_noc_0/S00_AXI] [get_bd_intf_pins socket_top_0/m0]
  connect_bd_intf_net -intf_net socket_top_0_m1 [get_bd_intf_pins axi_noc_0/S01_AXI] [get_bd_intf_pins socket_top_0/m1]

  # Create port connections
  connect_bd_net -net I0_0_1 [get_bd_pins lut1_in] [get_bd_pins lut1_primitive_0/I0]
  connect_bd_net -net f_clk_1 [get_bd_pins f_clk] [get_bd_pins socket_top_0/f_clk]
  connect_bd_net -net clk_1 [get_bd_pins clk] [get_bd_pins axi_noc_0/aclk0] [get_bd_pins socket_top_0/clk]
  connect_bd_net -net lut1_primitive_0_O [get_bd_pins mbufgce_clr_n] [get_bd_pins lut1_primitive_0/O]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set M00_INI [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI ]
  set_property -dict [ list \
   CONFIG.COMPUTED_STRATEGY {load} \
   ] $M00_INI

  set M01_INI [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M01_INI ]
  set_property -dict [ list \
   CONFIG.COMPUTED_STRATEGY {load} \
   ] $M01_INI

  set S00_INI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 S00_INI ]
  set_property -dict [ list \
   CONFIG.COMPUTED_STRATEGY {load} \
   ] $S00_INI


  # Create ports
  set aclk [ create_bd_port -dir I -type clk -freq_hz 500000000 aclk ]
  set clk_ce [ create_bd_port -dir I clk_ce ]

  # Create instance: mbufgce_primitive_0, and set properties
  set mbufgce_primitive_0 [ create_bd_cell -type ip -vlnv xilinx.com:RTLKernel:mbufgce_primitive:1.0 mbufgce_primitive_0 ]

  # Create instance: socket
  create_hier_cell_socket [current_bd_instance .] socket

  # Create interface connections
  connect_bd_intf_net -intf_net S00_INI_0_1 [get_bd_intf_ports S00_INI] [get_bd_intf_pins socket/S00_INI]
  connect_bd_intf_net -intf_net socket_M00_INI [get_bd_intf_ports M00_INI] [get_bd_intf_pins socket/M00_INI]
  connect_bd_intf_net -intf_net socket_M01_INI [get_bd_intf_ports M01_INI] [get_bd_intf_pins socket/M01_INI]

  # Create port connections
  connect_bd_net -net aclk_1 [get_bd_ports aclk] [get_bd_pins mbufgce_primitive_0/clk_in]
  connect_bd_net -net ce_0_1 [get_bd_ports clk_ce] [get_bd_pins mbufgce_primitive_0/ce] [get_bd_pins socket/lut1_in]
  connect_bd_net -net mbufgce_primitive_0_clk_out_o1 [get_bd_pins mbufgce_primitive_0/clk_out_o1] [get_bd_pins socket/f_clk]
  connect_bd_net -net mbufgce_primitive_0_clk_out_o2 [get_bd_pins mbufgce_primitive_0/clk_out_o2] [get_bd_pins socket/clk]
  connect_bd_net -net socket_top_0_mbufgce_clr_n [get_bd_pins mbufgce_primitive_0/clr_n] [get_bd_pins socket/mbufgce_clr_n]

  # Create address segments
  assign_bd_address -offset 0x44A00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces socket/socket_top_0/m0] [get_bd_addr_segs M00_INI/Reg] -force
  assign_bd_address -offset 0x44A00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces socket/socket_top_0/m1] [get_bd_addr_segs M01_INI/Reg] -force
  assign_bd_address -offset 0x020100000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs socket/socket_top_0/s0/reg0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""



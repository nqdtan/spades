# /*******************************************************************************
# Copyright (c) 2018, Xilinx, Inc.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 
# 
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software
# without specific prior written permission.
# 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
# OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# *******************************************************************************/

set top [lindex $argv 0]
set app [lindex $argv 1]
set func [lindex $argv 2]

set src_dir ../rtl

create_project -force kernel_pack_$top kernel_pack_$top -part xcvc1902-vsvd1760-2MP-e-S
add_files -norecurse [glob $src_dir/*.v]
add_files -norecurse [glob $src_dir/*.vh]
add_files -norecurse [glob $src_dir/riscv/*.v]
add_files -norecurse [glob $src_dir/riscv/*.vh]
add_files -norecurse [glob $src_dir/../socket_cc_flow/ff_bridge/ff_bridge.v]
if { $app != "" } {
  add_files -norecurse [glob ../benchmarks/hls_kernel/${app}/proj/solution_${func}/syn/verilog/*.v]
  set tclFiles [glob -nocomplain ../benchmarks/hls_kernel/${app}/proj/solution_${func}/syn/verilog/*.tcl]
  foreach f $tclFiles {
  source $f }
}

check_syntax

set_property top $top [current_fileset]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
ipx::package_project -root_dir kernel_pack_$top -vendor xilinx.com -library RTLKernel -taxonomy /KernelIP -import_files -set_current false
ipx::unload_core kernel_pack_$top/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory kernel_pack_$top kernel_pack_$top/component.xml
set_property core_revision 2 [ipx::current_core]

set_property sdx_kernel true [ipx::current_core]
set_property sdx_kernel_type rtl [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]

ipx::associate_bus_interfaces -busif m0 -clock clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m1 -clock clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axis -clock f_clk [ipx::current_core]

ipx::associate_bus_interfaces -busif s0 -clock clk [ipx::current_core]
ipx::associate_bus_interfaces -busif s_axis -clock f_clk [ipx::current_core]

set_property xpm_libraries {XPM_CDC XPM_MEMORY XPM_FIFO} [ipx::current_core]
set_property supported_families { } [ipx::current_core]
set_property auto_family_support_level level_2 [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete

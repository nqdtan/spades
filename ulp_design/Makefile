
ts=$(shell date +"%Y-%m-%d_%H-%M-%S")
project_name=project_rm_$(top)_$(ts)

SRC_DIR := ../rtl

SRC := $(SRC_DIR)/*.v
SRC += $(SRC_DIR)/*.vh
SRC += $(SRC_DIR)/riscv/*.v
SRC += $(SRC_DIR)/riscv/*.vh
SRC += $(SRC_DIR)/*.mif

KERNEL_XML := kernel_pack_$(top)/component.xml
ULP_BD := myproj_$(top)_$(num_sockets)/project_1.srcs/sources_1/bd/ulp/ulp.bd
XPR := $(project_name)/$(project_name).xpr

jobs := 1
BD_TCL := ulp_bd_$(flow).tcl

$(XPR):
	vivado -mode batch -source build_rm_project.tcl -tclargs $(project_name) $(top) $(jobs) > log_rm_$(top)_$(ts)

$(ULP_BD):
	vivado -mode batch -source $(BD_TCL) -tclargs $(num_sockets)

$(KERNEL_XML):
	vivado -mode batch -source package_kernel_$(script).tcl -tclargs $(top) $(app) $(func)

kernel_pack: $(KERNEL_XML)
ulp_bd: $(ULP_BD)
rm_project: $(XPR)

clean:
	rm -f log_rm_* *.log *.jou

cleanall:
	rm -rf log_rm_* *.log *.jou kernel_pack* myproj* project_rm*

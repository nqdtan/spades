
VERILOG_SRCS := *.v
VERILOG_SRCS += riscv/*.v
VERILOG_SRCS += testbenches/*.v
APP_DIR := ../benchmarks/hls_kernel
VERILOG_SRCS += $(APP_DIR)/$(sw)/proj/solution_cl_$(kernel)/syn/verilog/*.v
VERILOG_SRCS += ../socket_cc_flow/ff_bridge/ff_bridge_sim.v

SW_DIR := ../controller_software/$(sw)
SW_SRCS  := $(wildcard $(SW_DIR)/*.h)
SW_SRCS  += $(wildcard $(SW_DIR)/*.c)
SW_SRCS  += $(wildcard $(SW_DIR)/*.s)
SW_SRCS  += $(wildcard $(SW_DIR)/*.ld)

top = socket

sim_exec = $(top).out
sw_mif = $(SW_DIR)/control.mif
init_mif    = $(APP_DIR)/$(sw)/$(sw)_init.mif
result_mif  = $(APP_DIR)/$(sw)/$(sw)_result.mif

$(sw_mif): $(SW_SRCS)
	cd $(SW_DIR) && make clean && make > /dev/null

.PHONY: iverilog-compile
iverilog-compile: $(sim_exec)

$(sim_exec): $(VERILOG_SRCS) $(sw_mif)
	iverilog $(VERILOG_SRCS) -I . -I riscv -s $(top) -o $(sim_exec)

.PHONY: iverilog-sim
iverilog-sim: $(sim_exec)
	./$(sim_exec) +CONTROL_FILE=$(SW_DIR)/control.mif +INIT_FILE=$(sw)_init.mif.${size} +VERIFY_FILE=$(sw)_result.mif.${size}

XPR = project_sim/project_sim.xpr

$(XPR): $(VERILOG_SRCS)
	vivado -mode batch -source build_project.tcl -tclargs $(APP_DIR) $(sw) $(kernel)

.PHONY: build-project
build-project: $(XPR)

.PHONY: xsim
xsim: $(VERILOG_SRCS) $(sw_mif) $(XPR)
	vivado -mode batch -source xsim.tcl -tclargs $(top) $(sw_mif) $(init_mif) $(result_mif)

.PHONY: clean
clean:
	rm -rf *.log *.out *.vcd *.mif *.mif.*

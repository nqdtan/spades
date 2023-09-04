
APP_DIR=$(app)
APP=app.exe

.PHONY: run

$(APP): $(APP_DIR)/host.cpp reset_bufdiv.cpp $(APP_DIR)/*.h
	g++ -Wall -g -std=c++14 $(APP_DIR)/host.cpp -o $(APP) -I$(APP_DIR) -I$(XILINX_XRT)/include/ -L$(XILINX_XRT)/lib/ -lOpenCL -lpthread -lrt -lstdc++ -lxrt_coreutil
	g++ -Wall -g -std=c++14 reset_bufdiv.cpp -o reset_bufdiv.exe -I$(XILINX_XRT)/include/ -L$(XILINX_XRT)/lib/ -lOpenCL -lpthread -lrt -lstdc++ -lxrt_coreutil

.PHONY: compile
compile: $(APP)

run: $(APP)
	./$(APP_DIR)/$(APP)

.PHONY: clean
clean:
	rm -f *.exe

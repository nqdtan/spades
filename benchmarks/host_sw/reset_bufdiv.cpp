
#include <iostream>
#include <cstdlib>
#include <unistd.h>
#include <sys/stat.h>
#include <string>
#include <sys/time.h>
#include "experimental/xrt_kernel.h"
#include "experimental/xrt_ip.h"
#include "experimental/xrt_uuid.h"

#define DEVICE_ID 0
typedef int64_t DATATYPE;

#define SOCKET_CSR_OFFSET        64
#define EXT_MEM_OFFSET_LO        65
#define EXT_MEM_OFFSET_HI        66
#define SOCKET_IMEM_ADDR_OFFSET  67
#define SOCKET_IMEM_WDATA_OFFSET 68
#define SOCKET_IMEM_WE_OFFSET    69

int main(int argc, char *argv[]) {
  std::string xclbin_file;
  std::cout << "Program running in hardware mode" << std::endl;
  xclbin_file = "ulp.xclbin";

  // Load xclbin
  std::cout << "Load " << xclbin_file << std::endl;
  xrt::device device = xrt::device(DEVICE_ID);
  xrt::uuid xclbin_uuid = device.load_xclbin(xclbin_file);

  // create kernel objects
  std::cout << "Create kernel" << std::endl;
  xrt::ip ip = xrt::ip(device, xclbin_uuid, "socket_manager");

  ip.write_register(0x24, 0);
  ip.write_register(0x28, 0);

  std::cout << "socket_manager state_wr " << std::hex << ip.read_register(0x18) << std::dec << '\n';
  std::cout << "socket_manager state_rd " << std::hex << ip.read_register(0x2c) << std::dec << '\n';

  std::cout << "[0] clkwiz_ce " << std::dec << ip.read_register(0x30) << std::dec << '\n';
  std::cout << "[0] clkwiz_clr " << std::dec << ip.read_register(0x34) << std::dec << '\n';

  int mbufgce_clr = 0xFFF;

  // clear clock bufdiv leaves
  ip.write_register(0x30, 0);
  ip.write_register(0x34, mbufgce_clr);
  usleep(1000000);

//  ip.write_register(0x34, 1);

  std::cout << "[1] clkwiz_ce " << std::dec << ip.read_register(0x30) << std::dec << '\n';
  std::cout << "[1] clkwiz_clr " << std::dec << ip.read_register(0x34) << std::dec << '\n';

  ip.write_register(0x34, 0);
  usleep(1000000);
  // enable mbufgce
  ip.write_register(0x30, 1);

  std::cout << "[2] clkwiz_ce " << std::dec << ip.read_register(0x30) << std::dec << '\n';
  std::cout << "[2] clkwiz_clr " << std::dec << ip.read_register(0x34) << std::dec << '\n';
}

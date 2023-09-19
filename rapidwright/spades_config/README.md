
The SPADESFlow java program requires a JSON input file for the description of how
to craft a full design checkpoint (full_design.dcp) from one or many design
checkpoints available in spades/checkpoints.
Here we show the available fields and expected values of the JSON configuration file.

- FullShell:
  - true: create a full design that uses the full shell checkpoint (shell_static).
The design checkpoint is ready for bitstream generation.
  - false: create a full design that uses partial shell checkpoint (ulp_static).
This is mainly for debugging purpose (e.g., inspecting the routing in socket region),
since the DCP loads faster in Vivado due to reduced size as compared to the full shell.

- SocketDesign:
  - DesignId: an integer. To distinguish between different socket designs in the full design.
  - ImplId: an integer. To select different floorplan shapes.
    - 0: floorplan w=1,h=1 (socket_m)
    - 1: floorplan w=2,h=1
    - 2: floorplan w=1,h=2
    - 3: floorplan w=1,h=3
    - 4: floorplan w=1,h=1 (socket_s)
  - Flow:
    - "separateCCCL": SocketCC + SocketCL flow
    - "standalone": standalone flow. No precompiled part.
  - DcpName: a string. Name of the DCP file of the socket design. Must be found at spades/checkpoints

- SocketConnect
  - NMUSocketId: an integer. Refer to the DesignId of the NMU socket
  - NSUSocketId: an integer. Refer to the DesignId of the NSU socket. 28 represents DDR (since the target device only has 28 PL NSUs).
  - NMUName: a string. The AXI port name of the NMU Socket module. E.g., "S00", "S01" 
  - NSUName: a string. The AXI port name or DDRMC port name of the NSU Socket module. E.g., "M00", "2" (DDRMC), "3" (DDRMC)
  - Type: a string. Type of AXI transaction.
    - "AXI": This connection uses AXI-MM
    - "AXIS": This connection uses AXI-Stream

# Notes

- If DDRMC is specified as NSUSocket (id 28), the only accepted `NSUName` values are "2" and "3" (PORT2 and PORT3).
Otherwise, Vivado NoC compiler would not generate a working Noc solution.


First, please make sure base platform checkpoint and shell utility IPs are present
at spades/ulp_design/utils. They can be found in the `spades\_assets`.

```
cp /path/to/spades_assets/utils /path/to/spades/ulp_design/ -R
```

Available commands

```
make kernel_pack script={script} top={top} app={app} func={top_func}
make ulp_bd flow={flow}
make rm_project top={flow} jobs={num_jobs}
```

Examples

```
## Example to build shell static design checkpoint
# Package required IPs: lut1_primitive, mbufgce_primitive, socket_manager
make kernel_pack script=lut_primitive
make kernel_pack script=mbufgce_primitive
make kernel_pack script=socket_manager

# Run Block Design to build socket_manager project
make ulp_bd flow=socket_manager

# Run Synthesis & Implementation to implement socket_manager project. The output
# is shell_static.dcp
make rm_project top=socket_manager jobs=1

## Example to build socket project in top-down mode
# Package IP socket_top for matmul
make kernel_pack script=socket_top top=socket_top app=matmul func=cl_matmul

# Run Block Design to build socket project with 4 sockets
make ulp_bd flow=socket num_sockets=4

# Implement the project
make rm_project top=socket_4 jobs=1

# Alternatively, this can also be accomplised with the following command
./run_socket_td_flow.sh matmul cl_matmul 4

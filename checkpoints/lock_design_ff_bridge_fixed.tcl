open_checkpoint ff_bridge_extracted.dcp
lock_design -level routing
set_property is_route_fixed 1 [get_nets { stub  }]
write_checkpoint -force ff_bridge_extracted_fixed.dcp

# This is a simple tcl script which creates the vivado project for the AXI MASTER BURST DDR COMMUNICATION

create_project project_1 ./ddr_comm_test -part xc7z045ffg900-2
set_property board_part em.avnet.com:zed:part0:1.2 [current_project]

add_files -fileset sim_1 ../sim
update_compile_order -fileset sim_1
update_compile_order -fileset sim_1

add_files ../hdl
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
update_compile_order -fileset sources_1









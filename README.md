# zynq_ddr_design_ex
simulation setup (written in verilog) to simulate the signals of an AXI master burst IPIF and user logic (designed in vivado design suite aimed at zynq devices based xilinx FPGAs)

NOTE - this work is based on the work released by TU-Kaiserslautern under the GPL licanse. For more information, please visit the following link. 
https://ems.eit.uni-kl.de/lehre/online-kurse/xilinx-zynq/



1. this simulation setup is to implement the AXI MASTER busrt IPIF with a sample user logic
2. this setup is a simple combination of two state machines - main_FSM and axi_FSM which govern read and write transaction between the DDR (simulated by a file in the axi master burst IPIF simulation module) and the user logic (currently just a register in the ddr_comm_controller module but extensible to any complex buffer based state machine)
3. The simulation models are not accurate - they just serve as a means to test user logic in the burst IPIF environment and track the internal buffer in "user logic" against IPIF signals - the clock latencies observed in simulation using these models is not golden by any means
4. The write operation writes to a file (which again simulates a DDR)
5. for information on IPIF IP - documentation 
http://www.xilinx.com/support/documentation/ip_documentation/axi_master_burst/v1_00_a/ds844_axi_master_burst.pdf

6. simulation setup:
   include the provided files in your design.
  create a testbench with an enable and reset signal for logic control
  tweak the "fixed signals" in the controller module to tweak the read and write parameters
  run simulation - data reg should follow the bus2ip_mstrd_d signal for the #<burst length> cycles
  the output file (writefileH in the IPIF module) should reflect the ip2bus_mstwr_d signal

Note: This work is open source and doesnt come with any kind of warranty/guarantee or assurance of accuracy or correctness. If you get some initial errors, a run of the mill verilog debugging should set things straight. my email is prakhar.gtm@gmail.com in case you want to write to me for questions.  

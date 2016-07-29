

`timescale 1ns/1ps 

`include "design_definitions.sv" 

module  ddr_comm_top #
(
//design parameters 
<internal parameter = val>
)
(
input 	wire  					s_axi_aclk,
input 	wire  					s_axi_aresetn,
input 	wire [31:0] 				s_axi_awaddr,
input 	wire [2:0] 				s_axi_awprot,
input 	wire  					s_axi_awvalid,
output 	wire  					s_axi_awready,
input 	wire [31:0] 				s_axi_wdata,
input 	wire [3:0] 				s_axi_wstrb,
input 	wire  					s_axi_wvalid,
output 	wire  					s_axi_wready,
output 	wire [1:0] 				s_axi_bresp,
output 	wire  					s_axi_bvalid,
input 	wire  					s_axi_bready,
input 	wire [31:0] 				s_axi_araddr,
input 	wire [2:0] 				s_axi_arprot,
input 	wire  					s_axi_arvalid,
output 	wire  					s_axi_arready,
output 	wire [31:0] 				s_axi_rdata,
output 	wire [1:0] 				s_axi_rresp,
output 	wire  					s_axi_rvalid,
input 	wire  					s_axi_rready,


input 	wire    				m_axi_aclk,
input 	wire    				m_axi_aresetn,
input 	wire    				m_axi_arready,
output 	wire   					m_axi_arvalid,
output 	wire [31:0]    				m_axi_araddr,
output 	wire [7:0]     				m_axi_arlen,
output 	wire [2:0]     				m_axi_arsize,
output 	wire [1:0]     				m_axi_arburst,
output 	wire [2:0]				m_axi_arprot,
output 	wire [3:0]				m_axi_arcache,
output 	wire 					m_axi_rready,
input 	wire 					m_axi_rvalid,
input 	wire [(DDR_DATA_WIDTH*4-1):0]		m_axi_rdata,
input 	wire [1:0]				m_axi_rresp,
input 	wire 					m_axi_rlast,
input 						m_axi_awready,
output 	wire 					m_axi_awvalid,
output 	wire [31:0]				m_axi_awaddr,
output 	wire [7:0]				m_axi_awlen,
output 	wire [2:0]				m_axi_awsize,
output 	wire [1:0]				m_axi_awburst,
output 	wire [2:0]				m_axi_awprot,
output 	wire [3:0] 				m_axi_awcache,
input 	wire 					m_axi_wready,
output 	wire 					m_axi_wvalid,
output 	wire [(DDR_DATA_WIDTH*4-1):0]		m_axi_wdata,
output 	wire [7:0]				m_axi_wstrb,
output 	wire 					m_axi_wlast,
output 	wire 					m_axi_bready,
input 	wire 					m_axi_bvalid,
input 	wire [1:0]				m_axi_bresp,

output 	wire 					InterruptToCPU, 
);

//////////////////////////////////////////////////////////
//
// signals 
//
//////////////////////////////////////////////////////////

wire 						ip2bus_mstrd_req;
wire 						ip2bus_mstwr_req;
wire 	[31:0]					ip2bus_mst_addr;
wire 	[19:0] 					ip2bus_mst_length;
wire 	[((DDR_DATA_WIDTH*4)/8-1):0] 		ip2bus_mst_be;
wire 						ip2bus_mst_type;
wire 						ip2bus_mst_lock;
wire 						ip2bus_mst_reset;
wire 						bus2ip_mst_cmdack;
wire 						bus2ip_mst_cmplt;
wire 						bus2ip_mst_error;
wire 						bus2ip_mst_rearbitrate;
wire 						bus2ip_mst_cmd_timeout;
wire 	[(DDR_DATA_WIDTH*4-1):0]			bus2ip_mstrd_d;
wire 	[7:0]					bus2ip_mstrd_rem;
wire 						bus2ip_mstrd_sof_n;
wire 						bus2ip_mstrd_eof_n;
wire 						bus2ip_mstrd_src_rdy_n;
wire 						bus2ip_mstrd_src_dsc_n;
wire 						ip2bus_mstrd_dst_rdy_n;
wire 						ip2bus_mstrd_dst_dsc_n;
wire 	[(DDR_DATA_WIDTH*4-1):0]			ip2bus_mstwr_d;
wire 	[7:0]					ip2bus_mstwr_rem;
wire 						ip2bus_mstwr_sof_n;
wire 						ip2bus_mstwr_eof_n;
wire 						ip2bus_mstwr_src_rdy_n;
wire 						ip2bus_mstwr_src_dsc_n;
wire 						bus2ip_mstwr_dst_rdy_n;
wire 						bus2ip_mstwr_dst_dsc_n;

wire 	[31:0]					InputImageAddress; 
wire 	[31:0] 					OutputImageAddress; 
wire 						BeginRotation;
wire 						RotationDone; 
wire 	[2:0]					RotationType; 
wire 	[4:0]					NumberOf120PixelsBlocks_X; 
wire 	[4:0]					NumberOf120PixelsBlocks_Y; 

wire 	[31:0]					StartPixel_X; 
wire 	[31:0]					StartPixel_Y; 
wire 	[31:0]					NumberOfPixelsPerLine; 



//////////////////////////////////////////////////////////
//
// axi master burst IPIF - this is a hidden IP in the vivado install directory
//
//////////////////////////////////////////////////////////
 



sim_AXIMasterBurstIPIF sim_AXIMasterBurstIPIF_Instance (
.Clk						( m_axi_aclk ), 
.ResetL 					( m_axi_aresetn ),

.ip2bus_mstrd_req          	( ip2bus_mstrd_req       ),  
.ip2bus_mstwr_req          	( ip2bus_mstwr_req       ),  
.ip2bus_mst_addr           	( ip2bus_mst_addr        ),  
.ip2bus_mst_length         	( ip2bus_mst_length      ),  
.ip2bus_mst_be             	( ip2bus_mst_be          ),  
.ip2bus_mst_type           	( ip2bus_mst_type        ),  
.ip2bus_mst_lock           	( ip2bus_mst_lock        ),  
.ip2bus_mst_reset          	( ip2bus_mst_reset       ),  
.bus2ip_mst_cmdack         	( bus2ip_mst_cmdack      ),  
.bus2ip_mst_cmplt          	( bus2ip_mst_cmplt       ),  
.bus2ip_mst_error          	( bus2ip_mst_error       ),  
.bus2ip_mst_rearbitrate    	( bus2ip_mst_rearbitrate ),  
.bus2ip_mst_cmd_timeout    	( bus2ip_mst_cmd_timeout ),  
.bus2ip_mstrd_d            	( bus2ip_mstrd_d         ),  
.bus2ip_mstrd_rem          	( bus2ip_mstrd_rem       ),  
.bus2ip_mstrd_sof_n        	( bus2ip_mstrd_sof_n     ),  
.bus2ip_mstrd_eof_n        	( bus2ip_mstrd_eof_n     ),  
.bus2ip_mstrd_src_rdy_n    	( bus2ip_mstrd_src_rdy_n ),  
.bus2ip_mstrd_src_dsc_n    	( bus2ip_mstrd_src_dsc_n ),  
.ip2bus_mstrd_dst_rdy_n    	( ip2bus_mstrd_dst_rdy_n ),  
.ip2bus_mstrd_dst_dsc_n    	( ip2bus_mstrd_dst_dsc_n ),  
.ip2bus_mstwr_d            	( ip2bus_mstwr_d         ),  
.ip2bus_mstwr_rem          	( ip2bus_mstwr_rem       ),  
.ip2bus_mstwr_sof_n        	( ip2bus_mstwr_sof_n     ),  
.ip2bus_mstwr_eof_n        	( ip2bus_mstwr_eof_n     ),  
.ip2bus_mstwr_src_rdy_n    	( ip2bus_mstwr_src_rdy_n ),  
.ip2bus_mstwr_src_dsc_n    	( ip2bus_mstwr_src_dsc_n ),  
.bus2ip_mstwr_dst_rdy_n    	( bus2ip_mstwr_dst_rdy_n ),  
.bus2ip_mstwr_dst_dsc_n    	( bus2ip_mstwr_dst_dsc_n )  
); 



//////////////////////////////////////////////////////////
//
// Main Controller
//
//////////////////////////////////////////////////////////

ddr_comm_controller #
(
.DDR_DATA_WIDTH(DDR_DATA_WIDTH)
)
ImageRotator_controller_Ins 
(
.clock				( m_axi_aclk ),
//.ILAClk				( ILAClk ), 
.reset				( m_axi_aresetn ),

.ip2bus_mstrd_req          	( ip2bus_mstrd_req       ),  
.ip2bus_mstwr_req          	( ip2bus_mstwr_req       ),  
.ip2bus_mst_addr           	( ip2bus_mst_addr        ),  
.ip2bus_mst_length         	( ip2bus_mst_length      ),  
.ip2bus_mst_be             	( ip2bus_mst_be          ),  
.ip2bus_mst_type           	( ip2bus_mst_type        ),  
.ip2bus_mst_lock           	( ip2bus_mst_lock        ),  
.ip2bus_mst_reset          	( ip2bus_mst_reset       ),  
.bus2ip_mst_cmdack         	( bus2ip_mst_cmdack      ),  
.bus2ip_mst_cmplt          	( bus2ip_mst_cmplt       ),  
.bus2ip_mst_error          	( bus2ip_mst_error       ),  
.bus2ip_mst_rearbitrate    	( bus2ip_mst_rearbitrate ),  
.bus2ip_mst_cmd_timeout    	( bus2ip_mst_cmd_timeout ),  
.bus2ip_mstrd_d            	( bus2ip_mstrd_d         ),  
.bus2ip_mstrd_rem          	( bus2ip_mstrd_rem       ),  
.bus2ip_mstrd_sof_n        	( bus2ip_mstrd_sof_n     ),  
.bus2ip_mstrd_eof_n        	( bus2ip_mstrd_eof_n     ),  
.bus2ip_mstrd_src_rdy_n    	( bus2ip_mstrd_src_rdy_n ),  
.bus2ip_mstrd_src_dsc_n    	( bus2ip_mstrd_src_dsc_n ),  
.ip2bus_mstrd_dst_rdy_n    	( ip2bus_mstrd_dst_rdy_n ),  
.ip2bus_mstrd_dst_dsc_n    	( ip2bus_mstrd_dst_dsc_n ),  
.ip2bus_mstwr_d            	( ip2bus_mstwr_d         ),  
.ip2bus_mstwr_rem          	( ip2bus_mstwr_rem       ),  
.ip2bus_mstwr_sof_n        	( ip2bus_mstwr_sof_n     ),  
.ip2bus_mstwr_eof_n        	( ip2bus_mstwr_eof_n     ),  
.ip2bus_mstwr_src_rdy_n    	( ip2bus_mstwr_src_rdy_n ),  
.ip2bus_mstwr_src_dsc_n    	( ip2bus_mstwr_src_dsc_n ),  
.bus2ip_mstwr_dst_rdy_n    	( bus2ip_mstwr_dst_rdy_n ),  
.bus2ip_mstwr_dst_dsc_n    	( bus2ip_mstwr_dst_dsc_n ),  

// readAddress and writeAddress and BeginOp to be supplied here
); 

endmodule 

`timescale 1ns / 1ps

module sim_AXIMasterBurstIPIF ( 
input wire 			Clk,
input wire 			ResetL,
 
input wire 			ip2bus_mstrd_req,
input wire 			ip2bus_mstwr_req,
input wire [31:0] 	ip2bus_mst_addr,
input wire [19:0] 	ipaus_mst_length,
input wire [7:0] 	ip2bus_mst_be,
input wire 			ip2bus_mst_type,
input wire 			ip2bus_mst_lock,
input wire			ip2bus_mst_reset,
output reg 			ip2bus_mst_cmdack,
output reg 			bus2ip_mst_cmplt,
output reg 			bus2ip_mst_error,
output wire 		bus2ip_mst_rearbitrate,
output wire 		bus2ip_mst_cmd_timeout,
output reg 	[63:0]	bus2ip_mstrd_d,
output wire [7:0] 	bus2ip_mstrd_rem,
output reg 			bus2ip_mstrd_sof_n,
output reg 			bus2ip_mstrd_eof_n,
output reg 			bus2ip_mstrd_src_rdy_n,
output reg 			bus2ip_mstrd_src_dsc_n,
input wire 			ip2bus_mstrd_dst_rdy_n,
input wire 			ip2bus_mstrd dst_dsc_n,
input wire [63:0] 	ip2bus_mstwr_d,
input wire [7:0]	ip2bus_mstwr_rem,
input wire 			ip2bus_mstwr_sof_n,
input wire 			ip2bus_mstwr_eof_e,
input wire 			ip2bus_mstwr_src_rdy_n,
input wire 			ip2bus_mstwr_srt_dsc_n,
output reg 			bus2ip_mstwr_dst_rdy_n,
output wire 		bus2ip_mstwr_dst_dsc_n
); 
 
// make the edged single cycle pulse out of these two 

reg ip2bus_mstrd_reqR; 
reg ip2bus_mstwr_reqR; 
reg ip2bus_mstrd_req_edge; 
reg ip2bus_mstwr_req_edge; 

always @(posedge Clk) 
	if ( ! ResetL ) begin 
	ip2bus_mstrd_reqR <= 0; 
	ip2bus_mstwr_reqR <= 0; 
	ip2bus_mstrd_req_edge <= 0; 
	ip2bus_mstwr_req_edge <= 0; 
	end 
	else begin 
		ip2bus_mstrd_reqR <= ip2bus_mstrd_req; 
		ip2bus_mstwr_reqR <= ip2bus_mstwr_req; 
	if ( (! ip2bus_mstrd_reqR) && ip2bus_mstrd_req ) 
		ip2bus_mstrd_req_edge <= 1; 
	else 
		ip2bus_mstrd_req_edge <= 0; 
	if ((! ip2bus_mstwr_reqR) && ip2bus_mstwr_req ) 
		ip2bus_mstwr_req_edge <= 1; 
	else 
		ip2bus_mstwr_req_edge <= 0; 
end 

`define MASTER_LATENCY 70

reg  [7:0] 	readCounter; 
reg 		readCounterEn; 
reg  [15:0] pixelCounter; 



always @(posedge Clk) 
	if ( ! ResetL ) begin 
		readCounter <= 0; 
		readCounterEn <= 0; 
	end 
	else begin 
	if ( ip2bus_mstrd_req_edge ) begin 
		readCounterEn <= 1; 
		end 
		else if ( readCounter == `MASTER_LATENCY ) begin 
			readCounterEn <= 0; 
			end 

			if ( readCounterEn ) 
				readCounter <= readCounter + 1; 
			else 
				readCounter <= 0; 
	end 
reg bus2ip_mstrd_cmdackR; 
reg bus2ip_mstrd_cmpltR; 

integer fileH; 
integer readStatus; 

initial begin 
	 
	//fileH = $fopen <sample file that simulates the ddr>; 
end 

always @(posedge Clk) 
	if ( ! ResetL ) begin 
		bus2ip_mstrd_cmdackR <= 0; 
		bus2ip_mstrd_cmpltR <= 0; 
		bus2ip_mstrd_sof_n <= 1; 
		bus2ip_mstrd_eof_n <= 1; 
		bus2ip_mstrd_src_rdy_n <= 1; 
		bus2ip_mstrd_d <= 0; 
		 
		end 
		else begin 
			if ( readCounter == 3 ) begin 
				bus2ip_mstrd_cmdackR <= 1; 
				bus2ip_mstrd_cmpltR <= 0; 
				bus2ip_mstrd_sof_n <= 1; 
				bus2ip_mstrd_eof_n <= 1; 
				bus2ip_mstrd_src_rdy_n <= 1; 
				bus2ip_mstrd_d <= 0; 
				end 
				else if ( masterReadTransactionCounter == 4 ) begin 
						bus2ip_mstrd_cmdackR <= 0; 
						bus2ip_mstrd_cmpltR <= 0; 
						bus2ip_mstrd_sof_n <= 1; 
						bus2ip_mstrd_eof_n <= 1; 
						bus2ip_mstrd_src_rdy_n <= 1; 
						bus2ip_mstrd_d <= 0; 
					end 
					else if ( readCounter == 20 ) begin 
						bus2ip_mstrd_cmdackR <= 0; 
						bus2ip_mstrd_cmpltR <= 0; 
						bus2ip_mstrd_sof_n <= 0; 
						bus2ip_mstrd_eof_n <= 1; 
						bus2ip_mstrd_src_rdy_n <= 0; 
					   
					   readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[15:0] );
					   readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[31:16] );
					   readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[47:32] );
					   readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[63:48] );
					   pixelCounter =  pixelCounter + 4;
  


					end 
					else if ( masterReadiransactionCounter == 21 )begin
						bus2ip_mstrd_cmdackR <= 0; 
						bus2ip_mstrd_cmpltR <= 0; 
						bus2ip_mstrd_sof_n <= 1; 
						bus2ip_mstrd_eof_n <= 1; 
						bus2ip_mstrd_src_rdy_n <= 0; 
						
						readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[15:0] );
						readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[31:16] );
						readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[47:32] );
						readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[63:48] );
						pixelCounter =  pixelCounter + 4;
						
						end 
						else if ( (readCounter > 21) && (readCounter < 49) ) begin
							bus2ip_mstrd_cmdackR <= 0; 
							bus2ip_mstrd_cmpltR <= 0; 
							bus2ip_mstrd_sof_n <= 1; 
							bus2ip_mstrd_eof_n <= 1; 
							bus2ip_mstrd_src_rdy_n <= 0; 
						
							readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[15:0] );
							readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[31:16] );
							readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[47:32] );
							readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[63:48] );
							pixelCounter =  pixelCounter + 4;
							end

							else if ( readCounter == 49 ) begin 
								bus2ip_mstrd_cmdackR <= 0; 
								bus2ip_mstrd_cmpltR <= 0; 
								bus2ip_mstrd_sof_n <= 1; 
								bus2ip_mstrd_eof_n <= 0; 
								bus2ip_mstrd_src_rdy_n <= 0; 
								
								readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[15:0] );
								readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[31:16] );
								readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[47:32] );
								readStatus = $fscanf ( fileH, "%h\n", bus2ip_mstrd_d[63:48] );
								pixelCounter =  pixelCounter + 4;
									
							end 
//							

							else if ( nasterReadTransactionCounter == 68 ) begin 
								bus2ip_mstrd_cmdackR <= 0; 
								bus2ip_mstrd_cmpltR <= 0; 
								bus2ip_mstrd_sof_n <= 1; 
								bus2ip_mstrd_eof_n <= 1; 
								bus2ip_mstrd_src_rdy_n <= 1; 
								bus2ip_mstrd_d <= 0; 
								end
								else if ( readCounter == 69 ) begin 
									bus2ip_mstrd_cmdackR <= 0; 
									bus2ip_mstrd_cmpltR <= 0; 
									bus2ip_mstrd_sof_n <= 1; 
									bus2ip_mstrd_eof_n <= 1; 
									bus2ip_mstrd_src_rdy_n <= 1; 
									bus2ip_mstrd_d <= 0;  
									end 
									else begin 
										bus2ip_mstrd_cmdackR <= 0; 
										bus2ip_mstrd_cmpltR <= 0; 
										bus2ip_mstrd_sof_n <= 1; 
										bus2ip_mstrd_eof_n <= 1; 
										bus2ip_mstrd_src_rdy_n <= 1; 
										bus2ip_mstrd_d <= 0; 
									end 
							end
// cmd ack is after after 3 clock cycles
assign bus2ip_mst_cmdack = ( bus2ip_mstrd_cmdackR || bus2ip_mstwr_cmdackR ) ? 1 : 0; 

assign bus2ip_mst_cmplt = (bus2ip_mstrd_cmpltR || bus2ip_mstwr_cmpltR ) ? 1 : 0; 

assign bus2ip_mst_rearbitrate = 0; 
assign bus2ip_mst_cmd_timeout = 0; 
assign bus2ip_mstrd_rem = 0; 
assign bus2ip_mst_error = 0; 


reg [7:0] 	writeCounter; 
reg 		writeCounterEn; 
reg [7:0] 	masterWriteBurstCounter; 

always @ (posedge Clk) 
	if ( ! ResetL ) begin 
	writeCounter <= 0; 
	writeCounterEn <= 0; 
	masterWriteBurstCounter <= 0; 
	end 
	else begin 
		if ( ip2bus_mstwr_req_edge ) begin 
			writeCounterEn <= 1; 
		end 
		else if ( writeCounter == `MASTER_LATENCY ) begin 
			writeCounterEn <= 0; 
			end 
		
		if ( writeCounterEn ) 
			writeCounter <= writeCounter + 1; 
		else 
			writeCounter <= 0; 
		
		if ( ip2bus_mstwr_req_edge ) begin 
			masterWriteBurstCounter <= 0; 
			end
			else begin 
				if ( (!ip2bus_mstwr_src_rdy_n) && (!bus2ip_mstwr_dst_rdy_n) ) 
					masterWriteBurstCounter <= masterWriteBurstCounter + 1; 
				else if ( masterWriteBurstCounter == 30 ) 
					masterWriteBurstCounter <= 0; 
				else 
					masterWriteBurstCounter <= masterWriteBurstCounter; 
				end 
		end 

reg bus2ip_mstwr_cmdackR; 
reg bus2ip_mstwr_cmpltR; 

always @(posedge Clk) 
	if( ! ResetL ) begin 
		bus2ip_mstwr_cmdackR c= 0; 
		bus2ip_mstwr_cmpltR c= 0; 
		end 
		else begin 
			if ( writeCounter == 3 ) begin 
				bus2ip_mstwr_cmdackR <= 1; 
				bus2ip_mstwr_cmpltR <= 0; 
				end 
			else if ( writeCounter == 4 ) begin 
				bus2ip_mstwr_cmdackR <= 0; 
				bus2ip_mstwr_cmpltR <= 0; 
			end 
			else if ( masterwriteTransactionCounter == `MASTER_LATENCY ) begin  
				bus2ip_mstwr_cmdackR <= 0; 
				bus2ip_mstwr_cmpltR <= 1; 
			end 
			else begin 
				bus2ip_mstwr_cmdackR <= 0; 
				bus2ip_mstwr_cmpltR <= 0; 
			end 
	end 

assign bus2ip_mstrd_src_dsc_n = 1; 
assign bus2ip_mstwr_dst_dsc_n = 1; 


////////////////////////////////////////////////////////////////
//
//bus2ip_mstwr_dst_rdy_n
//
///////////////////////////////////////////////////////////////	

reg [3:0] burstCounter; 

always @ (posedge Clk) 
	if ( ! ResetL ) begin 
		bus2ip_mstwr_dst_rdy_n <= 1; 
		burstCounter <= 0;
	end 
	else begin 
		if ( ! ip2bus_mstwr_src_rdy_n ) begin 
			if ( & burstCounter ) 
				bus2ip_mstwr_dst_rdy_n <= 1; 
			else 
				bus2ip_mstwr_dst_rdy_n <= 0; 
			if ( ! bus2ip_mstwr_dst_rdy_n ) 
				burstCounter <= burstCounter + 1; 
			end 
			else begin 
				bus2ip_mstwr_dst_rdy_n <= 1; 
				burstCounter <= 0; 
			end 
	end 
///////////////////////////////////////////////////////////
//
//output data to a file 
//
///////////////////////////////////////////////////////////
integer writeFileH; 
integer writeStatus; 

initial begin 
	
	//writeFileH = $fopen <file to be written to - txt file>
end 

always @(posedge Clk) begin 
	if ( ( ! ip2bus_mstwr_src_rdy_n ) && ( ! bus2ip_mstwr_dst_rdy_n ) ) begin 
		$fwrite ( writeFileH , "%h\n", ip2bus_mstwr_d[15:0] ); 
		$fwrite ( writeFileH , "%h\n", ip2bus_mstwr_d[31:16] ); 
		$fwrite ( writeFileH , "%h\n", ip2bus_mstwr_d[47:32] ); 
		$fwrite ( writeFileH , "%h\n", ip2bus_mstwr_d[63:48] ); 
		 
	end 
end 

endmodule
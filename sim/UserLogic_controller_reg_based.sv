
`include "design_definitions.sv" 

module ddr_comm_controller #
(
//design parameters 
<internal parameter = val>
)
(
input 	wire 								clock,  
input 	wire 								reset, 
output 	reg 								ip2bus_mstrd_req, 
output 	reg 								ip2bus_mstwr_req,
output 	reg 	[31:0]						ip2bus_mst_addr,//address
output 	wire 	[19:0] 						ip2bus_mst_length, //what length eg 256
output 	wire 	[((DDR_DATA_WIDTH*4)/8-1):0] 	ip2bus_mst_be, //which bytes read 
output 	wire 								ip2bus_mst_type, //type - only 1 chuck or large chunk (bit or burst)
output 	wire 								ip2bus_mst_lock,
output 	wire 								ip2bus_mst_reset,
input 	wire 								bus2ip_mst_cmdack,
input 	wire 								bus2ip_mst_cmplt,//complete signal
input 	wire 								bus2ip_mst_error, // user logic to IPIF 
input 	wire 								bus2ip_mst_rearbitrate,
input 	wire 								bus2ip_mst_cmd_timeout,
input 	wire 	[(DDR_DATA_WIDTH*4-1):0]		bus2ip_mstrd_d,
input 	wire 	[7:0]						bus2ip_mstrd_rem,
input 	wire 								bus2ip_mstrd_sof_n, //master read start of frame - bus to user logic - after dst_rdy
input 	wire 								bus2ip_mstrd_eof_n, //enf of frame goes down with final frame
input 	wire 								bus2ip_mstrd_src_rdy_n, // active low when IPIF is providing valid chunk of data
input 	wire 								bus2ip_mstrd_src_dsc_n,
output 	wire 								ip2bus_mstrd_dst_rdy_n, //ready to accept the read data - user logic is always the destination - active low
output 	wire 								ip2bus_mstrd_dst_dsc_n,
output 	reg 	[(DDR_DATA_WIDTH*4-1):0]		ip2bus_mstwr_d, //data to be put on the data bus 
output 	wire 	[7:0]						ip2bus_mstwr_rem,
output 	reg 								ip2bus_mstwr_sof_n, // gets activated with ip2bus_mstwr_d to indicate start
output 	reg 								ip2bus_mstwr_eof_n, //e o frame
output 	reg 								ip2bus_mstwr_src_rdy_n, // active low 
output 	wire 								ip2bus_mstwr_src_dsc_n,
input 	wire 								bus2ip_mstwr_dst_rdy_n, //IPIF brings this down when it is ready - active low
input 	wire 								bus2ip_mstwr_dst_dsc_n,

//readAddress and writeAddress are inputs to this control unit - defined outside this module
//BeginOp is also a single bit input from outside this module
);

localparam BE_WIDTH = (DDR_DATA_WIDTH*4)/8;

reg 	[3:0]		mainFSM_currentState; 
reg		[3:0]		mainFSM_prevState; 

reg		[31:0]		readAddressR; 
reg		[31:0]		writeAddressR; 

always @(posedge clock)
       if ( ! reset ) begin 
	      mainFSM_currentState <= `FSM_IDLE; 
	      mainFSM_prevState <= `FSM_IDLE; 
	      
	      readAddressR <= 0; 
	      writeAddressR <= 0; 
	      
	      opDone <= 0; 
       end 
       else begin 
	      case ( mainFSM_currentState ) 
	      `FSM_IDLE: begin 
	      
		     if ( BeginOp ) begin 
			    readAddressR <= readAddress;
			    writeAddressR <= writeAddress;
			    
			    mainFSM_currentState <= `FSM_RECEIEVE_BLOCK;
			    mainFSM_prevState <= `FSM_IDLE;
		     end 
		     else begin 
			    readAddressR <= readAddressR;
			    writeAddressR <= writeAddressR; 
			    
			    mainFSM_currentState <= `FSM_IDLE;
			    mainFSM_prevState <= `FSM_IDLE; 
		     end
		     
		     opDone <= 0; 
	      end 
	      `FSM_RECEIEVE_BLOCK: begin 
			if ( axiMaster_blockReceived ) begin 
				mainFSM_currentState <= `FSM_SEND_BLOCK;
				mainFSM_prevState <= `FSM_RECEIEVE_BLOCK;
			end 
			else begin 
				mainFSM_currentState <= `FSM_RECEIEVE_BLOCK;
				mainFSM_prevState <= `FSM_RECEIEVE_BLOCK;
			end 
	      end 
	      `FSM_SEND_BLOCK: begin
			if ( axiMaster_blockSent ) begin
					mainFSM_currentState <= `FSM_END_OPERATION;
					mainFSM_prevState <= `FSM_SEND_BLOCK; 
			end
			else begin
				mainFSM_currentState <= `FSM_SEND_BLOCK;
				mainFSM_prevState <= `FSM_SEND_BLOCK;
			end 
	      end 
	      `FSM_END_OPERATION: begin 
			opDone <= 1; 
			
			mainFSM_currentState <= `FSM_IDLE; 
			mainFSM_prevState <= `FSM_END_OPERATION; 
	      end 
	      default: begin 
			mainFSM_currentState <= `FSM_IDLE; 
			mainFSM_prevState <= mainFSM_prevState; 
	      end 
	      endcase 
       end 
	   
	   
/////This implementation is handling just one transfer for now to be put in one register. It could be modified to extend to a complex buffer memory based design.

	   
//////////////////////////////////////////////////////
// 
// axi master - fixed signals
//
//////////////////////////////////////////////////////

assign ip2bus_mst_length = 10;		// length of transaction
assign ip2bus_mst_type = 1; 		// always transfer in bursts. 
assign ip2bus_mst_lock = 0; 
assign ip2bus_mstrd_dst_dsc_n = 1; 	// never discountinue a transfer (master read destination ready) 
assign ip2bus_mstrd_dst_rdy_n = 0; 	// always ready to receive the data (look into this because in your implementation you might wanna halt?)
assign ip2bus_mst_be = {BE_WIDTH{1'b1}};			//8'hff; 		// all of the transferred data is always meaningful
assign ip2bus_mstwr_rem = 0; 
assign ip2bus_mst_reset = 0; 
assign ip2bus_mstwr_src_dsc_n = 1; 	   
	   
	   
////////////////No need for passed pixels and passed lines calculation - handling just one transfer for now	   
//////Just offsets calculated 

wire 	[31:0]	axi_readAddress_offset;
wire 	[31:0]	axi_writeAddress_copy_offset;

	   
assign axi_readAddress_offset = 400; //sample values - change as needed 
assign axi_writeAddress_copy_offset = 400;	   //sample values - change as needed 
	   
	   
//////////////////////////////////////////////////////
// 
// axi master fsm - flow of operations and data to the axi world (IPIF and eventually DRAM)
//
//////////////////////////////////////////////////////
// logic to talk to the axi master ipif

reg 			axiMaster_blockReceived; //indicates if all the reads are done
reg 			axiMaster_blockSent; //indicates if all the writes are done
reg	[4:0]		axiFSM_currentState; //indicated if the IPIF is current in the read or write state
reg	[4:0]		axiFSM_prevState; 
reg	[7:0]		axiFSM_readRequestCounter; 
reg 	[7:0]		axiFSM_writeRequestCounter; 

always @(posedge clock) 
	if ( ! reset ) begin
		axiFSM_currentState <= `AXI_FSM_IDLE; 
		axiFSM_prevState <= `AXI_FSM_IDLE;
		axiMaster_blockReceived <= 0; 
		axiMaster_blockSent <= 0; 
		ip2bus_mstrd_req <= 0; 
		ip2bus_mstwr_req <= 0; 
		ip2bus_mst_addr <= 0;
		axiFSM_readRequestCounter <= 0; 
		axiFSM_writeRequestCounter <= 0; 
	end 
	else begin 
		case ( axiFSM_currentState )
		`AXI_FSM_IDLE : begin 
			if ( (mainFSM_currentState == `FSM_RECEIEVE_BLOCK) && (mainFSM_prevState == `FSM_IDLE) ) begin 
				axiFSM_currentState <= `AXI_FSM_SEND_READ_REQUEST1; 
				axiFSM_prevState <= `AXI_FSM_IDLE; 
				
				axiFSM_readRequestCounter <= 0; 
			end 
			else if ( (mainFSM_currentState == `FSM_RECEIEVE_BLOCK) && (mainFSM_prevState == `FSM_SEND_BLOCK) ) begin 
				axiFSM_currentState <= `AXI_FSM_SEND_READ_REQUEST1; 
				axiFSM_prevState <= `AXI_FSM_IDLE; 
				
				axiFSM_readRequestCounter <= 0; 
			end 
			else if ( (mainFSM_currentState == `FSM_SEND_BLOCK) && (mainFSM_prevState == `FSM_RECEIEVE_BLOCK) ) begin 
				axiFSM_currentState <= `AXI_FSM_SEND_WRITE_REQUEST1; 
				axiFSM_prevState <= `AXI_FSM_IDLE; 
				
				axiFSM_writeRequestCounter <= 0; 
			end 
			else begin 
				axiFSM_currentState <= `AXI_FSM_IDLE; 
				axiFSM_prevState <= `AXI_FSM_IDLE; 
			end 
			
			axiMaster_blockReceived <= 0; 
			axiMaster_blockSent <= 0; 
		end 
		/////////////////////////////////
		// 
		// read req. 
		//
		/////////////////////////////////
		`AXI_FSM_SEND_READ_REQUEST1: begin 
			ip2bus_mstrd_req <= 1; 
			ip2bus_mst_addr <= readAddressR + axi_readAddress_offset; // READ Address generated here
			
			axiFSM_currentState <= `AXI_FSM_WAIT_FOR_READ_ACK1; 
			axiFSM_prevState <= `AXI_FSM_SEND_READ_REQUEST1; 
		end 
		`AXI_FSM_WAIT_FOR_READ_ACK1: begin 
			if ( bus2ip_mst_cmdack ) begin 
				ip2bus_mstrd_req <= 0; 
				
				axiFSM_currentState <= `AXI_FSM_WAIT_FOR_READ_CMPLT1;
				axiFSM_prevState <= `AXI_FSM_WAIT_FOR_READ_ACK1;
			end 
			else begin 
				ip2bus_mstrd_req <= ip2bus_mstrd_req; 
				
				axiFSM_currentState <= `AXI_FSM_WAIT_FOR_READ_ACK1;
				axiFSM_prevState <= `AXI_FSM_WAIT_FOR_READ_ACK1;
			end 
		end 
		`AXI_FSM_WAIT_FOR_READ_CMPLT1: begin 
			if ( bus2ip_mst_cmplt ) begin 
			
				if ( axiFSM_readRequestCounter == 1 ) begin //no. times send and receive is to happen for 1 block
					axiFSM_currentState <= `AXI_FSM_IDLE; 
					axiFSM_prevState <= `AXI_FSM_WAIT_FOR_READ_CMPLT1; 
					
					axiMaster_blockReceived <= 1;
					
				end 
				else begin 	
					axiFSM_currentState <= `AXI_FSM_SEND_READ_REQUEST1; 
					axiFSM_prevState <= `AXI_FSM_WAIT_FOR_READ_CMPLT1; 
					
					axiMaster_blockReceived <= 0; 
					axiFSM_readRequestCounter <= axiFSM_readRequestCounter + 1; //inc. if the block hasnt been received
				end 
			end 
			else begin 
				axiFSM_currentState <= `AXI_FSM_WAIT_FOR_READ_CMPLT1; 
				axiFSM_prevState <= `AXI_FSM_WAIT_FOR_READ_CMPLT1; 
			end 
		end 
		/////////////////////////////////
		// 
		// write req. 1 
		//
		/////////////////////////////////
		`AXI_FSM_SEND_WRITE_REQUEST1: begin 
			ip2bus_mstwr_req <= 1; 
			ip2bus_mst_addr <= writeAddressR + axi_writeAddress_copy_offset;
			
			
			axiFSM_currentState <= `AXI_FSM_WAIT_FOR_WRITE_ACK1; 
			axiFSM_prevState <= `AXI_FSM_SEND_WRITE_REQUEST1; 
		end 
		`AXI_FSM_WAIT_FOR_WRITE_ACK1: begin 
			if ( bus2ip_mst_cmdack ) begin 
				ip2bus_mstwr_req <= 0; 
				
				axiFSM_currentState <= `AXI_FSM_WAIT_FOR_WRITE_CMPLT1; 
				axiFSM_prevState <= `AXI_FSM_WAIT_FOR_WRITE_ACK1; 
			end 
			else begin 
				ip2bus_mstwr_req <= ip2bus_mstwr_req; 
				
				axiFSM_currentState <= `AXI_FSM_WAIT_FOR_WRITE_ACK1; 
				axiFSM_prevState <= `AXI_FSM_WAIT_FOR_WRITE_ACK1; 
			end 	
		end 
		`AXI_FSM_WAIT_FOR_WRITE_CMPLT1: begin 
			if ( bus2ip_mst_cmplt ) begin 
				if ( axiFSM_writeRequestCounter == 1) begin 
					axiFSM_currentState <= `AXI_FSM_IDLE; 
					axiFSM_prevState <= `AXI_FSM_WAIT_FOR_READ_CMPLT1; 
					
					axiMaster_blockSent <= 1; 
				end 
				else begin 
					axiFSM_currentState <= `AXI_FSM_SEND_WRITE_REQUEST1; 
					axiFSM_prevState <= `AXI_FSM_WAIT_FOR_WRITE_CMPLT1;
					
					axiFSM_writeRequestCounter <= axiFSM_writeRequestCounter + 1; 
				end 
			end 
			else begin
				axiFSM_currentState <= `AXI_FSM_WAIT_FOR_WRITE_CMPLT1;
				axiFSM_prevState <= `AXI_FSM_WAIT_FOR_WRITE_CMPLT1;
			end 
		end 
		/////////////////////////////////
		// 
		// default
		//
		/////////////////////////////////
		default : begin 
			axiFSM_currentState <= `AXI_FSM_IDLE; 
			axiFSM_prevState <= `AXI_FSM_IDLE; 
		end
		endcase  
	end 	   
	   
	   
	   
/////Instantiation of buffer memories is not necessary - as we are storing data in a  native register	   
	   
//////////////////////////////////////////////////////
// 
// input data - take data from IPIF and puts in your register
////////////////////////////////////////////////////// 
reg [31:0] data_reg; //this is the register that holds your read value 
	   
	   
always @(posedge clock)
	if ( ! reset ) begin
		data_reg <= 0;
		end
	else begin 
		if ( axiFSM_currentState == `AXI_FSM_IDLE ) begin 
			data_reg <= 0; 
		end 
	else if ( axiFSM_currentState == `AXI_FSM_SEND_READ_REQUEST1 ) begin 
			data_reg <= 0;
		end    
	else if ( axiFSM_currentState == `AXI_FSM_WAIT_FOR_READ_CMPLT1 ) begin 
			if ( ! bus2ip_mstrd_src_rdy_n ) begin 
				data_reg <= bus2ip_mstrd_d; 
			end   
			else begin 
				data_reg <= 0;
			end 
	    end 
		else begin 
			data_reg <= 0; 
		end 
	  end 
	   
//////////////////////////////////////////////////////
// 
// output data - take data from reg and send to IPIF
//////////////////////////////////////////////////////	   
	   
always @(posedge clock) 
	if ( ! reset ) begin 
		 data_reg <= 0;
	end 	   
	else begin 
		if ( axiFSM_currentState == `AXI_FSM_IDLE ) begin 
			 data_reg <= 0;
		end   
	else if ( ( axiFSM_prevState == `AXI_FSM_WAIT_FOR_WRITE_ACK1 ) && bus2ip_mst_cmdack) begin 
			data_reg <= 0;
		end   
	   
	else if  (! ( ( axiFSM_prevState == `AXI_FSM_WAIT_FOR_WRITE_ACK1 ) && ( axiFSM_currentState == `AXI_FSM_WAIT_FOR_WRITE_CMPLT1 ) ) ) begin 	
			data_reg <= 0;
		end    
	   end
	   
   
	   assign burstLength = 1;
	   
	   
always @(posedge clock) 
	if ( ! reset ) begin 
		ip2bus_mstwr_src_rdy_n <= 1;
	end 
	else begin 
		if ( axiFSM_currentState == `AXI_FSM_IDLE ) begin 
			ip2bus_mstwr_src_rdy_n <= 1;
		end 
		else if ( ( axiFSM_currentState == `AXI_FSM_WAIT_FOR_WRITE_CMPLT1 ) ) begin 
			if ( ( ! ip2bus_mstwr_src_rdy_n ) && ( ! bus2ip_mstwr_dst_rdy_n )) begin 
				ip2bus_mstwr_src_rdy_n <= 0; 
			end 
			else begin 
				ip2bus_mstwr_src_rdy_n <= ip2bus_mstwr_src_rdy_n;
			end 
		end 
	end 	   
	   
//////////////////////////////////////////////////////////////////////////////////////////
//
// write start of frame - key signals between user logic and AXI IPIF
//
//////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clock) 
	if ( ! reset ) begin 
		ip2bus_mstwr_sof_n <= 1; 
	end 
	else begin 
		if ( axiFSM_currentState == `AXI_FSM_IDLE ) begin 
			ip2bus_mstwr_sof_n <= 1; 
		end
		else if ( ( axiFSM_currentState == `AXI_FSM_WAIT_FOR_WRITE_CMPLT1 ) ) begin 
			if ( ( ! ip2bus_mstwr_src_rdy_n ) && ( ! bus2ip_mstwr_dst_rdy_n ) ) begin 
				ip2bus_mstwr_sof_n <= 0; 
			end 
			else 
				ip2bus_mstwr_sof_n <= ip2bus_mstwr_sof_n; 
		end 
		else begin 
			ip2bus_mstwr_sof_n <= ip2bus_mstwr_sof_n; 
		end
	end 	   
	   
//////////////////////////////////////////////////////////////////////////////////////////
//
// write end of frame - key signals between user logic and AXI IPIF
//
//////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clock) 
	if ( ! reset ) begin 
		ip2bus_mstwr_eof_n <= 1;
	end 
	else begin 
		if ( axiFSM_currentState == `AXI_FSM_IDLE ) begin 
			ip2bus_mstwr_eof_n <= 1;
		end
		else if ( ( axiFSM_currentState == `AXI_FSM_WAIT_FOR_WRITE_CMPLT1 ) ) begin
			if ( ( ! ip2bus_mstwr_src_rdy_n ) && ( ! bus2ip_mstwr_dst_rdy_n ) ) 
				ip2bus_mstwr_eof_n <= 1;
			
			else 
				ip2bus_mstwr_eof_n <= ip2bus_mstwr_eof_n;
		end 
		else begin 
			ip2bus_mstwr_eof_n <= ip2bus_mstwr_eof_n;
		end 
	end 	   
	   
assign ip2bus_mstwr_d = 10;	 // sample write data 
endmodule
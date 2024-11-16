interface fifomult_bfm;
import fifomult_tb_pkg::*;

	bit           [15:0] data_in;
	bit                  clk;
	bit                  rst_n;
	wire                 data_in_parity_error;
	wire                 busy_out;
	wire                 data_in_parity;
	wire                 data_in_valid;
	wire                 data_out_parity;
	wire                 data_out_valid;
	wire          [31:0] data_out;
	bit par, vaild;
	
	assign data_in_parity = par;
	assign data_in_valid = vaild; 
	


modport tlm (import reset_fifomult);


initial begin : clk_gen_blk
	clk = 0;
	forever begin : clk_frv_blk
		#10;
		clk = ~clk;
	end
end

task reset_fifomult();		
	rst_n = 1'b0;
	@(negedge clk);
	rst_n = 1'b1;
endtask : reset_fifomult



task send_data(input data_in_pckg data_in_t);
	@(negedge clk);
	
	if(busy_out) begin
		@(negedge busy_out);
		@(negedge clk);
	end
	
	data_in 	= data_in_t.A;
	par 	= data_in_t.A_parity;
	vaild 		= 1'b1;  
	
	@(negedge clk);
	vaild = 1'b0;
	
	
	if(busy_out) begin
		@(negedge busy_out);
		@(negedge clk);
	end
		
	data_in 	= data_in_t.B;
	par 		= data_in_t.B_parity;
	vaild 		= 1'b1;  
	
	@(negedge clk);
	vaild 		= 1'b0;
	
	
endtask: send_data


endinterface : fifomult_bfm





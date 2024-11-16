
class tpgen;
	
	protected virtual fifomult_bfm bfm;

    function new (virtual fifomult_bfm b);
        bfm = b;
    endfunction : new
	

	protected function bit[15:0] get_num();

    bit [2:0] zero_ones;

    zero_ones = 3'($random);

    if (zero_ones == 3'b000)
        return 16'h0000;
	else if (zero_ones == 2'b001)
        return 16'h7FFF;
	else if (zero_ones == 3'b010)
        return 16'h7FFF;
	else if (zero_ones == 3'b011)
        return 16'h8000;
	else if (zero_ones == 3'b100)
        return 16'h8000;
    else
        return 16'($random);
    
	endfunction : get_num

	protected function logic wrong_parity(logic signed [15:0] lsArg);
	    logic parity;
	    bit [2:0] zero_ones;
		
	    zero_ones = 3'($random);
		parity = ^lsArg;
		
	    if (zero_ones == 3'b000)
	        return 1'b0;
	
	    else
	        return (parity);
	
	endfunction : wrong_parity

	protected function data_in_pckg get_data(); 
		data_in_pckg data;
		
		data.A = get_num();
		data.B = get_num();
		
		data.A_parity = wrong_parity(data.A);
		data.B_parity = wrong_parity(data.B);
		
		return(data); 
	endfunction: get_data

	task execute(); 
		data_in_pckg data_pckg;
		bfm.reset_fifomult();
		repeat (10000) begin : tpgen_main_blk
			data_pckg     = get_data();
			bfm.send_data(data_pckg);			
		end : tpgen_main_blk
	endtask

endclass : tpgen

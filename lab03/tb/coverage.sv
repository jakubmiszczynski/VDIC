
module coverage(fifomult_bfm bfm);
import fifomult_tb_pkg::*;
	
covergroup corners;
	cp_data_inA : coverpoint bfm.data_in_str.A{
		bins zeros 		= {16'sh0000};
		bins max_pos 	= {16'sh7FFF};
		bins max_neg 	= {16'sh8000};
		bins random 	= default;		
	}
	cp_data_inB : coverpoint bfm.data_in_str.B{
		bins zeros 		= {16'sh0000};
		bins max_pos 	= {16'sh7FFF};
		bins max_neg 	= {16'sh8000};
		bins random 	= default;		
	}
	cp_data_in_valid : coverpoint bfm.data_in_valid{
		bins valid = {1'b1};
		bins not_valid = {1'b0};
	}
	cp_busy_out : coverpoint bfm.busy_out{
		bins busy = {1'b1};
		bins not_busy = {1'b0};
	}	
	cp_parity : coverpoint bfm.data_in_parity{
		bins zero = {1'b0};
		bins one = {1'b1};		
	}
	cp_reset : coverpoint bfm.rst_n{
		bins zero = {1'b0};
		bins one = {1'b1};		
	}
	
	
	cross_data_in_parity_errorA : cross cp_parity, cp_data_inA;
	cross_data_in_parity_errorB : cross cp_parity, cp_data_inB;	
	cross_data_in_AB : cross cp_data_inA, cp_data_inB;
	
endgroup : corners

corners cov_test;

initial begin : coverage
        cov_test     = new();

        forever begin : sample_cov
            @(posedge bfm.clk);
			begin
                cov_test.sample();
                #1ps;
                if($get_coverage() == 100) break; //disable, if needed
            end
        end
    end : coverage

endmodule : coverage






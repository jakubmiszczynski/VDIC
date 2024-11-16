
class coverage;

    protected virtual fifomult_bfm bfm;
    protected bit [15:0] data_in;
	protected bit rst_n;
	protected bit data_in_parity;
	protected bit data_in_valid;
	protected byte cov_ctr;
	
	local bit [15:0] data_in_prev;
	local bit [1:0] data_in_parity_AB;

	
    covergroup cor;

        cp_data_A: coverpoint data_in_prev{
            bins zeros 		= {16'h0000};  
	        bins neg_min 	= {16'h8000};
            bins ones		= {16'hFFFF};
            bins pos_max  	= {16'h7FFF};
			bins random 	= default;
	        	        
        }
        
        cp_data_B: coverpoint data_in{
            bins zeros 		= {16'h0000};  
	        bins neg_min 	= {16'h8000};
            bins pos_max  	= {16'h7FFF};
	        bins random 	= default;
	        
        }
        
        cp_reset: coverpoint rst_n{
	        bins reset_off 	= {1'b0};
	        bins reset_on	= {1'b0};
        }  
        
        cb_data_parity: coverpoint data_in_parity_AB{
	        bins cor_cor 	= {2'b11};
	        bins cor_bad 	= {2'b10};
	        bins bad_cor 	= {2'b01};
	        bins bad_bad 	= {2'b00};
        }

        cp_data_in_valid : coverpoint data_in_valid{
			bins valid 		= {1'b1};
			bins not_valid 	= {1'b0};
        }
     
    endgroup
          

    function new (virtual fifomult_bfm b);
	    bfm     = b;
        cor = new();
    endfunction : new
    
    
    task execute();    
        forever begin : sample_cov
            @(posedge bfm.clk);			
				if(!bfm.rst_n) begin
		            cov_ctr = 0;
		           	rst_n = bfm.rst_n;
		            cor.sample();
	            end
	            else if(bfm.data_in_valid ===1'b1 && cov_ctr == 0) begin
		            data_in_prev = bfm.data_in;
		            data_in_valid = bfm.data_in_valid;
		            data_in_parity_AB[1] = (bfm.data_in_parity == ^bfm.data_in);
	            	cor.sample();
		            cov_ctr = 1;
	            end
	            else if(bfm.data_in_valid ===1'b1 && cov_ctr == 1) begin
		            data_in_parity_AB[0] = (bfm.data_in_parity == ^bfm.data_in);
		           	data_in_valid = bfm.data_in_valid;
		            data_in = bfm.data_in;
	            	cor.sample();
		            cov_ctr = 0;
	            end
	            
			cor.sample();	
	            
                #1;
	            
                if($get_coverage() == 100) begin
	                $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
	                break; 
	            end    	
        end
    endtask 

endclass: coverage


class scoreboard;
	
	protected typedef enum bit {
		TEST_PASSED,
		TEST_FAILED
	} test_result_t;
			
	protected typedef enum {
		COLOR_BOLD_BLACK_ON_GREEN,
		COLOR_BOLD_BLACK_ON_RED,
		COLOR_BOLD_BLACK_ON_YELLOW,
		COLOR_BOLD_BLUE_ON_WHITE,
		COLOR_BLUE_ON_WHITE,
		COLOR_DEFAULT
	} print_color_t;
	
	protected typedef struct packed{
		bit signed [31:0] 	data_out;
		bit 			  	data_out_parity;
		bit 				di_par_err;
	} data_out_pckg;

	local virtual fifomult_bfm bfm;
	
	local test_result_t 	test_result  = TEST_PASSED;
	local data_in_pckg      data_in_q   [$]; 
	local data_in_pckg	    buffor_t; 
	local bit data_in_valid_cntr = 1'b0;  
	
	function new (virtual fifomult_bfm b);
        bfm = b;
    endfunction : new		
			
			
	local function data_out_pckg get_exp(data_in_pckg data_in_t);
		
		data_out_pckg data_out_t;

		data_out_t.di_par_err = ~(( data_in_t.A_parity == ^ data_in_t.A) & 
								  ( data_in_t.B_parity == ^ data_in_t.B)); 
		
		if (data_out_t.di_par_err == 1'b1) begin
			data_out_t.data_out 		= data_in_t.A * data_in_t.B;  
			data_out_t.data_out_parity 	= ^data_out_t.data_out;	
		end	
		
		if (data_out_t.di_par_err == 1'b0) begin	
			data_out_t.data_out 		= data_in_t.A * data_in_t.B;
			data_out_t.data_out_parity 	= ^data_out_t.data_out;
		end	
		
		else begin
			 $display("Hello from get_exp");
		end
		
		return(data_out_t);
		
	endfunction : get_exp
	
	

	local task store_cmd();    
	    forever begin:scoreboard_fe_blk
	        @(posedge bfm.clk or negedge bfm.rst_n);
		    if(!bfm.rst_n) begin
			    data_in_valid_cntr 	= 1'b0;
			    
			    data_in_q.delete();
		    end
		 
		    if(bfm.data_in_valid === 1'b1 && data_in_valid_cntr == 1'b1)begin 
			    buffor_t.B 			= bfm.data_in;
			    buffor_t.B_parity 	= bfm.data_in_parity;     
	        	data_in_valid_cntr 	= 1'b0;	
			    
			   data_in_q.push_front(buffor_t);  
		    end
		    
		    else if(bfm.data_in_valid === 1'b1 && data_in_valid_cntr == 1'b0)begin 
			    buffor_t.A 			= bfm.data_in;
			    buffor_t.A_parity 	= bfm.data_in_parity;       
	        	data_in_valid_cntr 	= 1'b1; 
		    end    
			   
		    
	    end
	endtask
	    
	local task process_data();
		forever begin: scoreboard_be_blk
			
	        data_out_pckg data_out_exp_t;
			data_in_pckg data_in_process_t;
			
	        @(negedge bfm.clk);
		    if(bfm.data_out_valid == 1 && bfm.rst_n == 1) begin   

	            data_in_process_t= data_in_q.pop_back();    
	            data_out_exp_t = get_exp(data_in_process_t);
			    
	            if ({	bfm.data_out, 
		            	bfm.data_out_parity, 
		            	bfm.data_in_parity_error} == data_out_exp_t) begin
			            	
	                $display("Test passed for A=%0d B=%0d, parA=%0d parB=%0d", data_in_process_t.A, data_in_process_t.B, data_in_process_t.A_parity, data_in_process_t.B_parity);
		            	end
		            	
	            else begin
		            test_result = TEST_FAILED;
	                $error("Test failed ");
					end;
	
	        end
	    end : scoreboard_be_blk
	endtask
	    
	task execute();
        fork
            store_cmd();
            process_data();
        join_none
    endtask
	
	local function void set_print_color ( print_color_t c );
		string ctl;
		case(c)
			COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
			COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
			COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
			COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
			COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
			COLOR_DEFAULT : ctl              = "\033\[0m\n";
			default : begin
				$error("set_print_color: bad argument");
				ctl                          = "";
			end
		endcase
		$write(ctl);
	endfunction
	
	local function void print_test_result (test_result_t r);
		if(r == TEST_PASSED) begin
			set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
			$write ("-----------------------------------\n");
			$write ("----------- Test PASSED -----------\n");
			$write ("-----------------------------------");
			set_print_color(COLOR_DEFAULT);
			$write ("\n");
		end
		else begin
			set_print_color(COLOR_BOLD_BLACK_ON_RED);
			$write ("-----------------------------------\n");
			$write ("----------- Test FAILED -----------\n");
			$write ("-----------------------------------");
			set_print_color(COLOR_DEFAULT);
			$write ("\n");
		end
	endfunction

	function void print_result();
        print_test_result(test_result);
    endfunction

endclass: scoreboard

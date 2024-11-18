/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
class scoreboard extends uvm_component;
    `uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// local typedefs
//------------------------------------------------------------------------------
    protected typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result;

	
	protected typedef struct packed{
		bit signed [31:0] 	data_out;
		bit 			  	data_out_parity;
		bit 				di_par_err;
	} data_out_pckg;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual fifomult_bfm bfm;
    protected test_result tr = TEST_PASSED; // the result of the current test

    // fifo for storing input and expected data
	local data_in_pckg      data_in_q   [$]; 
	local data_in_pckg	    buffor_t; 
	local bit data_in_valid_cntr = 1'b0;  

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

			
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

//------------------------------------------------------------------------------
// local tasks
//------------------------------------------------------------------------------
    protected task store_cmd();
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

    protected task process_data_from_dut();
        forever begin : scoreboard_be_blk
			
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
		            tr = TEST_FAILED;
	                $error("Test failed ");
					end;
	
	        end
	    end : scoreboard_be_blk
    endtask

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual fifomult_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        fork
            store_cmd();
            process_data_from_dut();
        join_none
    endtask : run_phase

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
    protected function void print_test_result (test_result r);
        if(tr == TEST_PASSED) begin
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

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

endclass : scoreboard
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
class coverage extends uvm_component;
    `uvm_component_utils(coverage)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual fifomult_bfm bfm;

    protected bit [15:0] data_in;
	protected bit rst_n;
	protected bit data_in_parity;
	protected bit data_in_valid;
	protected byte cov_ctr;
	
	local bit [15:0] data_in_prev;
	local bit [1:0] data_in_parity_AB;

//------------------------------------------------------------------------------
// covergroups
//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
        cor               = new();
    endfunction : new

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
        forever begin : sampling_block
            @(negedge bfm.clk);
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
        end : sampling_block
    endtask : run_phase


endclass : coverage







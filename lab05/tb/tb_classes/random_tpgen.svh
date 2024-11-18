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
class random_tpgen extends base_tpgen;
    `uvm_component_utils (random_tpgen)
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// function: get_data - generate random data for the tpgen
//------------------------------------------------------------------------------
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

endclass : random_tpgen







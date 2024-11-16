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
 
 Last modification: 2024-10-22 AGH RSz
 */
interface fifomult_bfm;
import fifomult_tb_pkg::*;

bit                  clk;
bit                  rst_n;		
	
bit          [15:0] data_in;
bit           		data_in_parity;
bit                 data_in_valid; 

wire				busy_out;
wire         [31:0] data_out;
wire				data_out_parity;
wire				data_out_valid;	
wire				data_in_parity_error;

bit send_busy;
bit signed [31:0] 	res_rel_q [$];
bit signed  		par_err_q [$];
st_data_in_packet_t data_in_q [$];
st_data_in_packet_t data_in_str;
	
modport tlm (import reset_fifomult, check_parity, exp, wrong_parity, send_data,send_nothing, send_data_busy_test);
    
//------------------------------------------------------------------------------
// clock generator  
//------------------------------------------------------------------------------
initial begin
    clk = 0;
    forever begin
        #10;
        clk = ~clk;
    end
end


task reset_fifomult();
    `ifdef DEBUG
    $display("%0t DEBUG: reset_fifomult", $time);
    `endif
    rst_n = 1'b0;
    @(negedge clk);
    rst_n = 1'b1;
endtask : reset_fifomult

function logic check_parity(logic signed [15:0] lsArg);
	logic parity;
	parity = ^lsArg;
	return(parity);
endfunction : check_parity

function int exp(bit signed [15:0] A, bit signed [15:0] B);
	bit signed [31:0] res;
	res = A*B;
	return(res);
endfunction : exp

function logic wrong_parity(logic signed [15:0] lsArg);
    logic parity;
    bit [2:0] zero_ones;
	
    zero_ones = 3'($random);
	parity = ^lsArg;
	
    if (zero_ones == 3'b000)
        return 1'b0;

    else
        return (parity);

endfunction : wrong_parity

function bit[15:0] get_data();

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
    
endfunction : get_data

task send_data();
		
	begin
		
		data_in_str.A = get_data();
		data_in_str.A_parity = wrong_parity(data_in_str.A);
	    data_in_str.B = get_data();
		data_in_str.B_parity = wrong_parity(data_in_str.B);
		data_in_str.exp = data_in_str.A * data_in_str.B;
		send_busy = 0;
		if(check_parity(data_in_str.A)==data_in_str.A_parity)begin
			data_in_str.A_parity_chk = OK;	
		end
		else begin
			data_in_str.A_parity_chk = NOT_OK;
		end
		if(check_parity(data_in_str.B)==data_in_str.B_parity)begin
			data_in_str.B_parity_chk = OK;	
		end
		else begin
			data_in_str.B_parity_chk = NOT_OK;
		end
		
		
		data_in_q.push_front(data_in_str);
  

	    @(negedge clk);
	    data_in = data_in_str.A;
	    data_in_parity = data_in_str.A_parity;
	    data_in_valid = 1'b1;
	    @(negedge clk);
	    data_in_valid = 1'b0;
	    

	    @(negedge clk);
	    data_in = data_in_str.B;
	    data_in_parity = data_in_str.B_parity;
	    data_in_valid = 1'b1;
	    @(negedge clk);
	    data_in_valid = 1'b0; 
	end
	
endtask : send_data

task send_nothing();
	@(negedge clk);
endtask

task send_data_busy_test();
	bit signed [15:0] A;
	bit signed [15:0] B;
	send_busy = 1;
	begin
	
		A = get_data();
	    B = get_data();

		if (busy_out == 0)begin
	    	@(negedge clk);
	    	data_in = A;
	    	data_in_parity = check_parity(A);
	    	data_in_valid = 1'b1;
		end

	    
		if (busy_out == 0)begin
		    @(negedge clk);
		    data_in = B;
		    data_in_parity =  check_parity(B);
		    data_in_valid = 1'b1;
		end
	end
	
endtask : send_data_busy_test

endinterface : fifomult_bfm



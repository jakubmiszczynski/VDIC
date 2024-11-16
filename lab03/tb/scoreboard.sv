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
 NOTE: scoreboard uses bfm signals directly - this is a temporary solution
 */

module scoreboard(fifomult_bfm bfm);

import fifomult_tb_pkg::*;

//------------------------------------------------------------------------------
// local typdefs
//------------------------------------------------------------------------------
typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
bit busy_res;
test_result_t    test_result = TEST_PASSED;



always @(negedge bfm.clk) begin : scoreboard_fe_blk
	
		if(bfm.data_out_valid ==1 & bfm.send_busy ==0)begin
			bfm.res_rel_q.push_front(bfm.data_out);
			bfm.par_err_q.push_front(bfm.data_in_parity_error);			
		end
		if(bfm.busy_out ==1 & bfm.send_busy == 1)begin
			busy_res <= 1;		
		end
end

always @(posedge bfm.clk) begin : scoreboard_be_blk
	
	bit signed [31:0] result_srb;
	bit  par_err_srb;
	int busy_c;
	
	st_data_in_packet_t data_in_q_srb;

		if(bfm.data_out_valid ==1 & bfm.res_rel_q.size() == 1 & bfm.send_busy ==0)begin
						
			data_in_q_srb 	= bfm.data_in_q.pop_back();
			
			result_srb 		= bfm.res_rel_q.pop_back();
			par_err_srb		= bfm.par_err_q.pop_back();
			
			if(	result_srb 	== 	data_in_q_srb.exp 	& 
			   	data_in_q_srb.A_parity_chk == OK 	&
			   	data_in_q_srb.B_parity_chk == OK 	&
			   	par_err_srb == 1'b0 		)
			begin
                $display("%0t Test passed for A=%0h B=%0h", $time, data_in_q_srb.A, data_in_q_srb.B);
			end
			
			else if(	result_srb 	== 	data_in_q_srb.exp 	& 
					par_err_srb == 1'b1 &
			   	(data_in_q_srb.A_parity_chk == NOT_OK || data_in_q_srb.B_parity_chk == NOT_OK))
			begin
                $display("%0t Test passed with 1 parity error for A=%0h B=%0h", $time, data_in_q_srb.A, data_in_q_srb.B);
			end
			   		
			else if(	result_srb 	== 	data_in_q_srb.exp 	& 
						par_err_srb == 1'b1 &
			   	   (	data_in_q_srb.A_parity_chk == NOT_OK & data_in_q_srb.B_parity_chk == NOT_OK))
			begin
                $display("%0t Test passed with 2 parity error for A=%0h B=%0h", $time, data_in_q_srb.A, data_in_q_srb.B);
			end
			
            else begin
                test_result = TEST_FAILED;
                $error("%0t Test FAILED for A=%0h B=%0h A_par=%0d B_par=%0d, Achk=%0d, Bchk=%0d, exp=%0h, rel_out=%0h, relpar=%0h,", $time, data_in_q_srb.A, data_in_q_srb.B, data_in_q_srb.A_parity, data_in_q_srb.B_parity, data_in_q_srb.A_parity_chk, data_in_q_srb.B_parity_chk, data_in_q_srb.exp, result_srb, par_err_srb);
	            //$error("%0t more data for A=%0h B=%0h A_par=%0h B_par=%0h B_par_rel=%0h B_par_rel=%0h", $time, A_srb, B_srb, A_par_srb, B_par_srb, check_parity(A_srb), check_parity(B_srb));

            end;
		end
		else if (bfm.send_busy == 1)begin
			if (busy_res ==1)begin
				$display("%0t Test PASSED after %d clk", $time,busy_c);
			end
			else if (busy_c > 500)begin
				 test_result = TEST_FAILED;
                $error(" Test FAILED after busy_c = 500");
			end
			else begin
                $display("%0t Waiting for busy_out", $time,);
				busy_c++;
			end

		end
end

//------------------------------------------------------------------------------

final begin : finish_of_the_test
    print_test_result(test_result);
end

function void set_print_color ( print_color_t c );
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

function void print_test_result (test_result_t r);
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


endmodule : scoreboard







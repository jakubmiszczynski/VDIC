
module top;

typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

typedef enum bit {
    OK,
    NOT_OK
} parity_t;


typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;
	
typedef struct {
	bit signed [15:0] A;
	bit A_parity;
	bit signed [15:0] B;
	bit B_parity;
	bit signed [31:0] exp;
	parity_t A_parity_chk;
	parity_t B_parity_chk;
} st_data_in_packet_t;
	

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

	
test_result_t        test_result = TEST_PASSED;

bit signed [31:0] 	res_rel_q [$];
bit signed  		par_err_q [$];
st_data_in_packet_t data_in_q [$];
st_data_in_packet_t data_in_str;

fifomult2024 DUT (.clk, .rst_n, .data_in, .data_in_parity, .data_in_valid, .busy_out, .data_out, .data_out_parity, .data_out_valid, .data_in_parity_error);


covergroup corners;
	cp_data_inA : coverpoint data_in_str.A{
		bins zeros 		= {16'sh0000};
		bins max_pos 	= {16'sh7FFF};
		bins max_neg 	= {16'sh8000};
		bins random 	= default;		
	}
	cp_data_inB : coverpoint data_in_str.B{
		bins zeros 		= {16'sh0000};
		bins max_pos 	= {16'sh7FFF};
		bins max_neg 	= {16'sh8000};
		bins random 	= default;		
	}
	cp_data_in_valid : coverpoint data_in_valid{
		bins valid = {1'b1};
		bins not_valid = {1'b0};
	}
	cp_busy_out : coverpoint busy_out{
		bins busy = {1'b1};
		bins not_busy = {1'b0};
	}	
	cp_parity : coverpoint data_in_parity{
		bins zero = {1'b0};
		bins one = {1'b1};		
	}
	cp_reset : coverpoint rst_n{
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
            @(posedge clk);
			begin
                cov_test.sample();
                #1step;
                if($get_coverage() == 100) break; //disable, if needed
            end
        end
    end : coverage

initial begin : clk_gen_blk
    clk = 0;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end

initial begin
    longint clk_counter;
    clk_counter = 0;
    forever begin
        @(posedge clk) clk_counter++;
        if(clk_counter % 1000 == 0) begin
            $display("%0t Clock cycles elapsed: %0h", $time, clk_counter);
        end
    end
end

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

initial begin : tpgen
	parameter N = 100;
	reset_fifomult();

	repeat (N) begin
	    begin
		    send_data();
	    end
	end

    $finish;
end : tpgen

always @(negedge clk) begin : scoreboard_fe_blk
	
		if(data_out_valid ==1)begin
			res_rel_q.push_front(data_out);
			par_err_q.push_front(data_in_parity_error);
			
		end
end

always @(posedge clk) begin : scoreboard_be_blk
	
	bit signed [31:0] result_srb;
	bit  par_err_srb;
	
	st_data_in_packet_t data_in_q_srb;

		if(data_out_valid ==1 & res_rel_q.size() == 1)begin
						
			data_in_q_srb 	= data_in_q.pop_back();
			
			result_srb 		= res_rel_q.pop_back();
			par_err_srb		= par_err_q.pop_back();
			
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
end

task send_data();
		
	begin
	
		data_in_str.A = get_data();
		data_in_str.A_parity = wrong_parity(data_in_str.A);
	    data_in_str.B = get_data();
		data_in_str.B_parity = wrong_parity(data_in_str.B);
		data_in_str.exp = data_in_str.A * data_in_str.B;
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

		
		if (busy_out !== 1'b0)begin
			$display("%0t FAILED busy_out=1", $time);
	    	test_result = TEST_FAILED;
		end    

	    @(negedge clk);
	    data_in = data_in_str.A;
	    data_in_parity = data_in_str.A_parity;
	    data_in_valid = 1'b1;
	    @(negedge clk);
	    data_in_valid = 1'b0;
	    
	    if (busy_out !== 1'b0)begin
		    $display("%0t FAILED busy_out=1", $time);
	    	test_result = TEST_FAILED;
	    end
	    
	    @(negedge clk);
	    data_in = data_in_str.B;
	    data_in_parity = data_in_str.B_parity;
	    data_in_valid = 1'b1;
	    @(negedge clk);
	    data_in_valid = 1'b0; 
	end
	
endtask : send_data
	
	
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

endmodule : top

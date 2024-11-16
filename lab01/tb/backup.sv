
module top;

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

fifomult2024 DUT (.clk, .rst_n, .data_in, .data_in_parity, .data_in_valid, .busy_out, .data_out, .data_out_parity, .data_out_valid, .data_in_parity_error);

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
            $display("%0t Clock cycles elapsed: %0d", $time, clk_counter);
        end
    end
end

function byte get_data();

    bit [2:0] zero_ones;

    zero_ones = 3'($random);

    if 		(zero_ones == 3'b000)
        return 16'h0000;
	else if (zero_ones == 3'b001)
        return 16'h7FFF;
	else if (zero_ones == 3'b100)
        return 16'h8000;
    else if (zero_ones == 3'b111)
        return 16'hFFFF;
    else
        return 16'($random);
    
endfunction : get_data

parameter N = 10;
bit signed [N-1:0][15:0] A_arr;
bit signed [N-1:0][15:0] B_arr;
bit signed [N-1:0][31:0] exp_res_arr;

initial begin : tpgen

	bit signed [15:0] A_t2, B_t2;
	bit signed [31:0] expected_result_t2;

	/*
	//---------------TEST 1------------------------	
	begin : test1
		$display("%0t Start test 1", $time);
	    reset_fifomult();
	    if (busy_out !== 1'b0 || data_out_valid !== 1'b0 || data_out !== 32'b0) begin
		    $display("%0t test 1 faild", $time);
		    test_result = TEST_FAILED;
	    end
	    else begin
		    $display("%0t  test 1 pass", $time);
	    end
	end : test1
    */
    //---------------TEST 2------------------------
	repeat (N) begin
	    begin : test2
			$display("%0t Start test 2", $time);
		  
		    send_data(A_t2, B_t2, expected_result_t2);
		    A_arr [N] = A_t2;
		    B_arr [N] = B_t2;
		    exp_res_arr [N] = expected_result_t2;
		    
 	    	@(posedge data_out_valid);
		    //$display("%0t Multi num: %d %d", $time, A_t2, B_t2);
		    if(data_out !== expected_result_t2) begin 
				$display("%0t Test 2 Incorrect result Expected: %d got %d", $time, expected_result_t2, data_out);
			    test_result = TEST_FAILED;
			end
			else if(data_out_parity !== check_parity(data_out)) begin 
				$display("%0t Test 2 Incorrect result parity data_out", $time);
			    test_result = TEST_FAILED;
			end
			else if(data_out_parity !== check_parity(expected_result_t2)) begin 
				$display("%0t Test 2 Incorrect result parity expected_result_t2", $time);
			    test_result = TEST_FAILED;
			end
			else begin
				$display("%0t Test 2  PASSED", $time);
			end
	    end : test2
    
	end
	
    //---------------TEST 3------------------------
    begin : test3
	$display("%0t Start test 3", $time);   
	
	send_data(A_t2, B_t2, expected_result_t2);
	 @(posedge data_out_valid);
	 @(negedge clk);
	    #5
	    rst_n = 1'b0;
	    #5
	    if(busy_out !== 0 || data_out_valid !== 0 || data_out !== 0)begin : ifseq
			$display("%0t Test 3 Reset not work", $time);  
		    test_result = TEST_FAILED;
	    end : ifseq
	    	
	    else begin
		    $display("%0t Test 3 PASS", $time);  
		end
	    
	    rst_n = 1'b1;
	    
    end : test3 
    
    //---------------TEST 4------------------------  
    begin : test4
	$display("%0t Start test 4", $time);   
	
	send_data(A_t2, B_t2, expected_result_t2);
	 @(posedge data_out_valid);
	    #5
	    rst_n = 1'b0;
	    #5
	    if(busy_out !== 0 || data_out_valid !== 0 || data_out !== 0)begin : ifseq
			$display("%0t Test 4 Reset not work", $time);  
		    test_result = TEST_FAILED;
	    end : ifseq
	    	
	    else begin
		    $display("%0t Test 4 PASS", $time);  
		end
	    
	    rst_n = 1'b1;
	    
    end : test4 
    
    //---------------TEST 5------------------------  
    begin : test5
	$display("%0t Start test 4", $time);   
	
	send_data(A_t2, B_t2, expected_result_t2);	 
	    #5
	    rst_n = 1'b0;
	    #5
	    if(busy_out !== 0 || data_out_valid !== 0 || data_out !== 0)begin : ifseq
			$display("%0t Test 5 Reset not work", $time);  
		    test_result = TEST_FAILED;
	    end : ifseq
	    	
	    else begin
		    $display("%0t Test 5 PASS", $time);  
		end
	    
	    rst_n = 1'b1;
	    
    end : test5 
    
    //---------------TEST 6------------------------

    
    $finish;
end : tpgen


task send_data_wrong_par();
	bit signed [15:0] A, B;

	output signed [15:0] A_out;
	output signed [15:0] B_out;
	output signed [31:0] expected_result_out;

	
	begin
		
		A = get_data();
	    B = get_data();
		
		if (busy_out !== 1'b0)begin
			$display("%0t FAILED busy_out=1", $time);
	    	test_result = TEST_FAILED;
		end    

	    @(negedge clk);
	    data_in = A;
	    data_in_parity = wrong_parity();
	    data_in_valid = 1'b1;
	    @(negedge clk);
		data_in = 1'b0;
	    data_in_valid = 1'b0;
	    
	    if (busy_out !== 1'b0)begin
		    $display("%0t FAILED busy_out=1", $time);
	    	test_result = TEST_FAILED;
	    end
	    
	    @(negedge clk);
	    data_in = B;
	    data_in_parity = wrong_parity();
	    data_in_valid = 1'b1;
	    @(negedge clk);
	    data_in_valid = 1'b0; 
	    data_in = 1'b0;
	    
	    A_out = A;
	    B_out = B;
	    expected_result_out = A*B;
	end
	
endtask : send_data_wrong_par
	
task send_data();
	bit signed [15:0] A, B;

	output signed [15:0] A_out;
	output signed [15:0] B_out;
	output signed [31:0] expected_result_out;

	
	begin
		
		A = get_data();
	    B = get_data();
		
		if (busy_out !== 1'b0)begin
			$display("%0t FAILED busy_out=1", $time);
	    	test_result = TEST_FAILED;
		end    

	    @(negedge clk);
	    data_in = A;
	    data_in_parity = check_parity(A);
	    data_in_valid = 1'b1;
	    @(negedge clk);
		data_in = 1'b0;
	    data_in_valid = 1'b0;
	    
	    if (busy_out !== 1'b0)begin
		    $display("%0t FAILED busy_out=1", $time);
	    	test_result = TEST_FAILED;
	    end
	    
	    @(negedge clk);
	    data_in = B;
	    data_in_parity = check_parity(B);
	    data_in_valid = 1'b1;
	    @(negedge clk);
	    data_in_valid = 1'b0; 
	    data_in = 1'b0;
	    
	    A_out = A;
	    B_out = B;
	    expected_result_out = A*B;
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

function logic wrong_parity();
	bit parity;
	parity = 1'($random);
	return(parity);
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

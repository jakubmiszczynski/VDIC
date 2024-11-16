
module top;
import fifomult_tb_pkg::*;

fifomult2024 DUT (	.clk(bfm.clk), .rst_n(bfm.rst_n), .data_in(bfm.data_in), .data_in_parity(bfm.data_in_parity), 
					.data_in_valid(bfm.data_in_valid), .busy_out(bfm.busy_out), .data_out(bfm.data_out), 
					.data_out_parity(bfm.data_out_parity), .data_out_valid(bfm.data_out_valid), .data_in_parity_error(bfm.data_in_parity_error));


fifomult_bfm bfm();

testbench testbench_h;

initial begin
    testbench_h = new(bfm);
    testbench_h.execute();
    $finish;
end


endmodule 
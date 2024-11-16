 
package fifomult_tb_pkg;
	 
	 	
typedef struct packed
{
	bit signed [15:0] 	A;
	bit					A_parity;
	bit signed [15:0] 	B;
	bit 				B_parity;
} data_in_pckg;
	 
`include "coverage.svh"
`include "tpgen.svh"
`include "scoreboard.svh"
`include "testbench.svh"

endpackage
 
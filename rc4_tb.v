/* 
	RC4 PRGA Testbench 
	Copyright 2012 - Alfredo Ortega
	aortega@alu.itba.edu.ar

 This library is free software: you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation, either
 version 3 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

`define RC4


`ifndef TEST_CYCLES
`define TEST_CYCLES 2000
`endif

`include "rc4.inc"

module rc4_tb;

reg [7:0] password[0:`KEY_SIZE-1];

parameter tck = 10, program_cycles = `TEST_CYCLES;


reg clk, rst; // clock, reset
wire output_ready; // output ready (valid)

wire [7:0] K; // output
reg [7:0] password_input; //input
//wire [7:0] Kreg; // output

//assign Kreg=K;
/* Clocking device */
always #(tck/2) 
	clk = ~clk;

integer clkcount;
always @ (posedge clk)
	begin
	clkcount<=clkcount+1;
	if (clkcount < `KEY_SIZE)
		begin
		password_input<=password[clkcount];
		$display ("--- clk %d --- key[%x] = %08X",clkcount,clkcount,password[clkcount]);
		end
	else $display ("--- clk %d --- K %08X",clkcount,K);
	end


/* rc4 module implementation */
rc4 rc4mod(
	.clk(clk),
	.rst(rst),
	.password_input(password_input),
	.output_ready(output_ready),
	.K(K)
);


/* Simulation */
integer q;
initial begin
	for (q=0; q<`KEY_SIZE; q=q+1) password[q] = 8'h42; // initialize Key
	$display ("Start...");
	clk = 0;
	rst = 1;
	clkcount =0;
	password_input=password[clkcount];
	#(1*tck) 
	rst = 0;
	#(program_cycles*tck+100) 
	$display ("Finish.");
	$finish;
end


endmodule

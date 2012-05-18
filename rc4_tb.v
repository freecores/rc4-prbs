/* RC4 PRGA Testbench */

`define RC4


`ifndef TEST_CYCLES
`define TEST_CYCLES 2000
`endif

`define KEY_SIZE 8

module rc4;
endmodule

module rc4_tb;


parameter tck = 10, program_cycles = `TEST_CYCLES;


reg clk, rst; // clock, reset



/* Clocking device */
always #(tck/2) 
	clk = ~clk;

integer clkcount=0;
always @ (posedge clk)
	begin
	clkcount=clkcount+1;
		$display ("--- clk %d ---",clkcount);
	end

/* RC4 PRGA */

// S array
reg [7:0] S[0:256];
// Key
reg [7:0] key[0:`KEY_SIZE-1];

// Key-scheduling state
`define KSS_KEYSCHED1 4'h1
`define KSS_KEYSCHED2 4'h2
`define KSS_KEYSCHED3 4'h3
`define KSS_CRYPTO 4'h4

// Variable names from http://en.wikipedia.org/wiki/RC4
reg [3:0] KSState;
reg [7:0] i; // Counter
reg [7:0] j;
reg [7:0] temp;
reg [7:0] K;
reg KS_Finished;
always @ (posedge clk or posedge rst)
	begin
	if (rst)
		begin
		i <= 8'h0;
		KSState <= `KSS_KEYSCHED1;
		KS_Finished <= 0;
		j <= 0; 
		end
	case (KSState)
		`KSS_KEYSCHED1:	begin
				S[i] <= i;
				if (i == 8'hFF)
					begin
					KSState <= `KSS_KEYSCHED2;
					i <= 8'h00;
					end
				else	i <= i +1;
				end
		`KSS_KEYSCHED2:	begin
				j <= (j + S[i] + key[i % `KEY_SIZE]);
				KSState <= `KSS_KEYSCHED3;
				end
		`KSS_KEYSCHED3:	begin
				S[i]<=S[j];
				S[j]<=S[i];
				if (i == 8'hFF)
					begin
					KSState <= `KSS_CRYPTO;
					KS_Finished <= 1; // Flag keysched finished
					i <= 8'h00;
					end
				else	begin
					i <= i + 1;
					KSState <= `KSS_KEYSCHED2;
					end
				end

		`KSS_CRYPTO:	begin // It was all nicely pipelined until this point where I don't care anymore
				i = i + 1;
				j = (j + S[i]);
				temp = S[j];
				S[j]=S[i];
				S[i]=temp;
				K = S[ S[i]+S[j] ];
				$display ("KSS_CRYPTO: K: %d",K);
				end
		default:	begin
				end
	endcase
	end



/* Simulation */
integer q;
initial begin
	for (q=0; q<`KEY_SIZE; q=q+1) key[q] = 8'h42; // initialize Key
	$display ("Start...");
	clk <= 0;
	KSState <= 8'h0; // Init key-schedule state
	rst <= 1;
	#(1*tck) 
	rst <= 0;
	#(program_cycles*tck+100) 
	$display ("Finish.");
	$finish;
end


endmodule

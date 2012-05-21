/* 
	RC4 PRGA module implementation
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


`include "rc4.inc"

module rc4(clk,rst,output_ready,password_input,K);

input clk; // Clock
input rst; // Reset
input [7:0] password_input; // Password input
output output_ready; // Output valid
output [7:0] K; // Output port


wire clk, rst; // clock, reset
reg output_ready;
wire [7:0] password_input;


/* RC4 PRGA */

// Key
reg [7:0] key[0:`KEY_SIZE-1];
// S array
reg [7:0] S[0:256];

// Key-scheduling state
`define KSS_KEYREAD 4'h0
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

always @ (posedge clk or posedge rst)
	begin
	if (rst)
		begin
		i <= 8'h0;
		KSState <= `KSS_KEYREAD;
		output_ready <= 0;
		j <= 0; 
		end
	case (KSState)	
		`KSS_KEYREAD:	begin // KSS_KEYREAD state: Read key from input
				if (i == `KEY_SIZE)
					begin
					KSState <= `KSS_KEYSCHED1;
					i<=8'h00;
					end
				else	begin
					i <= i+1;
					key[i] <= password_input;
					$display ("key[%d] = %08X",i,password_input);
					end
				end
		`KSS_KEYSCHED1:	begin // KSS_KEYSCHED1: Increment counter for S initialization
				S[i] <= i;
				if (i == 8'hFF)
					begin
					KSState <= `KSS_KEYSCHED2;
					i <= 8'h00;
					end
				else	i <= i +1;
				end
		`KSS_KEYSCHED2:	begin // KSS_KEYSCHED2: Initialize S array
				j <= (j + S[i] + key[i % `KEY_SIZE]);
				KSState <= `KSS_KEYSCHED3;
				end
		`KSS_KEYSCHED3:	begin // KSS_KEYSCHED3: S array permutation
				S[i]<=S[j];
				S[j]<=S[i];
				if (i == 8'hFF)
					begin
					KSState <= `KSS_CRYPTO;
					output_ready <= 1; // Flag keysched finished
					i <= 8'h00;
					end
				else	begin
					i <= i + 1;
					KSState <= `KSS_KEYSCHED2;
					end
				end

		`KSS_CRYPTO:	begin // KSS_CRYPTO: Output crypto stream
				// It was all nicely pipelined until this point where I don't care anymore
				i = i + 1;
				j = (j + S[i]);
				temp = S[j];
				S[j]=S[i];
				S[i]=temp;
				K = S[ S[i]+S[j] ];
				end
		default:	begin
				end
	endcase
	end

endmodule

// Yunzhang Jiang
// EE 271 Lab 4
// this program as a whole simulates tug of war for 2 players on FPGA board 
// the frequency of pressing button corresponds to the force to pull the string

// takes 3 1-bit inputs in, clk and reset
// return a 1-bit filtered output
// the output will be true for only one clock period if the input is a constant true
module avoidKeepPressing (reset, clk, in, out);
	input logic in, clk, reset;
	output logic out;
	
	enum {A, B} ps, ns; // A for not pressing, B for pressing
	
	always_ff @(posedge clk) begin
		if (reset) 
			ps <= A;
		else 
			ps <= ns;
	end
	
	always_comb begin
		case (ps) 
			A: if (~in) begin 
				ns = A;
				out = 0;
				end 
				
				else begin 
					ns = B;
					out = 1;
					end
					
			B: if (in) begin 
					ns = B;
					out = 0;
					end
				else begin
					ns = A;
					out = 0;
				end
		endcase
	end
endmodule

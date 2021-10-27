module solve_meta (clock,in, out);
	input logic clock,in;
	output logic out;
	logic dff1;
	always_ff @ (posedge clock)begin
		dff1 <= in;
		out <= dff1;
	end
	
endmodule 
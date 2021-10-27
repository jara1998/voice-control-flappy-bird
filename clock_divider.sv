// divides a clock to slower clocks
module clock_divider (clock, divided_clocks);

	 input logic clock;
	 output logic [31:0] divided_clocks;
	 initial begin
	 divided_clocks <= 0;
	 end
	 always_ff @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	 end
	 
endmodule

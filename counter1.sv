module counter1 (cycle, clk, reset, ctr);
	input logic clk, reset, cycle;
	output logic [4:0] ctr;
	
	always_ff @(posedge clk) begin
		if (reset)
				ctr <= 5'd0;
		else if (cycle && ctr < 5'd31)
			ctr <= ctr + 5'd1;
		else
			ctr <= 5'd0;
	end
	
endmodule 

module counter1_tb();
	logic clk, reset, cycle;
	logic [4:0] ctr;
	
	counter1 ct (cycle, clk, reset, ctr);
	
	parameter PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(PERIOD / 2)
			clk <= ~clk;
	end
	
	initial begin
		cycle <= 1; reset <= 1;@(posedge clk)
		reset <= 0; @(posedge clk) 
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		cycle <= 0; @(posedge clk)
		
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		$stop;
	end
endmodule
	
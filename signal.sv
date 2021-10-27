module signal( clk, read_ready, read_ready_true);

input logic read_ready, clk;
output logic read_ready_true;
 
 always_ff @(posedge clk) begin
	if(read_ready) read_ready_true = 1;
	else read_ready_true = 0;
 end

endmodule 



module signal_tb();

logic read_ready, clk, read_ready_true;

signal dut(clk, read_ready, read_ready_true);
	parameter CLOCK_PERIOD=100; 

	initial begin   
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;    
	end
	initial begin
		read_ready <= 1;
		repeat (3) @(posedge clk);
		read_ready <= 0;
		repeat (3) @(posedge clk);
		read_ready <= 1;
		repeat (5) @(posedge clk);
		read_ready <= 0;
		repeat (3) @(posedge clk);
	$stop;
	end
	endmodule 
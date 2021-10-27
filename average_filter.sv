module average #(parameter logN = 3) (reset, dataIn, dataOut, clk);

	input logic reset;
	input logic signed [23:0] dataIn;
	input logic clk;
	output logic signed [23:0] dataOut;
	logic signed [23:0] toFifo;
	logic signed [23:0] fifoOut, D2, D1;
	logic rd, wr, empty, full;
	logic signed [23:0] accOut;
	/* always_ff @(posedge clk) begin
		if (reset) begin
			rd <= 0;
			wr <= 0;
			toFifo <= 24'd0;
		end
		else if (~full) begin
			rd <= 0;
			wr <= 1;
			toFifo <= {{logN{dataIn[23]}}, dataIn[23:logN]};
		end
		else begin
			rd <= 1;
			wr <= 1;
			toFifo <= {{logN{dataIn[23]}}, dataIn[23:logN]};
		end
	end*/
	
	always_comb begin
		if (reset) begin
			rd = 0;
			wr = 0;
			toFifo = 24'd0;
		end
		else if (~full) begin
			rd = 0;
			wr = 1;
			toFifo = {{logN{dataIn[23]}}, dataIn[23:logN]};
		end
		else begin
			rd = 1;
			wr = 1;
			toFifo = {{logN{dataIn[23]}}, dataIn[23:logN]};
		end
	end
	
	
	
	fifo #(24, logN) byN (clk, reset, rd, wr, toFifo, empty, full, fifoOut);
	
	
	always_comb begin
		if (~full|empty)
			D1 = 0;
		else
			D1 = fifoOut;
	end
	
	assign D2 =  {{logN{dataIn[23]}}, dataIn[23:logN]} - D1;
	always_ff @(posedge clk) begin: accummulator
		if(dataOut === 24'bx)
		accOut <= 0;
		else accOut <= dataOut;
	end
	 assign dataOut = accOut + D2;
	


// assign dataOut = {{3{dataIn[23]}},dataIn[23:3]} + {{3{dff1[23]}},dff1[23:3]} + {{3{dff2[23]}},dff2[23:3]} + {{3{dff3[23]}},dff3[23:3]} + {{3{dff4[23]}},dff4[23:3]} + {{3{dff5[23]}},dff5[23:3]} + {{3{dff6[23]}},dff6[23:3]} + {{3{dff7[23]}},dff7[23:3]};
endmodule


module average_testbench();
	logic  reset, clk;
	logic [23:0] dataIn, dataOut;

	average dut(reset,dataIn,dataOut,clk);
	parameter CLOCK_PERIOD=100; 

	initial begin   
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;    
	end
	initial begin
		reset <= 1; dataIn <= 24'd175;@(posedge clk);
		reset <= 0; @(posedge clk);
		dataIn <= 24'd187; @(posedge clk);
		dataIn <= 24'd196; @(posedge clk);
		dataIn <= 24'd143; @(posedge clk);
		dataIn <= 24'd199; @(posedge clk);
		dataIn <= 24'd166; @(posedge clk);
		dataIn <= 24'd153; @(posedge clk);
		dataIn <= 24'd1333; @(posedge clk);
		dataIn <= 24'd1843; @(posedge clk);
		dataIn <= 24'd2000; @(posedge clk);
		dataIn <= 24'd1000; @(posedge clk);
		dataIn <= 24'd500; @(posedge clk);
		dataIn <= 24'd1200; @(posedge clk);
		repeat (1000) @(posedge clk);
	$stop;
	end
	endmodule 
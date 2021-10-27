module drawTV (clkf, reset, x, y, llx, trx, lly, try);
	input logic clkf, reset;
	output logic [10:0] x, y;
	input logic [10:0] llx, lly, trx, try;

	always_ff @(posedge clkf) begin
		if (~reset) begin
			x <= llx;
			y <= lly;
		end
		else if (y < try)
			y <= y + 1;
		else if (x < trx) begin
			y <= lly;
			x <= x + 1;
		end
		else begin
			x <= llx;
			y <= lly;
		end
	end
	
endmodule
			


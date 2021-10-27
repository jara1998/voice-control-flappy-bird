module drawTVwitheye (clkf, reset, x, y, llx, trx, lly, try);
	input logic clkf, reset;
	output logic [10:0] x, y;
	input logic [10:0] llx, lly, trx, try;
	logic [10:0] eye1x,eye1y,eye2x, eye2y;
	
	assign eye1x = (trx - llx) / 2 + 2 + llx;
	assign eye2x = (trx - llx) / 2 - 2 + llx;
	assign eye1y = (try - lly) / 2 + lly;
	always_ff @(posedge clkf) begin
		if (~reset) begin
			x <= llx;
			y <= lly;
		end
		else if (x == eye1x || x == eye2x) begin
			if (y == eye1y) y <= y + 2;
			else y <= y + 1;
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
			


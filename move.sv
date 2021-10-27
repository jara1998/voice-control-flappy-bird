module move (clks, clkf, reset, x, y, L3, L4, color, lose);
	input logic clks, clkf, reset, L3, L4;
	output logic [10:0] x, y;
	output logic color, lose;
	enum{idle, holdTV, TVup, TVdown, movePipe, erase} ps, ns;
	logic [5:0] ctr;
	logic draw_TV, GND, E;
	logic [5:0] ctr_n;
	logic draw_TV_n, GND_n, E_n, lose_n;
	logic [10:0] moveY_n, moveY, x1, x2, x3, y1, y2, y3, groundx, groundx_n;
	logic [3:0] height, height_n;
	logic [9:0] random, random_n;
	always_comb begin
		case (ps) 
			idle: if (reset) ns = idle;
					else ns = holdTV;
			holdTV: if (L3 | L4) ns = TVup;
					  else ns = movePipe;
		   movePipe: ns = erase;
			erase: if (ctr == 0) ns = holdTV;
				else if (ctr > 0 && ctr <= 30) ns = TVup;
				else if (ctr > 30 && ctr <= 60) ns = TVdown;
				else ns = holdTV;
			TVup: ns = movePipe;
			TVdown: ns = movePipe;
			endcase
	end
	always_ff @(posedge clks) begin
		if(reset) begin
			ps <= idle;
			ctr <= 0;
			draw_TV <= 0;
			GND <= 0;
			E <= 0;
			moveY <= 11'd240;
			groundx <= 11'd620;
			lose <= 0;
			height <= 5;
		end
		else if(lose) begin
			ps <= idle;
			ctr <= 0;
			draw_TV <= 0;
			GND <= 0;
			E <= 0;
			moveY <= 11'd240;
			groundx <= 11'd620;
			lose <= lose_n;
			height <= 5;
		end
		else begin
			ps <= ns;
			ctr <= ctr_n; 
			draw_TV <= draw_TV_n;
			GND <= GND_n;
			E <= E_n;
			moveY <= moveY_n;
			groundx <= groundx_n;
			lose <= lose_n;
			height <= height_n;
		end
		
	end
	
	always_comb begin: datapath
		case (ps) 
			idle: begin 
						ctr_n = 0; moveY_n = 11'd240; E_n = 0; GND_n = 0; draw_TV_n = 0;
					end
					
			holdTV: if (L3 | L4) begin
							ctr_n = ctr + 1; moveY_n = moveY; E_n = 1; GND_n = 0; draw_TV_n = 0;
								 end
					  else begin
							ctr_n = 0; moveY_n = moveY; E_n = 0; GND_n = 0; draw_TV_n = 1;
							
							end
		   movePipe: begin
							if (ctr > 60)
							begin
								ctr_n = 0; moveY_n = moveY; E_n = 0; GND_n = 0; draw_TV_n = 1;
							end
							else 
							begin 
								ctr_n = ctr; moveY_n = moveY; E_n = 0; GND_n = 1; draw_TV_n = 0;
							end
						 end
			erase: 
				if (ctr > 0 && ctr <= 30) begin
							ctr_n = ctr + 1; moveY_n = moveY - height; E_n = 1; GND_n = 0; draw_TV_n = 0;
						 end
						 
				else if (ctr == 0)
					begin
						ctr_n = ctr; moveY_n = moveY; E_n = 1; GND_n = 0; draw_TV_n = 0;
					end

				else if (30 < ctr && ctr <= 60) begin
							ctr_n = ctr + 1; moveY_n = moveY + height; E_n = 1; GND_n = 0; draw_TV_n = 0;
							end
				else begin
							ctr_n = ctr; moveY_n = moveY; E_n = E; GND_n = 0; draw_TV_n = draw_TV;
					  end
			
			
			TVup: begin
							ctr_n = ctr; moveY_n = moveY; E_n = 0; GND_n = 0; draw_TV_n = 1;
				   end
			
			TVdown: 
					begin
							ctr_n = ctr; moveY_n = moveY; E_n = 0; GND_n = 0; draw_TV_n = 1;
					 end
			endcase
	end
	
	// ground moves in x-axis
	always_comb begin
		case (ps)
			idle: groundx_n = 11'd620;
			TVup: groundx_n = groundx;
			TVdown: groundx_n = groundx;
			movePipe: 	if (groundx <= 10)
								groundx_n = 11'd635;
							else 
								groundx_n = groundx - 3;
			holdTV:  groundx_n = groundx;
			erase: groundx_n = groundx;
	   endcase
	end
	
	// lose condition check
	always_comb
		if ((groundx <= 175 && groundx >= 145) && (moveY - 10 <= 250 && moveY + 10 >= 240 - random)) lose_n = 1;
		else lose_n = lose;
		
	// height
	always_comb begin
		case (ps)
			idle: height_n = height;
			TVup: height_n = height;
			TVdown: height_n = height;
			movePipe: height_n = height;
			holdTV:  if (L4) height_n = 7;
						else height_n = 5;
			erase: height_n = height;
	   endcase
	end
	
	random ran (groundx <= 10,random);
	                                           // 230       // 250
	drawTV tv (clkf, draw_TV, x1, y1, 150, 170, moveY - 10, moveY + 10);
	drawTV ground (clkf, GND, x2, y2, groundx - 5, groundx + 5, 240 - random, 250); // current 80
	drawTV clearScreen (clkf, E, x3, y3, 0, 640, 0, 480);
	
	
	
	assign color = (~E) || (y3 >= 250);
	
	always_comb begin
		if (draw_TV) begin
			x = x1;
			y = y1;
		end
		//else if (GND) begin
		else if (ps == erase) begin
			x = x2;
			y = y2;
		end
		else if (E) begin
			x = x3;
			y = y3;
		end
		else begin
			x = 11'd320;
			y = 11'd240;
		end
	end
	
endmodule


/* module move_tb();
		
	logic clks, clkf, reset, L3;
	logic [10:0] x, y;
	logic color;
	logic test;
	
	parameter period = 100000;
	initial begin
		clks <= 0;
		forever #(period / 2)
			clks <= ~clks;
	end
	
	initial begin
		clkf <= 0;
		forever #(period / 100000)
			clkf <= ~clkf;
	end
	
	move dut (clks, clkf, reset, x, y, L3, color, test);

	initial begin
		reset <= 1; L3 <= 0; @(posedge clks);
		reset <= 0; @(posedge clks);
		@(posedge clks);
		@(posedge clks);
		L3 <= 1; @(posedge clks);
		L3 <= 0; @(posedge clks);
		L3 <= 1; @(posedge clks);
		L3 <= 0; @(posedge clks);
		$stop;
	end
endmodule
*/ 








	
		
		
		
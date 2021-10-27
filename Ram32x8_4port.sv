module Ram32x8_4port (     
    input logic clk, reset, wr_en, startCyc, clk_fast, clk_slow, // WriteEnable, startCycle(partB)     
	 input logic [7:0] w_data,      // write data     
	 input logic [4:0] w_addr, // write address     
	 input logic [4:0] r_addr1, // read port 1 address async
	 input logic [4:0] r_addr2, // read port 2 address, 4 consecutive data
	 input logic [5:0] r_addr3, // read port 3 address 
    output logic [7:0]  r_port1, // read data output of port 1     
	 output logic [31:0] r_port2,   // read data output of port 2     
	 output logic [3:0]  r_port3 // read data output of port 3 
	 ); 
	 logic [7:0]  rp1a, rp1b; // ReadPort1A, ReadPort1B 
	 logic [31:0] rp2a, rp2b; // ReadPort2A, ReadPort2B 
	 logic [3:0]  rp3a, rp3b; // ReadPort3A, ReadPort3B 
	 logic [4:0] ctr, nctr; // Counter, nextCounterValue 
	 logic cycle;
	 enum {normal, cycling} ps, ns;
	 logic [7:0] ram [0:31];
	 
	 /* logic [31:0] clk_array;
	 parameter whichClock = 1;
	 clock_divider cdiv (.clock(clk), .divided_clocks(clk_array));
	 */
	 
	 
	 // write
	 always_ff@(posedge clk)
		if (wr_en) 
			ram[w_addr] <= w_data;
	 
	 
	 //counter1 c1 (cycle, clk_array[5], reset, ctr); // normal speed clock for read 1
	 //counter2 c2 (cycle, clk_array[7], reset, nctr); // slower clock for read 2 
	 
	 // for simulation
	 counter1 c1 (cycle, clk_fast, reset, ctr); // normal speed clock for read 1
	 counter2 c2 (cycle, clk_slow, reset, nctr); // slower clock for read 2 
	 
	 // read logics
	 
	 // determines cycling mode or normal mode
	 always_comb begin
		case(ps)
			normal: begin
					  cycle = 0;
					  ns = normal;
					  end
		  cycling: begin
					  if (ctr >= 5'd31) begin
					     cycle = 0;
						  ns = normal;
					  end
					  else begin
						  cycle = 1;
						  ns = cycling;
					  end
					  end
		endcase
	 end
	 
	 always_ff @(posedge clk) begin
		if (reset & startCyc) begin
			ps <= cycling;
			end
		else if (reset & ~startCyc) begin
			ps <= normal;
		end
			
		else begin
			ps <= ns;
		end
	 end
	 
	 
	 
	 // port A are produced in normal state
	 // port B are produced in cycling state
	 
	 // port 1 async
	 assign rp1a = ram[r_addr1];
	 assign rp1b = ram[ctr];
	 
	 // port 2 sync
	 always_ff @(posedge clk) begin
       rp2a <= {ram[r_addr2], ram[r_addr2 + 1], ram[r_addr2 + 2], ram[r_addr2 + 3]};
		 rp2b <= {ram[nctr], ram[nctr + 5'd1], ram[nctr + 5'd2], ram[nctr + 5'd3]};
	 end
	 
	 
	 
	 logic [7:0] temp_r3; 
	 
	 assign temp_r3 = ram[r_addr3[4:1]];
	 // port 3 sync
	 always_ff @(posedge clk) begin
		if (r_addr3[0] == 0)
			rp3a <= temp_r3[3:0];
		else
			rp3a <= temp_r3[7:4];
			
		rp3b <= ram[0][3:0];
	 end
	 
	 
	 
	 


	 always_comb begin
		if (ps == normal) begin
			r_port1 = rp1a;
			r_port2 = rp2a;
			r_port3 = rp3a;
		end
		else begin
		   r_port1 = rp1b;
			r_port2 = rp2b;
			r_port3 = rp3b;
	   end
	 end
	 
endmodule
	 
module Ram32x8_4port_testbench();
	logic clk, reset, wr_en, startCyc, clk_fast, clk_slow;// WriteEnable, startCycle(partB)     
	logic [7:0] w_data;     // write data     
	 logic [4:0] w_addr; // write address     
	 logic [4:0] r_addr1; // read port 1 address async
	logic [4:0] r_addr2; // read port 2 address, 4 consecutive data
	 logic [5:0] r_addr3; // read port 3 address 
     logic [7:0]  r_port1; // read data output of port 1     
	  logic [31:0] r_port2;   // read data output of port 2     
	  logic [3:0]  r_port3;
	  
	  
	 Ram32x8_4port dut (clk, reset, wr_en, startCyc, clk_fast, clk_slow, w_data, w_addr, r_addr1, r_addr2, r_addr3, r_port1, r_port2,  r_port3); 
	 
	 parameter PERIOD = 100;
	 initial begin
		clk <= 0;
		forever #(PERIOD/2)
			clk <= ~clk;
	 end
	 
	 initial begin
		clk_fast <= 0;
		forever #(PERIOD)
			clk_fast <= ~clk_fast;
	 end
	 
	 initial begin
		clk_slow <= 0;
		forever #(PERIOD * 4)
			clk_slow <= ~clk_slow;
	 end
	 
	 initial begin
	 reset <= 1; startCyc <= 1; @(posedge clk)
	 reset <= 0; @(posedge clk) @(posedge clk)
	 // write data
	 w_data <= 8'b00000001; wr_en <= 1; w_addr <= 5'd0; @(posedge clk) @(posedge clk)
	 w_data <= 8'b00000010; wr_en <= 1; w_addr <= 5'd2; @(posedge clk) @(posedge clk)
	 w_data <= 8'b00000011; wr_en <= 1; w_addr <= 5'd3; @(posedge clk)
	 w_data <= 8'b00011100; wr_en <= 1; w_addr <= 5'd4; @(posedge clk)
	 w_data <= 8'b00111100; wr_en <= 1; w_addr <= 5'd5; @(posedge clk) 
	 w_data <= 8'b01111100; wr_en <= 1; w_addr <= 5'd6; @(posedge clk)
	 w_data <= 8'b00000100; wr_en <= 1; w_addr <= 5'd7; @(posedge clk) 
	 w_data <= 8'b01111000; wr_en <= 1; w_addr <= 5'd25; @(posedge clk) @(posedge clk)
	 w_data <= 8'b01111001; wr_en <= 1; w_addr <= 5'd24; @(posedge clk) @(posedge clk)
	 w_data <= 8'b01111010; wr_en <= 1; w_addr <= 5'd23; @(posedge clk) @(posedge clk)
	 w_data <= 8'b01111011; wr_en <= 1; w_addr <= 5'd22; @(posedge clk) @(posedge clk)
	 w_data <= 8'b01111100; wr_en <= 1; w_addr <= 5'd21; @(posedge clk) @(posedge clk)
	 startCyc <= 1; wr_en <= 0; @(posedge clk)
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

	 r_addr1 <= 5'b00000; @(posedge clk)
	 r_addr2 <= 5'd21; @(posedge clk)
	 r_addr3 <= 6'b101010; @(posedge clk)  @(posedge clk) @(posedge clk) @(posedge clk) @(posedge clk) 
	 r_addr3 <= 6'b101011; @(posedge clk)
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
 
	 

/* module clock_divider (clock, divided_clocks);

	 input logic clock;
	 output logic [31:0] divided_clocks;
	 initial begin
		divided_clocks <= 0;
	 end
	 always_ff @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	 end
	 
endmodule */

module part1 (CLOCK_50, CLOCK2_50, KEY, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT,
				  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, SW, 
	           VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	output  reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output  reg [9:0] LEDR;
	input  [3:0] KEY;
	input [9:0] SW;
	
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	wire color;
	wire out;
	wire lose;
	
	wire [10:0] x, y;
	

	
	
	input CLOCK_50, CLOCK2_50;
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	// Local wires.
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right, Q;
	wire reset = ~KEY[0];
	wire KEY3, KEY2;
	
	wire [31:0] clk;
	parameter whichClock = 5;
	clock_divider cdiv (CLOCK_50, clk);
	wire test;
	
	/////////////////////////////////
	// Your code goes here 
	/////////////////////////////////
	
	//assign writedata_left = readdata_left + Q;
	//assign writedata_right = readdata_right + Q;
	assign read = read_ready;
	assign write = write_ready;
	/*always begin 
		if(writedata_left >0 || writedata_right >0) LEDR[0] = 1;
		else LEDR[0] = 0;
	end
	
	always begin 
		if(writedata_left >24'b000000000000001000000000 || writedata_right >24'b000000000000001000000000) LEDR[1] = 1; // 10th
		else LEDR[1] = 0;
	end
	
	always begin 
		if((writedata_left >> 21) == 3'b000 || (writedata_right >> 21) == 3'b000)  LEDR[2] = 1; // 13th
		else LEDR[2] = 0;
	end
	
	always begin 
		if((writedata_left >> 21) == 3'b001 || (writedata_right >> 21) == 3'b001) LEDR[3] = 1; // 16th
		else LEDR[3] = 0;
	end
	
	always begin 
		if((writedata_left >> 21) == 3'b010 || (writedata_right >> 21) == 3'b010)  LEDR[4] = 1; // 19th
		else LEDR[4] = 0;
	end
	
	always begin 
		if((writedata_left >> 21) == 3'b111 || (writedata_right >> 21) == 3'b111)  LEDR[5] = 1; // 21th
		else LEDR[5] = 0;
	end
	*/
	
	
	always begin 
		if((writedata_left >> 21) == 3'b001 || (writedata_right >> 21) == 3'b001) LEDR[3] = 1; // 16th
		else LEDR[3] = 0;
	end
	
	always begin 
		if((writedata_left >> 21) == 3'b010 || (writedata_right >> 21) == 3'b010)  LEDR[4] = 1; // 19th
		else LEDR[4] = 0;
	end
	
	
	average #(7) avl (1'b0, readdata_left, writedata_left, CLOCK_50);
	average #(7) avr (1'b0, readdata_right, writedata_right, CLOCK_50);
	
	// drawTV tv (CLOCK_50, ~KEY[0], x, y, 310, 330, 230, 240);
	
	always begin 
			if (test) 
				LEDR[0] = 1;
			else 
				LEDR[0] = 0;
	end
	
	always begin
		if (lose) LEDR[9] = 1;
		else LEDR[9] = 0;
	end
	
	move likeJagger (clk[18], CLOCK_50, out, x, y, LEDR[3], LEDR[4], color, lose);
	VGA_framebuffer fb(CLOCK_50, 1'b0, x, y,
				color, 1'b1,
				VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_HS, VGA_VS,
				VGA_BLANK_N, VGA_SYNC_N);
   solve_meta(~KEY[0], SW[9], out);
	
	
	
	
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		reset,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		reset,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		reset,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule


	 


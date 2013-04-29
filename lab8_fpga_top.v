/***********************************************
*  ECE324 Digital Systems Design:  Lab 8
*  John Hofman, Candice Adsero, & Ricky Barella
*  Lab8_fpga_top Module
************************************************/


/*********************************************************************
  ECE 324 Lab 8 starter kit 
  Dr. Lynch - 07 Mar 2011
  
*********************************************************************/
 
module Lab8_fpga_top(
	input clk,							// clock input
	input  [7:0] sw,					// switch inputs
	input  [3:0] btn,					// button inputs
	output [7:0] Led,					// LED outputs
// 7-segment display outputs
    output [3:0] an,					// SSEG select output
    output [6:0] sseg,				// SSEG output
    output dp,							// SSEG decimal point output
// VGA outputs
    output Vsync, Hsync,			// VGA vertical and horizontal output
    output [3:1] vgaRed, vgaGreen, // Red and Green outputs
    output [3:2] vgaBlue,			// Blue output
// PS2 bidirectional ports
	inout wire ps2d, ps2c
);

   // signal declarationse
    wire reset = 0;
	wire [7:0] key_code;
	wire [64*64-1:0] maze_data;
	wire start, finish;
	
	wire enable_display;
	wire [4:0] char_x, char_y;
	wire [3:0] finish_x, finish_y;
	wire [3:0] start_x, start_y;
	
	assign enable_display = sw[7];
   
   // tie off unsed outputs
	assign an = 4'b0000;
	assign sseg = 7'b0000000;
	assign dp = 1'b0;
	
// pass switch input on to Led outputs
	assign Led = key_code;
	
	// registers for testing display
	reg [4:0] x_dim = 16, y_dim = 16;
	reg [6:0] tile_width = 4, tile_height = 4;
	reg [4:0] x_coord = 0, y_coord = 0;
	reg [27:0] char_x_count = 0, char_y_count = 0, 
	           char_x_speed = 20_000_000, char_y_speed = 20_000_000;
	reg [7:0] KEY_UP =   8'b11101010, KEY_DOWN =  8'b11100100,
	          KEY_LEFT = 8'b11010110, KEY_RIGHT = 8'b11101000;
	reg [7:0] KEY_W =    8'b00111010, KEY_S =     8'b00110110,
	          KEY_A =    8'b00111000, KEY_D =     8'b01000110;
	always @(posedge clk) begin
		if (btn[2]) begin    // btn0 controls # tile for width/height of maze
			x_dim <= sw[4:0];
		end
		if (btn[2]) begin
			y_dim <= sw[4:0];
		end
		if (btn[3]) begin // btn1 controls # pixels per tile
			tile_width <=  sw[6:0]; 
		end
		if (btn[3]) begin
			tile_height <= sw[6:0];
		end
/*		if (char_x_count < char_x_speed) begin // btn3 controls position of avatar
			char_x_count <= char_x_count + 1;
		end
		else begin
			char_x_count <= 0;
			if (key_code == KEY_UP || key_code == KEY_W)
				char_y <= char_y - 1;
			if (key_code == KEY_DOWN || key_code == KEY_S)
				char_y <= char_y + 1;
			if (key_code == KEY_LEFT || key_code == KEY_A)
				char_x <= char_x - 1;
			if (key_code == KEY_RIGHT || key_code == KEY_D)
				char_x <= char_x + 1;
		end
*/
	end
	
	maze_carver_2 MC (
		.clk(clk),
		.slow_time(2_000_000),
		.start(btn[0]),
		.x_dimension(x_dim),
		.y_dimension(y_dim),
		.maze_data(maze_data),
		.finish(finish),
		.curr_x(char_x),
		.curr_y(char_y),
		.finish_x(finish_x),
		.finish_y(finish_y)
	);

	//instantiate keyboard
/*	kb_code KB(
		.clk(clk), 
		.reset(reset),
		.ps2d(ps2d), 
		.ps2c(ps2c), 
		.rd_key_code(1),
		.key_code(key_code),
		.kb_buf_empty()
	);
*/
	
// instantiate VGA tester
	maze_renderer_test MRT (
		.clk(clk), .reset(1'b0), .enable(enable_display),
		.char_x({2'b00, char_x}), .char_y({2'b00, char_y}),
		.path_data(maze_data),
	   .maze_width({2'b00, x_dim}), .maze_height({2'b00, y_dim}),
		.x_coord(0), .y_coord(0),
		.tile_width(tile_width), .tile_height(tile_height), // 2^x = width or height in pixels
		.start_x(start_x), .start_y(start_y),
		.finish_x(finish_x), .finish_y(finish_y),
	    .hsync(Hsync), .vsync(Vsync), 
	    .rgb({vgaRed, vgaGreen, vgaBlue})
	);


	// STARTUP_SPARTAN3E: Startup primitive for GSR, GTS, startup sequence control
	// and Multi-Boot Configuration Trigger. Spartan-3E
	// Xilinx HDL Libraries Guide, version 11.2
	STARTUP_SPARTAN3E SU(
		.CLK(clk), // Clock input for start-up sequence
		.GSR(reset), // Global Set/Reset input (GSR can not be used as a port name)
		.GTS(), // Global 3-state input (GTS can not be used as a port name)
		.MBT() // Multi-Boot Trigger input
	);
	


endmodule

/***********************************************
*  ECE324 Digital Systems Design:  Lab 8
*  John Hofman, Candice Adsero, & Ricky Barella
*  Lab8_fpga_top Module
************************************************/


/*********************************************************************
  ECE 324 Lab 8 starter kit 
  Dr. Lynch - 07 Mar 2011
  
*********************************************************************/
 
module maze_generator_fpga_top(
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
	
	wire carve_finished;
	wire state_start;
	wire state_carve;
	wire state_move;

//	reg start_carve = 0;
//	reg carve_started = 0;

   // signal declarationse
    wire reset = 0;
	wire [7:0] key_code;
	wire [16*16-1:0] maze_data;
	
	wire [3:0] char_1_x, char_1_y;
	wire [3:0] carve_x, carve_y;
	wire [3:0] finish_x, finish_y;
	wire [3:0] start_x, start_y;
   
   // tie off unsed outputs
	assign an = 4'b0000;
	assign sseg = 7'b0000000;
	assign dp = 1'b0;
	
// pass switch input on to Led outputs
	assign Led = key_code;
	
	// registers for testing display
	reg [4:0] maze_width = 16, maze_height = 16;
	reg [4:0] tile_width = 4, tile_height = 4;
	reg [25:0] char_x_count = 0, char_y_count = 0, 
	           char_speed = 20_000_000;
//	reg [7:0] KEY_UP =   8'b11101010, KEY_DOWN =  8'b11100100,
//	          KEY_LEFT = 8'b11010110, KEY_RIGHT = 8'b11101000;
//	reg [7:0] KEY_W =    8'b00111010, KEY_S =     8'b00110110,
//	          KEY_A =    8'b00111000, KEY_D =     8'b01000110;
//	always @(posedge clk) begin
//		if (state_carve == 1 && !start_carve)
//			start_carve <= 1;
//		else
//			start_carve <= 0;
//	end
	
	maze_state MS (
		.clk(clk),
		.start_btn(btn[0]),
		.finished_carve(carve_finished),
		.start(state_start),
		.carve(state_carve),
		.move(state_move)
	);
	
	maze_carver_2 MC (
		.clk(clk),
		.slow_time(2_000_000),
		.start(state_carve & btn[0]),
		.maze_width(maze_width),
		.maze_height(maze_height),
		.maze_data(maze_data),
		.finished(carve_finished),
		.curr_x(carve_x),
		.curr_y(carve_y),
		.finish_x(finish_x),
		.finish_y(finish_y)
	);

	//instantiate keyboard
	kb_code KB(
		.clk(clk), 
		.reset(btn[0]),
		.ps2d(ps2d), 
		.ps2c(ps2c), 
		.rd_key_code(1),
		.key_code(key_code),
		.kb_buf_empty()
	);
	
// instantiate VGA tester
	maze_renderer_test MRT (
		.clk(clk), .reset(1'b0), .enable(1),
		.start_screen(state_start),
		.maze_screen(state_carve | state_move),
		.char_x(state_carve? carve_x : state_move? char_1_x : start_x),
		.char_y(state_carve? carve_y : state_move? char_1_y : start_y),
		.path_data(maze_data),
		.maze_width(maze_width), .maze_height(maze_height),
		.tile_width(tile_width), .tile_height(tile_height), // 2^x = width or height in pixels
		.start_x(start_x), .start_y(start_y),
		.finish_x(finish_x), .finish_y(finish_y),
	    .hsync(Hsync), .vsync(Vsync), 
	    .rgb({vgaRed, vgaGreen, vgaBlue})
	);

	maze_move char_1 (
		.clk(clk),
		.reset(btn[0]),
		.enable(state_move),
		.key_code(key_code),
		.maze_data(maze_data),
		.maze_width(maze_width), .maze_height(maze_height),
		.start_x(start_x), .start_y(start_y),
		.curr_x(char_1_x), .curr_y(char_1_y)
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

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
    output [3:2] vgaBlue			// Blue output
);

   // signal declarationse
	wire [64*64-1:0] maze_data;
	wire start, finish;
	
	reg [6:0] x_dim = 64, y_dim = 64;
	reg [6:0] tile_width = 2, tile_height = 2;
	reg [6:0] x_coord = 0, y_coord = 0;
	wire enable_display;
	reg [6:0] char_x = 0, char_y = 0;
	always @(posedge clk) begin
		if (btn[0]) begin    // btn0 controls # tile for width/height of maze
			x_dim <= sw[6:0];
			y_dim <= sw[6:0];
		end
		if (btn[1]) begin // btn1 controls # pixels per tile
			tile_width <=  sw[6:0]; 
			tile_height <= sw[6:0];
		end
		if (btn[2]) begin // btn2 controls top-left tile coordinate on maze 
			x_coord <= sw[6:0];
			y_coord <= sw[6:0];
		end
		if (btn[3]) begin
			char_x <= sw[7:4];
			char_y <= sw[3:0];
		end
	end
	
	assign enable_display = sw[7];

   wire reset; // driven by Startup primitive
   
   // tie off unsed outputs
	assign an = 4'b0000;
	assign sseg = 7'b0000000;
	assign dp = 1'b0;
	
// pass switch input on to Led outputs
	assign Led = sw;

// instantiate VGA tester
	maze_renderer_test MRT (
		.clk(clk), .reset(1'b0), .enable(enable_display),
		.char_x(char_x), .char_y(char_y),
		.path_data(maze_data),
	   .maze_width(x_dim), .maze_height(y_dim),
		.x_coord(x_coord), .y_coord(y_coord),
		.tile_width(tile_width), .tile_height(tile_height), // 2^x = width or height in pixels
	    .hsync(Hsync), .vsync(Vsync), 
	    .rgb({vgaRed, vgaGreen, vgaBlue})
	);
	
	maze_carver MC (
		.start(1),
		.x_dimension(x_dim),
		.y_dimension(y_dim),
		.maze_data(maze_data),
		.finish()
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

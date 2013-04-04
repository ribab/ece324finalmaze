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
	output [7:0] Led,					// LED inputs
// 7-segment display outputs
    output [3:0] an,					// SSEG select output
    output [6:0] sseg,				// SSEG output
    output dp,							// SSEG decimal point output
// VGA outputs
    output Vsync, Hsync,			// VGA vertical and horizontal output
    output [3:1] vgaRed, vgaGreen, // Red and Green outputs
    output [3:2] vgaBlue			// Blue output
);

   // signal declarations
	wire [2:0] maze_paths [2:0];
	wire [1:0] start_x, start_y, finish_x, finish_y;
//	wire [2:0] x_dim, y_dim;
   wire [9:0] pixel_x, pixel_y;
   wire video_on, pixel_tick;
   wire [7:0] rgb_next;
   reg  [7:0] rgb_reg;

   wire reset; // driven by Startup primitive
   
   // tie off unsed outputs
	assign an = 4'b0000;
	assign sseg = 7'b0000000;
	assign dp = 1'b0;
   
   wire [9:0] y_pos;
	
// pass switch input on to Led outputs
	assign Led = sw;

// instantiate VGA tester
	maze_renderer_test MRT (
		.clk(clk), 
		.reset(1'b0),
//		.path_array(maze_paths),
//	   .maze_width(3), 
//		.maze_height(3),
	//	.sw(sw),
	    .hsync(Hsync), 
	    .vsync(Vsync), 
	    .rgb({vgaRed, vgaGreen, vgaBlue})
	);
	
/*	maze_carver MC (
		.x_dimension(x_dim),
		.y_dimension(y_dim),
		.maze_paths(maze_paths),			//  output
//		.maze_solution,
		.start_x(start_x),
		.start_y(start_y),
		.finish_x(finish_x),
		.finish_y(finish_y)
	);*/
	
	vga_sync VGAS(
		.clk(clk), 
		.reset(reset),		// clock and reset inputs
		.hsync(Hsync), 
		.vsync(Vsync), 
		.video_on(video_on), 
		.p_tick(pixel_tick),			// outputs
		.pixel_x(pixel_x),
		.pixel_y(pixel_y)			// pixel x and y outputs
   );	

   // rgb buffer
   always @(posedge clk) if (pixel_tick) rgb_reg <= rgb_next;
   // output
   assign {vgaRed, vgaGreen, vgaBlue} = rgb_reg;


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

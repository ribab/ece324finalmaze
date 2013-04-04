/***********************************************
*  ECE324 Digital Systems Design:  Lab 8
*  John Hofman, Candice Adsero, & Ricky Barella
*  vga_test Module
************************************************/


/* NEXYS 2 VGA tester
   from Pong Chu, "FPGA Protyping by Verilog Examples"
   Listing 13.2
   
   Modified 07 March 2011 by JDL: Changed from 8 colors (3 bits) to 256 colors (8 bits)
*/   

module maze_renderer_test
   (
    input wire clk, reset,			// input clock and reset
	 //input wire [2:0] maze_width, maze_height,
 //   input wire [7:0] sw,			// switch inputs
    output wire hsync, vsync,		// horizontal and vertical switch outputs
    output wire [7:0] rgb			// Red, green, blue output
   );

   //signal declaration
	reg [2:0] path_array [0:2];

   reg [7:0] rgb_reg, rgb_next;
	// colors are the colors of the rainbow roygbiv
	reg [7:0] c1 = 8'b11000100, c2 = 8'b11110000, c3 = 8'b11111100,
				 c4 = 8'b00011100, c5 = 8'b00001111, c6 = 8'b00000001,
				 c7 = 8'b10000011, c8 = 8'b11000110;
	// arbitrary colors assigned to next colors
	reg [7:0] c1_next = 8'b11000100, c2_next = 8'b11110000, c3_next = 8'b11111100,
				 c4_next = 8'b00011100, c5_next = 8'b00001111, c6_next = 8'b00000001,
				 c7_next = 8'b10000011, c8_next = 8'b11000110;
   wire video_on;
	// x and y position wire variables
	wire [9:0] x_pos, y_pos;
	//parameter wtime = 5_000_000;

		
/*	// assign next color to current color
	always @(posedge clk) begin
		rgb_reg <= rgb_next;
		c1 <= c1_next;
		c2 <= c2_next;
		c3 <= c3_next;
		c4 <= c4_next;
		c5 <= c5_next;
		c6 <= c6_next;
		c7 <= c7_next;
		c8 <= c8_next;
		end
*/
   // rgb buffer
	reg [1:0] i_reg, j_reg;
	wire [1:0] i_next, j_next;
	
	assign i_next = (i_reg >= 3-1) ? 0 :
						 i_reg + 1;
	assign j_next = (j_reg >= 3-1) ? 0 :
						 j_reg + 1;
	
	initial begin
		i_reg = 0;
		j_reg = 0;
	end
	
	// xpos and ypos are current pixels
	// path_array [y_pos] is path
   always @(negedge clk)begin
		if (i_reg*640/3 <= x_pos &&
			 i_reg*640/3 + 640/3 > x_pos &&
			 j_reg*480/3 <= y_pos &&
			 j_reg*480/3 + 480/3 > y_pos)
			 if (path_array[i_reg][j_reg] == 1)
				rgb_next = 8'b00000000;
			 else
				rgb_next = 8'b11111111;
		i_reg = i_next;
		if (i_reg >= 3-1)
			j_reg = j_next;
	end
	
//	 maze_paths
//  000...0
//  111...0
//  000...0
//  ...
//  000...0

	initial begin
		path_array [0] = 3'b111;
		path_array [1] = 3'b000;
		path_array [2] = 3'b111;
	end	
		
   // output
   assign rgb = (video_on) ? rgb_reg : 8'b0;

endmodule

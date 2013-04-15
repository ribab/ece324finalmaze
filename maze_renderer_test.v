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
    input wire clk, reset, enable,			// input clock and reset
	input [6:0] char_x, char_y,
	input [64*64-1:0] path_data,
	input wire [6:0] maze_width, maze_height,
	input wire [6:0] x_coord, y_coord,
	input wire [6:0] tile_width, tile_height,
    output wire hsync, vsync,		// horizontal and vertical switch outputs
    output wire [7:0] rgb			// Red, green, blue output
   );
	
	wire video_on;
	
	reg [7:0] char_color = 8'b000_111_00;
	reg [15:0] char_array = 16'b0110_1111_1111_0110;

   reg [7:0] rgb_reg;
	reg [7:0] rgb_next;
	// colors are the colors of the rainbow roygbiv
	reg [7:0] c1 = 8'b11000100, c2 = 8'b11110000, c3 = 8'b11111100,
				 c4 = 8'b00011100, c5 = 8'b00001111, c6 = 8'b00000001,
				 c7 = 8'b10000011, c8 = 8'b11000110;
				 
	// x and y position wire variables
	wire [9:0] x_pos, y_pos;
	//parameter wtime = 5_000_000;

	wire [9:0] tile_pixel_w = 1 << tile_width;
	wire [9:0] tile_pixel_h = 1 << tile_height;
	wire [9:0] maze_pixel_w = tile_pixel_w*maze_width;
	wire [9:0] maze_pixel_h = tile_pixel_h*maze_height;
	wire [9:0] maze_border_x = (640 - maze_pixel_w) >> 1;
	wire [9:0] maze_border_y = (480 - maze_pixel_h) >> 1;
	wire [9:0] tile_x = x_pos >> tile_width;
	wire [9:0] tile_y = y_pos >> tile_height;
	wire [9:0] centered_tile_x = (x_pos - maze_border_x) >> tile_width;
	wire [9:0] centered_tile_y = (y_pos - maze_border_y) >> tile_height;
	
   // Control the Display
	always @(posedge clk) begin
		if (enable)
			/*if (x_pos > char_x*(tile_pixel_w) && x_pos <= (char_x+1)*(tile_pixel_w) && // todo: doesn't show character
				 y_pos > char_y*(tile_pixel_h) && y_pos <= (char_y+1)*(tile_pixel_h))
			   rgb_next <= 8'b10101010;
			else */
			if (maze_pixel_w <= 640 && maze_pixel_h <= 480)
				if (x_pos >= maze_pixel_w + maze_border_x ||
					 x_pos < maze_border_x ||
					 y_pos >= maze_pixel_h + maze_border_y ||
					 y_pos < maze_border_y)
					rgb_next <= 8'b00000000;
				else if (char_x == centered_tile_x &&
							char_y == centered_tile_y &&
							char_array[  ((x_pos - maze_border_x - centered_tile_x*tile_pixel_w) >> (tile_width - 2)) +
										  4*((y_pos - maze_border_y - centered_tile_y*tile_pixel_h) >> (tile_height - 2))] == 1)
					rgb_next <= char_color;
				else if (path_data[   centered_tile_x +
								   64*centered_tile_y ] == 1)
						rgb_next <= 8'b11111111;
				else
					rgb_next <= 8'b00000000;
			else
				if (char_x == tile_x - x_coord &&
					char_y == tile_y - y_coord &&
					char_array[  ((x_pos - tile_x*tile_pixel_w) >> (tile_width - 2)) +
					           4*((y_pos - tile_y*tile_pixel_h) >> (tile_height - 2))] == 1)
					rgb_next <= char_color;
				else if (path_data[   (x_coord + (x_pos >> tile_width)) +
								  64*(y_coord + (y_pos >> tile_height))] == 1)
						rgb_next <= 8'b11100000;
				else
					rgb_next <= 8'b00000000;
		else
			rgb_next <= 8'b00000000;
	end
	
	vga_sync VGAS(
		.clk(clk), 
		.reset(reset),		// clock and reset inputs
		.hsync(hsync), 
		.vsync(vsync), 
		.video_on(video_on), 
		.p_tick(),			// outputs
		.pixel_x(x_pos),
		.pixel_y(y_pos)			// pixel x and y outputs
   );	

	always @(negedge clk) begin
		rgb_reg <= rgb_next;
	end
		
   assign rgb = (video_on) ? rgb_reg : 8'b0;

/* stretched maze old code
	// Control rgb output
	assign rgb_next = path_on(x_pos, y_pos, 0, 0) ? 8'b11111111 :
							path_on(x_pos, y_pos, 0, 1) ? 8'b11111111 :
							path_on(x_pos, y_pos, 0, 2) ? 8'b11111111 :
							path_on(x_pos, y_pos, 0, 3) ? 8'b11111111 :
							path_on(x_pos, y_pos, 1, 0) ? 8'b11111111 :
							path_on(x_pos, y_pos, 1, 1) ? 8'b11111111 :
							path_on(x_pos, y_pos, 1, 2) ? 8'b11111111 :
							path_on(x_pos, y_pos, 1, 3) ? 8'b11111111 :
							path_on(x_pos, y_pos, 2, 0) ? 8'b11111111 :
							path_on(x_pos, y_pos, 2, 1) ? 8'b11111111 :
							path_on(x_pos, y_pos, 2, 2) ? 8'b11111111 :
							path_on(x_pos, y_pos, 2, 3) ? 8'b11111111 :
							path_on(x_pos, y_pos, 3, 0) ? 8'b11111111 :
							path_on(x_pos, y_pos, 3, 1) ? 8'b11111111 :
							path_on(x_pos, y_pos, 3, 2) ? 8'b11111111 :
							path_on(x_pos, y_pos, 3, 3) ? 8'b11111111 :
							8'b00000000;
	
	function path_on;
		input [9:0] x;
		input [9:0] y;
		input [9:0] i;
		input [9:0] j;
		begin
			if (i*DIV_640(maze_width) <= x &&
				 i*DIV_640(maze_width) + DIV_640(maze_width) > x &&
				 j*DIV_480(maze_height) <= y &&
				 j*DIV_480(maze_height) + DIV_480(maze_height) > y &&
				 path_array[i][j] == 1)
				path_on = 1;
			else
				path_on = 0;
		end
	endfunction
	
	function [9:0] DIV_640;
		input [4:0] a;
		begin
			case (a)
				1: DIV_640 = 640;
				2: DIV_640 = 320;
				3: DIV_640 = 213;
				4: DIV_640 = 160;
				5: DIV_640 = 128;
				6: DIV_640 = 106;
				7: DIV_640 = 91;
				8: DIV_640 = 80;
				9: DIV_640 = 71;
				10: DIV_640 = 64;
				11: DIV_640 = 58;
				12: DIV_640 = 53;
				13: DIV_640 = 49;
				14: DIV_640 = 45;
				15: DIV_640 = 42;
				16: DIV_640 = 40;
				17: DIV_640 = 37;
				18: DIV_640 = 35;
				19: DIV_640 = 33;
				20: DIV_640 = 32;
				default: DIV_640 = 0;
			endcase
		end
	endfunction
	
	function [9:0] DIV_480;
		input [4:0] a;
		begin
			case (a)
				1: DIV_480 = 480;
				2: DIV_480 = 240;
				3: DIV_480 = 160;
				4: DIV_480 = 120;
				5: DIV_480 = 96;
				6: DIV_480 = 80;
				7: DIV_480 = 68;
				8: DIV_480 = 60;
				9: DIV_480 = 53;
				10: DIV_480 = 48;
				11: DIV_480 = 43;
				12: DIV_480 = 40;
				13: DIV_480 = 36; //36.923
				14: DIV_480 = 34;
				15: DIV_480 = 32;
				16: DIV_480 = 30;
				17: DIV_480 = 28;
				18: DIV_480 = 26;
				19: DIV_480 = 25;
				20: DIV_480 = 24;
				default: DIV_480 = 0;
			endcase
		end
	endfunction
*/
endmodule

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
	input [16*16-1:0] path_data,
	input wire [4:0] maze_width, maze_height,
	input wire [4:0] tile_width, tile_height,
	input wire [4:0] start_x, start_y,
	input wire [4:0] finish_x, finish_y,
    output wire hsync, vsync,		// horizontal and vertical switch outputs
    output wire [7:0] rgb			// Red, green, blue output
   );
	
	wire video_on;
	
	reg [7:0] char_color   = 8'b000_000_11;
	reg [7:0] start_color  = 8'b000_111_00;
	reg [7:0] finish_color = 8'b111_000_00;
	reg [15:0] char_array  = { 4'b0110 ,
	                           4'b1111 ,
	                           4'b1111 ,
	                           4'b0110 };

   reg [7:0] rgb_reg;
	reg [7:0] rgb_next;
	// colors are the colors of the rainbow roygbiv
//	reg [7:0] c1 = 8'b11000100, c2 = 8'b11110000, c3 = 8'b11111100,
//				 c4 = 8'b00011100, c5 = 8'b00001111, c6 = 8'b00000001,
//				 c7 = 8'b10000011, c8 = 8'b11000110;
				 
	// x and y position wire variables
	wire [9:0] x_pos, y_pos;
	//parameter wtime = 5_000_000;

	// pixel parameters
	wire [9:0] tile_pixel_w = 1 << tile_width;
	wire [9:0] tile_pixel_h = 1 << tile_height;
	wire [9:0] maze_pixel_w = tile_pixel_w*maze_width;
	wire [9:0] maze_pixel_h = tile_pixel_h*maze_height;
	wire [9:0] maze_border_x = (640 - maze_pixel_w) >> 1;
	wire [9:0] maze_border_y = (480 - maze_pixel_h) >> 1;
	
	// tile parameters
	wire [4:0] tile_x = x_pos >> tile_width;
	wire [4:0] tile_y = y_pos >> tile_height;
	wire [4:0] centered_tile_x = (x_pos - maze_border_x) >> tile_width;
	wire [4:0] centered_tile_y = (y_pos - maze_border_y) >> tile_height;
	
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
				// character on centered screen
				else if (char_x == centered_tile_x &&
							char_y == centered_tile_y &&
							char_array[  ((x_pos - maze_border_x - centered_tile_x*tile_pixel_w) >> (tile_width - 2)) +
										  4*((y_pos - maze_border_y - centered_tile_y*tile_pixel_h) >> (tile_height - 2))] == 1)
					rgb_next <= char_color;
				else if (start_x == centered_tile_x &&
				         start_y == centered_tile_y)
					rgb_next <= start_color;
				else if (finish_x == centered_tile_x &&
				         finish_y == centered_tile_y)
					rgb_next <= finish_color;
				else if (path_data[   centered_tile_x +
								   16*centered_tile_y ] == 1)
						rgb_next <= 8'b11111111;
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

endmodule

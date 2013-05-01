/***********************************************
*  ECE324 Digital Systems Design:  Maze Generator
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
    input wire clk, reset, enable,			    // input clock and reset
	input wire start_screen, maze_screen,       // which screen to display
	input [6:0] char_x, char_y,                 // location of character
	input [16*16-1:0] path_data,                // maze data to display
	input wire [4:0] maze_width, maze_height,   // width and height of maze (in #tiles)
	input wire [4:0] tile_width, tile_height,   // 2^THIS_NUMBER is the width and height of tiles (in #pixels)
	input wire [4:0] start_x, start_y,          // location in maze to put start
	input wire [4:0] finish_x, finish_y,        // location in maze to put finish 
    output wire hsync, vsync,		            // horizontal and vertical switch outputs
    output wire [7:0] rgb			            // Red, green, blue output
   );
	
	wire video_on;  // vga_sync enables output
	
//  *************
//  PIXEL OUTUPUT
//  *********************************************************
	wire [7:0] start_rgb;   // current output of start screen
    reg [7:0] rgb_reg;  // current output of maze screen
	reg [7:0] rgb_next; // next output of maze screen
    
	wire [9:0] x_pos, y_pos; // position of current pixel being written to
//  **********************************************************************
	
//  ***********
//  DEFINITIONS
//  ***************************************
    // Color definitions
	reg [7:0] char_color   = 8'b000_000_11;
	reg [7:0] start_color  = 8'b000_111_00;
	reg [7:0] finish_color = 8'b111_000_00;
    
    // Bitmap for character
	reg [15:0] char_array  = { 4'b0110 ,
	                           4'b1111 ,
	                           4'b1111 ,
	                           4'b0110 };
//  *************************************
				 
//  ******************
//  LOGICAL PARAMETERS
//  ******************************************
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
//  ********************************************************************
	
//  ***************
//  DISPLAY CONTROL
//  ***************************
	always @(posedge clk) begin
	
		if (enable) // enables display
            
//          ********************
//          OBJECT DISPLAY LOGIC
//          ***********************************************************************************
			if (maze_pixel_w <= 640 && maze_pixel_h <= 480) // don't display if maze is too big
                // maze borders
                if (x_pos >= maze_pixel_w + maze_border_x ||    // don't display if outside of maze borders
                    x_pos < maze_border_x ||
                    y_pos >= maze_pixel_h + maze_border_y ||
                    y_pos < maze_border_y)
                    rgb_next <= 8'b00000000;
                // character
                else if (char_x == centered_tile_x &&
                         char_y == centered_tile_y &&
                         char_array[  ((x_pos - maze_border_x - centered_tile_x*tile_pixel_w) >> (tile_width - 2)) +
                                    4*((y_pos - maze_border_y - centered_tile_y*tile_pixel_h) >> (tile_height - 2))] == 1)
                    rgb_next <= char_color;
                // start tile
                else if (start_x == centered_tile_x &&
                        start_y == centered_tile_y)
                    rgb_next <= start_color;
                // finish tile
                else if (finish_x == centered_tile_x &&
                        finish_y == centered_tile_y)
                    rgb_next <= finish_color;
                // carved path
                else if (path_data[   centered_tile_x +
                                16*centered_tile_y ] == 1)
                        rgb_next <= 8'b11111111;
                // wall or uncarved
                else
                    rgb_next <= 8'b00000000;
//              ****************************

        else
            rgb_next <= 8'b00000000;
    end
	
    // fon
    font_test_gen START_SCREEN(
        .display(display),
        .clk(clk),                  // clock input
        .video_on(start_screen),    // enable display
        .pixel_x(x_pos),            // current position of pixel being written to
        .pixel_y(y_pos),
        .rgb_text(start_rgb)        // current color of output
    );
	
    vga_sync VGAS(
        .clk(clk),              // clock input
        .reset(reset),		    // reset input
        .hsync(hsync),          // VGA inputs
        .vsync(vsync),
        .video_on(video_on),    // enable vga_sync
        .p_tick(),              
        .pixel_x(x_pos),        // set current pixel being written to
        .pixel_y(y_pos)
    );	

    always @(negedge clk) begin
        rgb_reg <= rgb_next;    // update current color output
    end
		
    assign rgb = (video_on & start_screen)? start_rgb   :   // assign color to start screen
                 (video_on & maze_screen)? rgb_reg      :   // assign color to maze screen
                 8'b0;

endmodule

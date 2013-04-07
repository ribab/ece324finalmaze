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
	 input [100*100-1:0] path_data,
	 input wire [4:0] maze_width, maze_height,
	 input wire [9:0] x_coord, y_coord,
	 input wire [7:0] tile_width, tile_height,
    output wire hsync, vsync,		// horizontal and vertical switch outputs
    output wire [7:0] rgb			// Red, green, blue output
   );

   //signal declaration
//	wire [100-1:0] path_array [100-1:0];
//	assign path_array[0] = path_data[99:0];
//	assign path_array[1] = path_data[199:100];
//	assign path_array[2] = path_data[299:200];
//	assign path_array[3] = path_data[399:300];
//	assign path_array[4] = path_data[499:400];
//	assign path_array[5] = path_data[599:500];
//	assign path_array[6]
	
	wire video_on;

   reg [7:0] rgb_reg;
	reg [7:0] rgb_next;
	// colors are the colors of the rainbow roygbiv
	reg [7:0] c1 = 8'b11000100, c2 = 8'b11110000, c3 = 8'b11111100,
				 c4 = 8'b00011100, c5 = 8'b00001111, c6 = 8'b00000001,
				 c7 = 8'b10000011, c8 = 8'b11000110;
				 
	// x and y position wire variables
	wire [9:0] x_pos, y_pos;
	//parameter wtime = 5_000_000;

	always @(negedge clk) begin
		rgb_reg <= rgb_next;
	end
		
   // output
   assign rgb = (video_on) ? rgb_reg : 8'b0;

	always @(posedge clk) begin
		if (path_data[    ((x_pos - x_coord) >> tile_width) +
		              100*((y_pos - y_coord) >> tile_height)  ]
						  == 1)
/*		if (path_array[(x_pos - x_coord) >> tile_width]
						  [(y_pos - y_coord) >> tile_height] == 1) */
			rgb_next <= 8'b00000000;
		else
			rgb_next <= 8'b11111111;
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

/* stretched maze
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

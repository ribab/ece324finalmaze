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
	 input wire [7:0] sw,
    input wire clk, reset, enable,			// input clock and reset
	 input wire [8:0] path_data,
	 input wire [2:0] maze_width, maze_height,
    output wire hsync, vsync,		// horizontal and vertical switch outputs
    output wire [7:0] rgb			// Red, green, blue output
   );

   //signal declaration
	wire [2:0] path_array [2:0];
	assign path_array[0] = {path_data[2:0]};
	assign path_array[1] = {path_data[5:3]};
	assign path_array[2] = {path_data[8:6]};
	
	wire video_on;

   reg [7:0] rgb_reg;
	wire [7:0] rgb_next;
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
	
   // output
   assign rgb = (video_on) ? rgb_reg : 8'b0;
	
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
	
	function path_on;
		input x;
		input y;
		input i;
		input j;
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
	
	function  DIV_640;
		input a;
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
	
	function  DIV_480;
		input a;
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

endmodule

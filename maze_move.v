/*****************************
module to move character for random maze generator
April 9, 2013
******************************/


module maze_move
   (
	input wire clk,
	input wire reset,
	input wire enable,
    input wire [7:0] key_code,
	input wire [16*16-1 :0] maze_data,
	input wire [4:0] maze_width, 
	input wire [4:0] maze_height,
	input wire [3:0] start_x, 
	input wire [3:0] start_y,
	output reg [3:0] curr_x,
	output reg [3:0] curr_y
   );
	
	// TODO: check these
/*	parameter [7:0] LEFT = 8'b11010110;
	parameter [7:0] RIGHT = 8'b11101000;
	parameter [7:0] UP = 8'b11101010;
	parameter [7:0] DOWN = 8'b11100100;
*/
	parameter [6:0] LEFT = 7'b1101011;
	parameter [6:0] RIGHT = 7'b1110100;
	parameter [6:0] UP = 7'b1110101;
	parameter [6:0] DOWN = 7'b1110010;
	
	parameter [25:0] slow_time = 10_000_000;
	
	reg move_up = 0;
	reg move_down = 0;
	reg move_right = 0;
	reg move_left = 0;
	
	reg [25:0] slow_count = 0;
	
	// Left arrow is Left, Up arrow is Up, Right arrow is Right, Down arrow is Down
	always @(posedge clk) begin
	   
		if(key_code[6:0] == LEFT) begin
			move_left <= ~move_left;
		end
		if(key_code[6:0] == RIGHT) begin
			move_right <= ~move_right;
		end
		if(key_code[6:0] == UP) begin
			move_up <= ~move_up;
		end
		if(key_code[6:0] == DOWN) begin
			move_down <= ~move_down;
		end
	   
		if (slow_count == slow_time) begin 
			if (key_code[6:0] == LEFT) 	begin
				if(maze_data[(curr_x - 1)+16*(curr_y)] == 1 && curr_x != 0)
					begin
						curr_x <= curr_x - 1; //move left
					end
				end
			if (key_code[6:0] == RIGHT)	begin
				if(maze_data[(curr_x + 1)+16*(curr_y)] == 1 && curr_x != maze_width)
					begin
						curr_x <= curr_x + 1;//move right
					end
				end
			if (key_code[6:0] == UP) begin
				if(maze_data[(curr_x)+16*(curr_y - 1)] == 1 && curr_y != 0)
					begin
						curr_y <= curr_y - 1; //move up
					end
				end
			if (key_code[6:0] == DOWN)	begin
				if(maze_data[(curr_x)+16*(curr_y + 1)] == 1 && curr_y != maze_height)
					begin
						curr_y <= curr_y + 1;//move down
					end
				end
			slow_count <= 0;
		end
	end
endmodule
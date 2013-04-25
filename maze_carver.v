
module maze_carver
	(
		input clk,
		input start,
		input wire [2:0] x_dimension,
		input wire [2:0] y_dimension,
		output reg [64*128-1:0] maze_data,
	
	// output reg [63:0] maze_array  [0:64*64-1],
	
	
	
		output reg finish
	);
	
	
	reg [15:0] i;
	reg [15:0] j;
	reg [15:0] start_x;
	reg [15:0] start_y;
	reg [1:0] rand;
	reg [1:0] dir_dist;
	reg [15:0] curr_x;
	reg [15:0] curr_y;
	reg [1:0] next_state;
	parameter [8:0] maze_width = 128;
	parameter [8:0] maze_height = 64;
	
	reg [6:0] stack_x [64*64-1:0];
	reg [6:0] stack_y [64*64-1:0];	
	
	reg [11:0] stack_pos = 0;

	initial begin
		finish = 0;
		for (i = 0; i < 128; i = i + 1)
			for (j = 0; j < 64; j = j + 1)
				maze_data [i + 128*j] = 0;
		start_x = 0;
		start_y = 0;
		//         X     Y          X     Y
		maze_data [0*2 + 0*128 + 1: 0*2 + 0*128] = PATH;
		curr_x = start_x;
		curr_y = start_y;
		
		push (start_x, start_y);
	end
	
	//  Key
	// 
	//  path = maze path = 2'b11
	//	out = maze wall = 2'b00
	//  frontier = 2'b10
	//	 wall = 2'b01
	
	localparam [1:0] PATH = 2'b11;
	localparam [1:0] OUT = 2'b00;
	localparam [1:0] FRONTIER = 2'b10;
	localparam [1:0] WALL = 2'b01;
	
	// instantiate rand_num
	rand_num RN(
		.clk(clk), .reset(reset), .rand(rand)
    );
	
	always @ (posedge clk) begin
	
		if (finish == 0) begin
		
			if (start == 1 && finish == 0) begin
				// MAKE FRONTIER or wall
				// change right into frontier
				// if current position is a path, and is in bounds, and position to right is not a wall or a path
				if (curr_x < maze_width - 1 && maze_data_check(curr_x + 1, curr_y) != PATH)
					if (maze_data_check(curr_x + 1, curr_y + 1) == 2'b11 || maze_data_check(curr_x + 1, curr_y - 1) == 2'b11 ||
						maze_data_check(curr_x + 2, curr_y) == 2'b11)
						maze_data [(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] = WALL;
					else
						maze_data [(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] = FRONTIER;
				// change left into frontier
				if (curr_x > 0 && maze_data_check(curr_x - 1, curr_y) != PATH)
					if (maze_data_check(curr_x - 1, curr_y + 1) == 2'b11 || maze_data_check(curr_x - 1, curr_y - 1) == 2'b11 ||
						maze_data_check(curr_x - 2, curr_y) == 2'b11)
						maze_data [(curr_x - 1)*2 + (curr_y)*128 + 1 : (curr_x - 1)*2 + (curr_y)*128] = WALL;
					else
						maze_data [(curr_x - 1)*2 + (curr_y)*128 + 1 : (curr_x - 1)*2 + (curr_y)*128] = FRONTIER;
				// change down into frontier
				if (curr_y < maze_height - 1 && maze_data_check(curr_x, curr_y + 1) != PATH)
					if (maze_data_check(curr_x - 1, curr_y + 1) == 2'b11 || maze_data_check(curr_x + 1, curr_y + 1) == 2'b11 ||
						maze_data_check(curr_x, curr_y + 2) == 2'b11)
						maze_data [(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] = WALL;
					else
						maze_data [(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] = FRONTIER;
				// change up into frontier
				if (curr_y > 0 && maze_data_check(curr_x, curr_y - 1) != PATH)
					if (maze_data_check(curr_x + 1, curr_y - 1) == 2'b11 || maze_data_check(curr_x - 1, curr_y - 1) == 2'b11 ||
						maze_data_check(curr_x, curr_y - 2) == 2'b11)
						maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] = WALL;
					else
						maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] = FRONTIER;
			end
	
			// MOVE RANDOM DIRECTION AND PUSH TO STACK
			case (rand)
				// move right
				2'b00 :	if (curr_x < maze_width - 1 && maze_data_check(curr_x + 1, curr_y) == FRONTIER) begin
							maze_data [(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] = PATH;
							curr_x = curr_x + 1;
							push (curr_x, curr_y);
						end
				// move left
				2'b01 :	if (curr_x > 0 && maze_data_check(curr_x - 1, curr_y) == FRONTIER) begin
							maze_data [(curr_x - 1)*2 + (curr_y)*128 + 1 : (curr_x - 1)*2 + (curr_y)*128] = PATH;
							curr_x = curr_x - 1;
							push (curr_x, curr_y);
						end
				// move down
				2'b10 : if (curr_y < maze_height - 1 && maze_data_check(curr_x, curr_y + 1) == FRONTIER) begin
							maze_data [(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] = PATH;
							curr_y = curr_y + 1;
							push (curr_x, curr_y);
						end
				// move up
				2'b11 : if (maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] == FRONTIER) begin
							maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] = PATH;
							curr_y = curr_y - 1;
							push (curr_x, curr_y);
						end
			endcase
		
			// IF ALL WALLS OR PATHS BY POS, POP STACK]
			// if current position is a path, and is in bounds, and position to right is not a wall or a path
			if ((curr_x == maze_width - 1  || maze_data_check(curr_x + 1, curr_y) == WALL || maze_data_check(curr_x + 1, curr_y) == PATH) &&
				(curr_x == 0               || maze_data_check(curr_x - 1, curr_y) == WALL || maze_data_check(curr_x - 1, curr_y) == PATH) &&
				(curr_y == maze_hegiht - 1 || maze_data_check(curr_x, curr_y + 1) == WALL || maze_data_check(curr_x, curr_y + 1) == PATH) &&
				(curr_y == 0               || maze_data_check(curr_x, curr_y - 1) == WALL || maze_data_check(curr_x, curr_y - 1) == PATH))
				pop(curr_x, curr_y);
		
			// CONTINUE LOOP UNTIL STACK IS EMPTY
			if (stack_pos == 0)
				finish = 1;
		end
		
	end
		
	function push;
		input [6:0] x_pos;
		input [6:0] y_pos;
		begin
			stack_pos = stack_pos + 1;
			stack_x [stack_pos - 1] = x_pos;
			stack_y [stack_pos - 1] = y_pos;
		end
	endfunction
		
	function pop;
		output [6:0] x_pos;
		output [6:0] y_pos;
		begin
			stack_pos = stack_pos - 1;
			x_pos = stack_x [stack_pos];
			y_pos = stack_y [stack_pos];
		end
	endfunction
	
	function [1:0] maze_data_check;
		input clk;
		input reg [15:0] reg_x;
		input reg [15:0] reg_y;
		begin
		maze_data_check = maze_data [(reg_x)*2 + (reg_y)*128 + 1 : (reg_x)*2 + (reg_y)*128];
		end
	endfunction
	
	function [1:0] maze_data_check_m;
		input clk;
		input reg [15:0] reg_x;
		input reg [15:0] reg_y;
		begin
		maze_data_check = maze_data [(reg_x)*2 + (reg_y)*128 + 1];
		end
	endfunction
	
	function maze_data_check_l;
		input clk;
		input reg [15:0] reg_x;
		input reg [15:0] reg_y;
		begin
		maze_data_check = maze_data [(reg_x)*2 + (reg_y)*128];
		end
	endfunction
	
endmodule


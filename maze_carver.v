
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
	

	initial begin
		for (i = 0; i < 128; i = i + 1)
			for (j = 0; j < 64; j = j + 1)
				maze_data [i + 128*j] = 0;
		start_x = 0;
		start_y = 0;
		//         X     Y          X     Y
		maze_data [0*2 + 0*128 + 1: 0*2 + 0*128] = PATH;
		curr_x = start_x;
		curr_y = start_y;
	end
	
	//  Key
	// 
	//  path = maze path = PATH
	//	out = maze wall = OUT
	//  frontier FRONTIER
	//	 wall = WALL
	
	localparam [1:0] PATH = PATH;
	localparam [1:0] OUT = OUT;
	localparam [1:0] FRONTIER = FRONTIER;
	localparam [1:0] WALL = WALL;
	
	always @ (posedge clk) begin
		if (start == 1 && finish == 0) begin
// MAKE FRONTIER or wall
		// change right into frontier
			// if current position is a path, and is in bounds, and position to right is not a wall or a path
			if (curr_x < maze_width - 1 && maze_data_check(curr_x + 1, curr_y) != PATH)
				if (maze_data_check_m(curr_x + 1, curr_y + 1) == 0 && maze_data_check_m(curr_x + 1, curr_y - 1) == 0 &&
					maze_data_check_m(curr_x + 2, curr_y) == 0)
					maze_data [(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] = FRONTIER;
				else
					maze_data [(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] = WALL;
		// change left into frontier
			if (curr_x > 0 && maze_data_check(curr_x - 1, curr_y) != PATH)
				if (maze_data_check_m(curr_x - 1, curr_y + 1) == 0 && maze_data_check_m(curr_x - 1, curr_y - 1) == 0 &&
					maze_data_check_m(curr_x - 2, curr_y) == 0)
					maze_data [(curr_x - 1)*2 + (curr_y)*128 + 1 : (curr_x - 1)*2 + (curr_y)*128] = FRONTIER;
				else
					maze_data [(curr_x - 1)*2 + (curr_y)*128 + 1 : (curr_x - 1)*2 + (curr_y)*128] = WALL;
		// change down into frontier
			if (curr_y < maze_height - 1 && maze_data_check(curr_x, curr_y + 1) != PATH)
				if (maze_data_check_m(curr_x - 1, curr_y + 1) == 0 && maze_data_check_m(curr_x + 1, curr_y + 1) == 0 &&
					maze_data_check_m(curr_x, curr_y + 2) == 0)
					maze_data [(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] = FRONTIER;
				else
					maze_data [(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] = WALL;
		// change up into frontier
			if (curr_y > 0 && maze_data_check(curr_x, curr_y - 1)* != PATH)
				if (maze_data_check_m(curr_x + 1, curr_y - 1) == 0 && maze_data_check_m(curr_x - 1, curr_y - 1) == 0 &&
					maze_data_check_m(curr_x, curr_y - 2) == 0)
					maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] = FRONTIER;
				else
					maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] = WALL;
		end
		
// MOVE RANDOM DIRECTION 
		case (rand)
			// move right
			2'b00 :	if (curr_x < maze_width - 1 && maze_data_check(curr_x + 1, curr_y) == FRONTIER) begin
						maze_data [(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] = PATH;
						curr_x = curr_x + 1;
					end
			// move left
			2'b01 :	if (curr_x > 0 && maze_data_check(curr_x - 1, curr_y) == FRONTIER) begin
						maze_data [(curr_x - 1)*2 + (curr_y)*128 + 1 : (curr_x - 1)*2 + (curr_y)*128] = PATH;
						curr_x = curr_x - 1;
					end
			// move down
			2'b10 : if (curr_y < maze_height - 1 && maze_data_check(curr_x, curr_y + 1) == FRONTIER) begin
						maze_data [(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] = PATH;
						curr_y = curr_y + 1;
					end
			// move up
			2'b11 : if (maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] == FRONTIER) begin
						maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] = PATH;
						curr_y = curr_y - 1;
					end
		endcase
		
		// PUSH TO STACK IF POS MOVED
		
		// IF ALL WALLS OR PATHS BY POS, POP STACK

		// CONTINUE LOOP UNTIL STACK IS EMPTY
		
	end
		
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


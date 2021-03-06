
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
	wire [1:0] rand;
	reg [1:0] dir_dist;
	reg [15:0] curr_x;
	reg [15:0] curr_y;
	reg [15:0] curr_x_p1;
	reg [15:0] curr_y_p1;
	reg [15:0] curr_x_p2;
	reg [15:0] curr_y_t128;
	reg [10:0] curr_y_t128_p1;
	reg [15:0] curr_x_m1;
	reg [15:0] curr_y_m1;
	reg [15:0] curr_x_m2;
	reg [15:0] curr_y_m2;
	reg [15:0] curr_x_t2;
	reg [15:0] curr_x_p1_t2;
	reg [15:0] curr_y_p1_t128;
	reg [15:0] curr_y_p1_t128_p1;
	reg [15:0] curr_y_m1_t128_p1;
	reg [15:0] curr_x_m1_t2;
	reg [15:0] curr_y_m1_t128;
	
	reg [1:0] next_state;
	parameter [8:0] maze_width = 128;
	parameter [8:0] maze_height = 64;
	
	reg [6:0] stack_x [64*64-1:0];
	reg [6:0] stack_y [64*64-1:0];	
	
	reg [11:0] stack_pos = 1;

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


	initial begin
		finish = 0;
		for (i = 0; i < 128; i = i + 1)
			for (j = 0; j < 64; j = j + 1)
				maze_data [i + 128*j] = 0;
		for (i = 0; i < 64; i = i + 1)
			for (j = 0; j < 64; j = j + 1) begin
				stack_x [i + 64*j] = 0;
				stack_y [i + 64*j] = 0;
			end
		start_x = 0;
		start_y = 0;
		//         X     Y          X     Y
		maze_data [0*2 + 0*128 + 1: 0*2 + 0*128] = PATH;
		curr_x 			= start_x;
		curr_y 			= start_y;

		
		stack_x [0] = start_x;
		stack_y [0] = start_y;
	end
	
	
	
	// instantiate rand_num
	rand_num RN(
		.clk(clk), .reset(reset), .rand(rand)
    );
	
	always @ (posedge clk) begin
		curr_x_p1			= curr_x + 1;
		curr_y_p1			= curr_y + 1;
		curr_x_m1	 		= curr_x - 1;
		curr_y_m1 			= curr_y - 1;
		curr_x_p2			= curr_x + 2;
		curr_x_m2			= curr_x - 2;
		curr_y_m2			= curr_y - 2;
		curr_x_t2			= curr_x * 2;
		curr_y_t128			= curr_y * 128;
		curr_y_t128_p1		= curr_y_t128 + 1;
		curr_x_p1_t2		= curr_x_p1 * 2;
		curr_y_p1_t128		= curr_y_p1 * 128;
		curr_x_m1_t2		= curr_x_m1 * 2;
		curr_y_m1_t128		= curr_y_m1 * 128;
		curr_y_p1_t128_p1 = (curr_y + 1)*128 + 1;
		curr_y_m1_t128_p1	= (curr_y - 1)*128 + 1;
	
		if (finish == 0) begin
		
			if (start == 1 && finish == 0) begin
				// MAKE FRONTIER or wall
				// change right into frontier
				// if current position is a path, and is in bounds, and position to right is not a wall or a path
				if (curr_x < maze_width - 1 && maze_data_check(curr_x + 1, curr_y) != PATH)
					if (maze_data_check(curr_x_p1, curr_y_p1) == 2'b11 || 
						 maze_data_check(curr_x_p1, curr_y_m1) == 2'b11 ||
						 maze_data_check(curr_x_p2, curr_y) 	== 2'b11) begin
						maze_data [curr_x_p1_t2 + curr_y_t128_p1]		= 0;
						maze_data [curr_x_p1_t2 + curr_y_t128] 		= 1;
						end
					else begin
						maze_data [curr_x_p1_t2 + curr_y_t128_p1]		= 1;
						maze_data [curr_x_p1_t2 + curr_y_t128] 		= 0;
						end
				// change left into frontier
				if (curr_x > 0 && maze_data_check(curr_x - 1, curr_y) != PATH)
					if (maze_data_check(curr_x_m1, curr_y_p1) == 2'b11 || 
						 maze_data_check(curr_x_m1, curr_y_m1) == 2'b11 ||
						 maze_data_check(curr_x_m2, curr_y) 	== 2'b11) begin
						maze_data [curr_x_m1_t2 + curr_y_t128_p1]		= 0;
						maze_data [curr_x_m1_t2 + curr_y_t128] 		= 1;
						end
					else begin	
						maze_data [curr_x_m1_t2 + curr_y_t128_p1]		= 1;
						maze_data [curr_x_m1_t2 + curr_y_t128] 		= 0;
						end
				// change down into frontier
				if (curr_y < maze_height - 1 && maze_data_check(curr_x, curr_y_p1) != PATH)
					if (maze_data_check(curr_x_m1, curr_y_p1) == 2'b11 || 
						 maze_data_check(curr_x_p1, curr_y_p1) == 2'b11 ||
						 maze_data_check(curr_x, curr_y_p1) 	== 2'b11) begin
						maze_data [curr_x_t2 + curr_y_p1_t128_p1]		= 0;
						maze_data [curr_x_t2 + curr_y_p1_t128] 		= 1;
						end
					else begin
						maze_data [curr_x_t2 + curr_y_p1_t128_p1] 	= 1;
						maze_data [curr_x_t2 + curr_y_p1_t128] 		= 0;
						end
				// change up into frontier
				if (curr_y > 0 && maze_data_check(curr_x, curr_y - 1) != PATH)
					if (maze_data_check(curr_x_p1, curr_y_m1) == 2'b11 || 
						 maze_data_check(curr_x_m1, curr_y_m1) == 2'b11 ||
						 maze_data_check(curr_x, curr_y_m2) 	== 2'b11) begin
						maze_data [curr_x_t2 + curr_y_m1_t128_p1] 	= 0;
						maze_data [curr_x_t2 + curr_y_m1_t128] 		= 1;
						end
					else begin
						maze_data [curr_x_t2 + curr_y_m1_t128_p1] 	= 1;
						maze_data [curr_x_t2 + curr_y_m1_t128] 		= 0;
						end
			end
	
			// MOVE RANDOM DIRECTION AND PUSH TO STACK
			case (rand)
				// move right
				2'b00 :	if (curr_x < maze_width - 1 && maze_data_check(curr_x + 1, curr_y) == FRONTIER) begin
							maze_data [curr_x_p1_t2 + curr_y_t128_p1] 	= 1;
							maze_data [curr_x_p1_t2 + curr_y_t128] 		= 1;
							curr_x = curr_x_p1;
							stack_pos = stack_pos + 1;
							stack_x [stack_pos - 1] = curr_x;
							stack_y [stack_pos - 1] = curr_y;
						end
				// move left
				2'b01 :	if (curr_x > 0 && maze_data_check(curr_x - 1, curr_y) == FRONTIER) begin
							maze_data [curr_x_m1_t2 + curr_y_t128_p1] 	= 1;
							maze_data [curr_x_m1_t2 + curr_y_t128] 		= 1;
							curr_x = curr_x - 1;
							stack_pos = stack_pos + 1;
							stack_x [stack_pos - 1] = curr_x;
							stack_y [stack_pos - 1] = curr_y;
						end
				// move down
				2'b10 : if (curr_y < maze_height - 1 && maze_data_check(curr_x, curr_y + 1) == FRONTIER) begin
							maze_data [curr_x_t2 + curr_y_p1_t128_p1] 	= 1;
							maze_data [curr_x_t2 + curr_y_p1_t128] 		= 1;
							curr_y = curr_y + 1;
							stack_pos = stack_pos + 1;
							stack_x [stack_pos - 1] = curr_x;
							stack_y [stack_pos - 1] = curr_y;
						end
				// move up
				2'b11 : if (curr_y > 0 && maze_data_check(curr_x, curr_y_m1) == FRONTIER) begin
							maze_data [curr_x_t2 + curr_y_m1_t128_p1] 	= 1;
							maze_data [curr_x_t2 + curr_y_m1_t128] 		= 1;
							curr_y 		= curr_y - 1;
							stack_pos 	= stack_pos + 1;
							stack_x [stack_pos - 1] = curr_x;
							stack_y [stack_pos - 1] = curr_y;
						end
			endcase
		
			// IF ALL WALLS OR PATHS BY POS, POP STACK]
			// if current position is a path, and is in bounds, and position to right is not a wall or a path
			if ((curr_x == maze_width - 1  || maze_data_check(curr_x_p1, curr_y) == WALL || maze_data_check(curr_x_p1, curr_y) == PATH) &&
				(curr_x 	== 0               || maze_data_check(curr_x_m1, curr_y) == WALL || maze_data_check(curr_x_m1, curr_y) == PATH) &&
				(curr_y 	== maze_height - 1 || maze_data_check(curr_x, curr_y_p1) == WALL || maze_data_check(curr_x, curr_y_p1) == PATH) &&
				(curr_y 	== 0               || maze_data_check(curr_x, curr_y_m1) == WALL || maze_data_check(curr_x, curr_y_m1) == PATH)) begin
				stack_pos 	= stack_pos - 1;
				curr_x 		= stack_x [stack_pos];
				curr_y 		= stack_y [stack_pos];
			end
		
			// CONTINUE LOOP UNTIL STACK IS EMPTY
			if (stack_pos == 0)
				finish = 1;
		end
		
	end
	
	function [1:0] maze_data_check;
		input reg [15:0] reg_x;
		input reg [15:0] reg_y;
		
		reg [15:0] reg_x_t2		= (reg_x) * 2;
		reg [15:0] reg_y_t128	= (reg_y) * 128;
		reg [15:0] reg_y_t128_p1	= (reg_y) * 128 + 1;
		begin
//		assign reg_x_t2 		= (reg_x) * 2;
//		assign reg_y_t128		= (reg_y) * 128;
//		assign reg_y_t128_p1	= (reg_y) * 128 + 1;
		
		maze_data_check = {maze_data [reg_x_t2 + reg_y_t128_p1], maze_data [reg_x_t2 + reg_y_t128]};
		end
	endfunction
	
//	function maze_data_check_m;
//		input reg [15:0] reg_x;
//		input reg [15:0] reg_y;
//		begin
//		maze_data_check = maze_data [(reg_x)*2 + (reg_y)*128 + 1];
//		end
//	endfunction
//	
//	function maze_data_check_l;
//		input reg [15:0] reg_x;
//		input reg [15:0] reg_y;
//		begin
//		maze_data_check = maze_data [(reg_x)*2 + (reg_y)*128];
//		end
//	endfunction
//	
endmodule


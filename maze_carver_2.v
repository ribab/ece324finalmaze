
module maze_carver_2
	(
		input clk,
		input start,
		input wire [2:0] x_dimension,
		input wire [2:0] y_dimension,
		output reg [16*16-1:0] maze_data,
	
	// output reg [63:0] maze_array  [0:64*64-1],
	
	
	
		output reg finish
	);
	
	
	reg [5:0] i;
	reg [5:0] j;
	reg [4:0] start_x;
	reg [4:0] start_y;
	wire [1:0] rand;
	reg [1:0] dir_dist;
	
	reg [4:0] curr_x;
	reg [4:0] curr_y;
	
	parameter [5:0] maze_width = 16;
	parameter [5:0] maze_height = 16;
	
	reg [4:0] stack_x [16*16-1:0];
	reg [4:0] stack_y [16*16-1:0];	
	
	reg [7:0] stack_pos = 1;

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
		// initialize finish to "not finished"
		finish = 0;
		// initialize maze to wall
		for (i = 0; i < 16; i = i + 1)
			for (j = 0; j < 16; j = j + 1)
				maze_data [i + 16*j] = 0;
		// initialize stack to nothing
		for (i = 0; i < 64; i = i + 1)
			for (j = 0; j < 64; j = j + 1) begin
				stack_x [i + 64*j] = 0;
				stack_y [i + 64*j] = 0;
			end
		// initialize starting position to zero
		start_x = 0;
		start_y = 0;
		// Carve out starting position
		//         X     Y          X     Y
		maze_data [0 + 0*16] = 1;
		// Initialize current carving position
		curr_x 	= start_x;
		curr_y 	= start_y;
		// Push start to stack
		stack_x [0] = start_x;
		stack_y [0] = start_y;
	end
	
	// instantiate rand_num
	// Generate random numbers on the fly
	rand_num RN(
		.clk(clk), .reset(reset), .rand(rand)
    );
	
	always @ (posedge clk) begin
	
		// Do algorithm until finished
		if (start == 1 && finish == 0) begin
		
			// MOVE RANDOM DIRECTION AND PUSH TO STACK
			case (rand)
				// move up
				2'b00 : begin
					mov_x = 5'b00000;
					if (curr_y > 0 &&
						maze_data[curr_x + (curr_y + 5'b11111)*16] == 0)
						mov_y = 5'b11111;
					else
						mov_y = 5'b00000;
				end
				// move left
				2'b01 : begin
					if (curr_x > 0 &&
						maze_data[(curr_x + 5'b11111) + curr_y*16] == 0)
						mov_x = 5'b11111;
					else
						mov_x = 5'b00000;
					mov_y = 5'b00000;
				end
				// move down
				2'b10 : begin
					mov_x = 5'b00000;
					if (curr_x < maze_height - 1 &&
						maze_data[curr_x + (curr_y + 5'b00001)*16] == 0)
						mov_y = 5'b00001;
					else
						mov_y = 5'b00000;
				end
				// move right
				2'b11 : begin
					if (curr_x > 0 &&
						maze_data[(curr_x + 5'b00001) + curr_y*16)
						mov_x = 5'b00001;
					else
						mov_x = 5'b00000;
					mov_y = 5'b00000;
				end
			endcase
				
			if (
				maze_data[curr_x + mov_x + mov_x + (curr_y + mov_y + mov_y)*16] == 0 &&
				((	mov_x = 0 &&
					maze_data[curr_x + 1 + (curr_y + mov_y)*16] == 0 &&
					maze_data[curr_x - 1 + (curr_y + mov_y)*16] == 0
				 ) ||
				 (	mov_y == 0 && 
					maze_data[curr_x + mov_x + (curr_y + 5'b00001)*16] == 0 &&
					maze_data[curr_x + mov_x + (curr_y + 5'b11111)*16] == 0
				))
			) begin
				curr_x = curr_x + mov_x;
				curr_y = curr_y + mov_y;
			end
			
			// IF SURROUNDED BY WALLS, POP STACK
			// TODO: Boundary conditions for these
			// TODO: maybe scratch this and have it just look 10 times
			//       in random directions instead
			if (
				// up
				(	maze_data[curr_x + (curr_y - 2)*16] == 1 ||
					maze_data[curr_x + 1 + (curr_y - 1)*16] == 1 ||
					maze_data[curr_x - 1 + (curr_y - 1)*16] == 1
				) &&
				// left
				(	maze_data[curr_x - 2 + curr_y*16] == 1 ||
					maze_data[curr_x - 1 + (curr_y + 1)*16] == 1 ||
					maze_data[curr_x - 1 + (curr_y - 1)*16] == 1
				) &&
				// down
				(	maze_data[curr_x + (curr_y + 2)*16] == 1 ||
					maze_data[curr_x - 1 + (curr_y + 1)*16] == 1 ||
					maze_data[curr_x + 1 + (curr_y + 1)*16] == 1
				) &&
				// right
				(	maze_data[curr_x + 2 + curr_y*16] == 1 ||
					maze_data[curr_x + 1 + (curr_y + 1)*16] == 1 ||
					maze_data[curr_x + 1 + (curr_y - 1)*16] == 1
				)
			) begin
				stack_pos = stack_pos - 1;
				curr_x = stack_x[stack_pos];
				curr_y = stack_y[stack_pos];
			end
		
			// CONTINUE LOOP UNTIL STACK IS EMPTY
			if (stack_pos == 0)
				finish = 1;
		end
		
	end
	
/*	function maze_data_check;
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
*/
	
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

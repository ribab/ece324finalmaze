
module maze_carver_2
	(
		input clk,
		input start,
		input wire [6:0] x_dimension,
		input wire [6:0] y_dimension,
		output reg [16*16-1:0] maze_data,
	
	// output reg [63:0] maze_array  [0:64*64-1],
	
		output reg finish = 0,
		
		output reg [3:0] curr_x,
		output reg [3:0] curr_y
	);
	
	// declare registers
	reg [5:0] i;
	reg [5:0] j;
	reg [3:0] start_x;
	reg [3:0] start_y;
	wire [1:0] rand;
	reg [1:0] dir_dist;
    
	// declare size of maze
    parameter [4:0] maze_width = 16;
	parameter [4:0] maze_height = 16;

    // make stack to hold memory
	reg [3:0] stack_x [16*16-1:0];
	reg [3:0] stack_y [16*16-1:0];	
	
	reg [7:0] stack_pos;
    
    
	// instantiate rand_num
	// Generate random numbers on the fly
	rand_num RN(
		.clk(clk), .rand(rand)
    );
	
	wire [3:0] mov_x = (rand == 2'b01) ? 5'b11111:
	               (rand == 2'b11) ? 5'b00001:
	                                 5'b00000;
	wire [3:0] mov_y = (rand == 2'b00) ? 5'b11111:
	               (rand == 2'b10) ? 5'b00001:
	                                 5'b00000;
	reg sequence = 0;
    

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
		// initialize starting position to zero
			start_x <= 4;
			start_y <= 4;
			
			// initialize maze to wall
			for (i = 0; i < 16; i = i + 1)
				for (j = 0; j < 16; j = j + 1)
					maze_data [i + 16*j] <= 1'b0;
			// initialize stack to nothing
			stack_pos <= 0;
			for (i = 0; i < 16; i = i + 1)
				for (j = 0; j < 16; j = j + 1) begin
					stack_x [i + 16*j] <= 4'b0000;
					stack_y [i + 16*j] <= 4'b0000;
				end
			// Initialize current carving position
			curr_x 	<= start_x;
			curr_y 	<= start_y;
	end

// TODO: Give "y" array position values enough bits to traverse a distance of
//       32 array positions so it can go down and up.

//       This is most likely why its not going up or down because it doesn't have
//       enough bits to go up and down

	// arithmetic definitions
    wire [3:0] new_pos_x = curr_x + mov_x;
    wire [3:0] new_pos_y = curr_y + mov_y;
    
    wire [16*16-1:0] new_y = (new_pos_y)*16;
    wire [16*16-1:0] new_y_down_1 = (new_pos_y + 1)*16;
    wire [16*16-1:0] new_y_up_1 = (new_pos_y - 1)*16;
    
    wire [3:0] new_x = new_pos_x;
    wire [3:0] new_x_right_1 = new_x + 1;
    wire [3:0] new_x_left_1 = new_x - 1;
    
    wire [16*16-1:0] new_pos = new_x + new_y;
    
	wire [16*16-1:0] curr_data_pos = curr_x + curr_y*16;
    wire [16*16-1:0] currpos_up_1 = curr_data_pos - 16;
    wire [16*16-1:0] currpos_down_1 = curr_data_pos + 16;
    wire [16*16-1:0] currpos_up_2 = currpos_up_1 - 16;  
    wire [16*16-1:0] currpos_down_2 = currpos_down_1 + 16;
    wire [16*16-1:0] currpos_right_1 = curr_data_pos + 1;
    wire [16*16-1:0] currpos_left_1 = curr_data_pos - 1;

	always @(posedge clk) begin
		// ===========================
		// DO ALGORITHM UNTIL FINISHED
		// ===========================
		
			if (finish == 0 && sequence == 0) begin
				if ( // See if tile in movement direction is closed and if that tile 
					 // is only connected to one open tile
					maze_data[new_pos] == 0 &&
					(	//           tile right of current is open & position not on right edge
						{2'b00, maze_data[new_x_right_1 + new_y]} +
						//           tile left of current is open  & position not on left edge
						{2'b00, maze_data[new_x_left_1 + new_y ]} +
						//           tile up of current is open    & position not on top edge
						{2'b00, maze_data[new_x + new_y_up_1   ]} +
						//           tile down of current is open  & position not on bottom edge
						{2'b00, maze_data[new_x + new_y_down_1 ]}
						== 3'b001
					)
				) begin
					curr_x <= new_pos_x; // Update current position
					curr_y <= new_pos_y;
					stack_x[stack_pos] <= curr_x; // Push old position on stack
					stack_y[stack_pos] <= curr_y;
					stack_pos <= stack_pos + 1;
				end
				
				sequence <= 1; // go to other sequence
			end
		
			if (finish == 0 && sequence == 1) begin
			
				// IF SURROUNDED BY WALLS, POP STACK
				// TODO: Boundary conditions for these
				// TODO: maybe scratch this and have it just look 10 times
				//       in random directions instead
                

                if ( // if stuck pop off stack
                    // up
                    (	maze_data[currpos_up_1] == 1 ||
						(	maze_data[currpos_up_1] == 0 &&
							(	maze_data[currpos_up_2] == 1 ||
								maze_data[currpos_up_1 + 1] == 1 ||
								maze_data[currpos_up_1 - 1] == 1
							)
						)
					) &&
					// left
					(	maze_data[currpos_left_1] == 1 ||
						(	maze_data[currpos_left_1] == 0 &&
							(	maze_data[currpos_left_1 - 1] == 1 ||
								maze_data[currpos_down_1 - 1] == 1 ||
								maze_data[currpos_up_1 - 1] == 1
							)
						)
					) &&
					// down
					(	maze_data[currpos_down_1] == 1 ||
						(	maze_data[currpos_down_1] == 0 &&
							(	maze_data[currpos_down_2] == 1 ||
								maze_data[currpos_down_1 - 1] == 1 ||
								maze_data[currpos_down_1 + 1] == 1
							)
						)
					) &&
					// right
					(	maze_data[currpos_right_1] == 1 ||
						(	maze_data[currpos_right_1] == 0 &&
							(	maze_data[currpos_right_1 + 1] == 1 ||
								maze_data[currpos_down_1 + 1] == 1 ||
								maze_data[currpos_up_1 + 1] == 1
							)
						)
					)
				) begin // pop off stack
					stack_pos <= stack_pos - 1;
					curr_x <= stack_x[stack_pos - 1];
					curr_y <= stack_y[stack_pos - 1];
				end else
					sequence <= 0; // go to other sequence
			end
			
			// CONTINUE LOOP UNTIL STACK IS EMPTY
			if (finish == 0 && stack_pos == 0 && start == 0)
				finish <= 1;
			if (finish == 1 && start == 1)
				finish <= 0;
			
			maze_data[curr_data_pos] <= 1; // carve
		
	end
	
//	always @ (posedge clk) begin
//	end
	
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

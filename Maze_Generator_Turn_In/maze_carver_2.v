
/***********************************************
*  ECE324 Digital Systems Design:  Maze Generator
*  John Hofman, Candice Adsero, & Ricky Barella
*  maze_carver_2 module
************************************************/

module maze_carver_2
	(
		input clk,                          // clock input
		input [25:0] slow_time,             // carve speed parameter
		input start,                        // start carve
		input wire [4:0] maze_width,        // width  of maze in tiles
		input wire [4:0] maze_height,       // height of maze in tiles
		output reg [16*16-1:0] maze_data,   // data for maze
	
		output wire finished,               // finished carving
		
		output reg [3:0] curr_x = 0,        // current carving position
		output reg [3:0] curr_y = 0,
		
		output reg [3:0] finish_x = 0,      // position of finish line
		output reg [3:0] finish_y = 0
	);
	
	// declare registers
	reg [25:0] slow_clk_counter;    // current count for carve speed
	reg [5:0] i;                    // unwrapping array definitinos
	reg [5:0] j;
	reg [3:0] start_x = 0;          // starting position
	reg [3:0] start_y = 0;
	reg finish = 1;                 // finished carving
	
    // make stack to hold memory
	reg [3:0] stack_x [16*16-1:0];  // stored x positions
	reg [3:0] stack_y [16*16-1:0];  // stored y positions
	reg [8:0] stack_pos;            // current position on stack
	reg stack_started = 0;          // stack had at least one value
	
	assign finished = finish/* & stack_started*/;
	
	reg [8:0] finish_stack_pos = 0; // keep track of largest value the stack gets
    
	// instantiate rand_num
	// Generate random numbers on the fly
	wire [1:0] rand;
	rand_num RN(
		.clk(clk), .rand(rand)
    );
	wire [3:0] mov_x = (rand == 2'b01) ? 4'b1111:
	               (rand == 2'b11) ? 4'b0001:
	                                 4'b0000;
	wire [3:0] mov_y = (rand == 2'b00) ? 4'b1111:
	               (rand == 2'b10) ? 4'b0001:
	                                 4'b0000;
	
	initial begin
		// initialize maze to wall
		for (i = 0; i < 16; i = i + 1)
			for (j = 0; j < 16; j = j + 1)\
				maze_data [i + 16*j] <= 1'b0;
		// initialize stack to nothing
		stack_pos <= 0;
		for (i = 0; i < 16; i = i + 1)
			for (j = 0; j < 16; j = j + 1) begin
				stack_x [i + 16*j] <= 4'b0000;
				stack_y [i + 16*j] <= 4'b0000;
			end
	end
	
	// arithmetic definitions
    wire [3:0] new_pos_x = curr_x + mov_x;
    wire [3:0] new_pos_y = curr_y + mov_y;
    
    wire [7:0] new_y = (new_pos_y)*16;
    wire [7:0] new_y_down_1 = (new_pos_y + 1)*16;
    wire [7:0] new_y_up_1 = (new_pos_y - 1)*16;
    
    wire [3:0] new_x = new_pos_x;
    wire [3:0] new_x_right_1 = new_x + 1;
    wire [3:0] new_x_left_1 = new_x - 1;
    
    wire [7:0] new_pos = new_x + new_y;
    
	wire [7:0] curr_data_pos = curr_x + curr_y*16;
    wire [7:0] currpos_up_1 = curr_data_pos - 16;
    wire [7:0] currpos_down_1 = curr_data_pos + 16;
    wire [7:0] currpos_up_2 = currpos_up_1 - 16;  
    wire [7:0] currpos_down_2 = currpos_down_1 + 16;
    wire [7:0] currpos_right_1 = curr_data_pos + 1;
    wire [7:0] currpos_left_1 = curr_data_pos - 1;
	
	wire [4:0] x_max = maze_width - 1;
	wire [4:0] y_max = maze_height - 1;
	 
     
//  ********************
//  WALL DETECTION LOGIC
//  ****************************************************************************************************
	wire is_wall_up = (	(	maze_data[currpos_up_1] == 0 &&
										(	(maze_data[currpos_up_1 - 16] == 1 && curr_y - 1 != 0) ||
											(maze_data[currpos_up_1 + 1] == 1 && curr_x != x_max - 1) ||
											(maze_data[currpos_up_1 - 1] == 1 && curr_x != 0)
										)
								) ||
								curr_y == 0
							) ? 1'b1 : 1'b0;
	wire is_wall_left = (	(	maze_data[currpos_left_1] == 0 &&
										(	(maze_data[currpos_left_1 - 1] == 1 && curr_x - 1 != 0) ||
											(maze_data[currpos_left_1 + 16] == 1 && curr_y != y_max) ||
											(maze_data[currpos_left_1 - 16] == 1 && curr_y != 0)
										)
									) ||
									curr_x == 0
								) ? 1'b1 : 1'b0;
	wire is_wall_down = (	(	maze_data[currpos_down_1] == 0 &&
										(	(maze_data[currpos_down_1 + 16] == 1 && curr_y + 1 != y_max) ||
											(maze_data[currpos_down_1 + 1] == 1 && curr_x != x_max) ||
											(maze_data[currpos_down_1 - 1] == 1 && curr_x != 0)
										)
									) ||
									curr_y == 15
								) ? 1'b1 : 1'b0;
	wire is_wall_right = (	(	maze_data[currpos_right_1] == 0 &&
										(	(maze_data[currpos_right_1 + 1] == 1 && curr_x + 1 != x_max) ||
											(maze_data[currpos_right_1 + 16] == 1 && curr_y != y_max) ||
											(maze_data[currpos_right_1 - 16] == 1 && curr_y != 0)
										)
									) ||
									curr_x == 15
								) ? 1'b1 : 1'b0;
//  ********************************************

	// DO ALGORITHM UNTIL FINISHED
	always @(posedge clk) begin
	
		if (finish == 0 && slow_clk_counter == slow_time) begin
			// if want to carve up
			if (         mov_y == 4'b1111 &&
			             !is_wall_up &&
			             maze_data[currpos_up_1] == 0) begin
				curr_y <= curr_y - 1; // update current position
				stack_x[stack_pos] <= curr_x; // push old position to stack
				stack_y[stack_pos] <= curr_y;
				stack_pos <= stack_pos + 1;
			// if want to carve left
			end else if (mov_x == 4'b1111 &&
			             !is_wall_left &&
			             maze_data[currpos_left_1] == 0) begin
				curr_x <= curr_x - 1; // update current position
				stack_x[stack_pos] <= curr_x; // push old position to stack
				stack_y[stack_pos] <= curr_y;
				stack_pos <= stack_pos + 1;
			// if want to carve down
			end else if (mov_y == 4'b0001 &&
			             !is_wall_down &&
			             maze_data[currpos_down_1] == 0) begin
				curr_y <= curr_y + 1; // update current position
				stack_x[stack_pos] <= curr_x; // push old position to stack
				stack_y[stack_pos] <= curr_y;
				stack_pos <= stack_pos + 1;
			// if want to carve right
			end else if (mov_x == 4'b0001 &&
			             !is_wall_right &&
			             maze_data[currpos_right_1] == 0) begin
				curr_x <= curr_x + 1; // update current position
				stack_x[stack_pos] <= curr_x; // push old position to stack
				stack_y[stack_pos] <= curr_y;
				stack_pos <= stack_pos + 1;
			end else if ( // if stuck pop off stack
				// up
				(	maze_data[currpos_up_1] == 1 ||
					is_wall_up
				) &&
				// left
				(	maze_data[currpos_left_1] == 1 ||
					is_wall_left
				) &&
				// down
				(	maze_data[currpos_down_1] == 1 ||
					is_wall_down
				) &&
				// right
				(	maze_data[currpos_right_1] == 1 ||
					is_wall_right
				)
			) begin // pop off stack
				stack_pos <= stack_pos - 1;
				curr_x <= stack_x[stack_pos - 1];
				curr_y <= stack_y[stack_pos - 1];
			end
			
			slow_clk_counter <= 0;
					
			
		end else // end algorithm step
			slow_clk_counter <= slow_clk_counter + 1;
			
		maze_data[curr_data_pos] <= 1; // carve
		
		// START OVER IF START
		if (start == 1) begin
			finish <= 0;
			finish_stack_pos <= 0;
			curr_x <= 0;
			curr_y <= 0;
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
		// CONTINUE LOOP UNTIL STACK IS EMPTY
		end else if (finish == 0 && stack_pos == 0 && stack_started) begin
			finish <= 1;
			stack_started <= 0;
		end
	
		if (stack_pos == 1)
			stack_started <= 1;
			
		if (stack_pos > finish_stack_pos) begin
			finish_x <= curr_x;
			finish_y <= curr_y;
			finish_stack_pos <= stack_pos;
		end
		
	end
	
endmodule

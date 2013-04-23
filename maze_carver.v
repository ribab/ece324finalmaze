
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
		maze_data [0*2 + 0*128 + 1: 0*2 + 0*128] = 2'b11;
		curr_x = start_x;
		curr_y = start_y;
	end
	
	//  Key
	// 
	//  path = maze path = 2'b11
	//	out = maze wall = 2'b00
	//  frontier 2'b01
	//	 wall = 2'b10
	
	function [1:0] maze_data_check;
		input x, y
	
	always @ (posedge clk)
		if (start == 1 && finish == 0) begin
// MAKE FRONTIER
		// change right into frontier
			// if current position is a path, and is in bounds, and position to right is not a wall or a path
			if (curr_x < maze_width &&
				maze_data[(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] != 2'b11 &&
				maze_data[(curr_x + 1)*2 + (curr_y + 1)*128 + 1] == 1 && maze_data [(curr_x + 1)*2 + (curr_y - 1)*128 == 1 &&
				maze_data[(curr_x + 2)*2 + (curr_y)*128 + 1] == 0)
				maze_data [(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] = 2'b01;
		// change left into frontier
			if (maze_data [(curr_x - 1)*2 + (curr_y)*128 + 1 : (curr_x - 1)*2 + (curr_y)*128] == 2'b00 && curr_x > 0 && 
							[(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] != 2'b01 &&
							[(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] != 2'b11)

				maze_data [(curr_x - 1)*2 + (curr_y)*128 + 1 : (curr_x - 1)*2 + (curr_y)*128] = 2'b01;
		// change down into frontier
			if (maze_data [(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] == 2'b00 && curr_y < maze_height && 
							[(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] != 2'b01 &&
							[(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] != 2'b11)
							
				maze_data [(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] = 2'b01;
		// change up into frontier
			if (maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] == 2'b00 && curr_y > 0 && 
							[(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] != 2'b01 &&
							[(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] != 2'b11*/)
							
				maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] = 2'b01;
		end
// MOVE RANDOM DIRECTION 
		case (rand)
			// change right into in and move right
			2'b00 :	if (maze_data [(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] == 2'b10) begin
							maze_data [(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] = 2'b11;
						// change right into wall
							// if current position is a path, and is in bounds, and position to right is not a wall or a path
/*							if (maze_data [(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] == 2'b00 && curr_x < maze_width && 
											[(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] != 2'b01 && 
											[(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] != 2'b11) 
							
								maze_data [(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] = 2'b01;
*/						// change left into wall
							if (maze_data [(curr_x - 1)*2 + (curr_y)*128 + 1 : (curr_x - 1)*2 + (curr_y)*128] == 2'b00 && curr_x > 0 && 
											[(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] != 2'b01 &&
											[(curr_x + 1)*2 + (curr_y)*128 + 1 : (curr_x + 1)*2 + (curr_y)*128] != 2'b11)

								maze_data [(curr_x - 1)*2 + (curr_y)*128 + 1 : (curr_x - 1)*2 + (curr_y)*128] = 2'b01;
							// change down into wall
							if (maze_data [(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] == 2'b00 && curr_y < maze_height && 
											[(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] != 2'b01 &&
											[(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] != 2'b11)
											
								maze_data [(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] = 2'b01;
							// change up into wall
							if (maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] == 2'b00 && curr_y > 0 && 
											[(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] != 2'b01 &&
											[(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] != 2'b11)
											
								maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] = 2'b01;
			// move right
							curr_x = (curr_x + 1)*2;
						end
			//change left into in and move left
			2'b01 :	if (maze_data [(curr_x - 1)*2 + (curr_y)*128 + 1 : (curr_x - 1)*2 + (curr_y)*128] == 2'b10) begin
						maze_data [(curr_x - 1)*2 + (curr_y)*128 + 1 : (curr_x - 1)*2 + (curr_y)*128] = 2'b11;
						curr_x = (curr_x - 1)*2;
					end
			// change down into in and move down
			2'b10 : if (maze_data [(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] == 2'b10) begin
						maze_data [(curr_x)*2 + (curr_y + 1)*128 + 1 : (curr_x)*2 + (curr_y + 1)*128] = 2'b11;
						curr_y = (curr_y + 1) * 128;
					end
			// change up into in and move up
			2'b11 : if (maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] == 2'b10) begin
						maze_data [(curr_x)*2 + (curr_y - 1)*128 + 1 : (curr_x)*2 + (curr_y - 1)*128] = 2'b11;
						curr_y = (curr_y - 1) * 128;
					end
		endcase

		
	function [1:0] maze_data_check;
	input clk;
	input reg [15:0] reg_x;
	input reg [15:0] reg_y;
	
	begin
	maze_data_check = maze_data [(reg_x)*2 + (reg_y)*128 + 1 : (reg_x)*2 + (reg_y)*128];	
	
	end
	endfunction
			
	
	
endmodule


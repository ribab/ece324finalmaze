
module maze_carver
	(
		input start,
		input wire [2:0] x_dimension,
		input wire [2:0] y_dimension,
		output wire [8:0] maze_data,
		output reg finish
	);

	localparam X_MAX = 4;
	localparam Y_MAX = 4;
	
	reg [X_MAX-1:0] maze_paths [Y_MAX-1:0];
	
//	 maze_paths
//  000...0
//  111...0
//  000...0
//  ...
//  000...0

	initial begin
		maze_paths [0] = 4'b0000;
		maze_paths [1] = 4'b1111;
		maze_paths [2] = 4'b0000;
		maze_paths [3] = 4'b0000;
	end
	
	assign maze_data = {maze_paths[0], maze_paths[1], maze_paths[2]};

endmodule

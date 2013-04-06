
module maze_carver
	(
		input clk,
		input start,
		input wire [2:0] x_dimension,
		input wire [2:0] y_dimension,
		output reg [307200-1:0] maze_data,
		output reg finish
	);
	
	reg [640-1:0] maze_paths [480-1:0];
	
//	 maze_paths
//  000...0
//  111...0
//  000...0
//  ...
//  000...0

	
	reg [15:0] i;
	reg [15:0] j;

	initial begin
		for (i = 0; i < 640; i = i + 1)
			for (j = 0; j < 480; j = j + 1)
				maze_paths [i][j] = 0;
		maze_paths [0] = 4'b0000;
		maze_paths [1] = 4'b1110;
		maze_paths [2] = 4'b0000;
		maze_paths [3] = 4'b0000;
	end
	
	always @(posedge clk) begin
		for (i = 0; i < 640; i = i + 1)
			for (j = 0; j < 480; j = j + 1)
				maze_data[i*j+1] <= maze_paths[i][j];
	end

endmodule

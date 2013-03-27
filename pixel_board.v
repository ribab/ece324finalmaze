
module pixel_board
	(
	input wire clk,
	input wire [31:0] triangle_camera [0:MAX_TRIANGLES-1] [0:2] [0:2];
	output reg [7:0] setpixel [SCREEN_WIDTH] [SCREEN_HEIGHT]
	);
	
	// transform world to camera current position
	
	// e.g. triangle[<triangle #>][<vertex #>][<X,Y,Z>] = <new coord>
	reg [9:0] triangle2d [0:MAX_TRIANGLES-1] [0:2] [0:1];
	
	integer i;
	
	always @(posedge clk) begin
		setpixel = 0;
		triangle2d = 0;
		
		// refer to en.wikipedia.org/wiki/3d_projection
		// diagram at the bottom of the screen for algorithm.
		// x_pixel = model_x_coord * focal_length / model_z_coord
		// (relative to the camera)
		for (i = 0; i < MAX_TRIANGLES; i = i + 1) begin
			if (triangle3d[i][0][Z] >= FOCAL_LENGTH && triangle3d[i][1][Z] >= FOCAL_LENGTH && triangle3d[i][2][Z] >= FOCAL_LENGTH) begin
				triangle2d[i][0][X] = triangle3d[i][0][X]*FOCAL_LENGTH/triangle3d[i][0][Z];
				triangle2d[i][0][Y] = triangle3d[i][0][Y]*FOCAL_LENGTH/triangle3d[i][0][Z];
				triangle2d[i][1][X] = triangle3d[i][0][X]*FOCAL_LENGTH/triangle3d[i][0][Z];
				triangle2d[i][1][Y] = triangle3d[i][0][Y]*FOCAL_LENGTH/triangle3d[i][0][Z];
				triangle2d[i][2][X] = triangle3d[i][0][X]*FOCAL_LENGTH/triangle3d[i][0][Z];
				triangle2d[i][2][Y] = triangle3d[i][0][Y]*FOCAL_LENGTH/triangle3d[i][0][Z];
				end
			end
			
		// TODO: set setpixel based on triangle2d
		end
	
endmodule

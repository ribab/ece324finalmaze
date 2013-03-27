
module world_view
	(
	input clk,
	input wire [31:0] triangle_world [0:MAX_TRIANGLES] [0:2] [0:2],
	input [31:0] camera_i [0:2], camera_j [0:2], camera_k [0:2],
			   camera_x, camera_y, camera_z,
	output reg [31:0] triangle_camera [0:MAX_TRIANGLES-1] [0:2] [0:2],
	);
	
	integer i;
	
	initial begin
		camera_i[X] = 1024;
		camera_i[Y] = 0;
		camera_i[Z] = 0;
		
		camera_j[X] = 0;
		camera_j[Y] = 0;
		camera_j[Z] = 1024;
		
		camera_k[X] = 0;
		camera_k[Y] = 1024;
		camera_k[Z] = 0;
		
		camera_x = 150;
		camera_y = 0;
		camera_z = 150;
		end
	
	always @* begin
		
		for (i = 0; i < MAX_TRIANGLES; i = i + 1) begin
			triangle_camera[i][0][X]
				= (triangle_world[i][0][X]*camera_i[X]
				+  triangle_world[i][0][Y]*camera_i[Y]
				+  triangle_world[i][0][Z]*camera_i[Z])
				/ (camera_i[X]*camera_i[X]
				+  camera_i[Y]*camera_i[Y]
				+  camera_i[Z]*camera_i[Z]);
			triangle_camera[i][1][X]
				= (triangle_world[i][1][X]*camera_j[X]
				+  triangle_world[i][1][Y]*camera_j[Y]
				+  triangle_world[i][1][Z]*camera_j[Z])
				/ (camera_j[X]*camera_j[X]
				+  camera_j[Y]*camera_j[Y]
				+  camera_j[Z]*camera_j[Z]);
			triangle_camera[i][2][X]
				= (triangle_world[i][2][X]*camera_k[X]
				+  triangle_world[i][2][Y]*camera_k[Y]
				+  triangle_world[i][2][Z]*camera_k[Z])
				/ (camera_k[X]*camera_k[X]
				+  camera_k[Y]*camera_k[Y]
				+  camera_k[Z]*camera_k[Z]);
				
			triangle_camera[i][0][Y]
				= (triangle_world[i][0][X]*camera_y[X]
				+  triangle_world[i][0][Y]*camera_y[Y]
				+  triangle_world[i][0][Z]*camera_y[Z])
				/ (camera_i[X]*camera_k[X]
				+  camera_i[Y]*camera_k[Y]
				+  camera_i[Z]*camera_k[Z]);
			triangle_camera[i][1][Y]
				= (triangle_world[i][1][X]*camera_y[X]
				+  triangle_world[i][1][Y]*camera_y[Y]
				+  triangle_world[i][1][Z]*camera_y[Z])
				/ (camera_k[X]*camera_k[X]
				+  camera_k[Y]*camera_k[Y]
				+  camera_k[Z]*camera_k[Z]);
			triangle_camera[i][2][Y]
				= (triangle_world[i][2][X]*camera_y[X]
				+  triangle_world[i][2][Y]*camera_y[Y]
				+  triangle_world[i][2][Z]*camera_y[Z])
				/ (camera_k[X]*camera_k[X]
				+  camera_k[Y]*camera_k[Y]
				+  camera_k[Z]*camera_k[Z]);
				
			triangle_camera[i][0][Z]
				= (triangle_world[i][0][X]*camera_z[X]
				+  triangle_world[i][0][Y]*camera_z[Y]
				+  triangle_world[i][0][Z]*camera_z[Z])
				/ (camera_k[X]*camera_k[X]
				+  camera_k[Y]*camera_k[Y]
				+  camera_k[Z]*camera_k[Z]);
			triangle_camera[i][1][Z]
				= (triangle_world[i][1][X]*camera_z[X]
				+  triangle_world[i][1][Y]*camera_z[Y]
				+  triangle_world[i][1][Z]*camera_z[Z])
				/ (camera_k[X]*camera_k[X]
				+  camera_k[Y]*camera_k[Y]
				+  camera_k[Z]*camera_k[Z]);
			triangle_camera[i][2][Z]
				= (triangle_world[i][2][X]*camera_z[X]
				+  triangle_world[i][2][Y]*camera_z[Y]
				+  triangle_world[i][2][Z]*camera_z[Z])
				/ (camera_k[X]*camera_k[X]
				+  camera_k[Y]*camera_k[Y]
				+  camera_k[Z]*camera_k[Z]);
			end
		
		end
	
endmodule


module set_world
	(
	output reg [31:0] world [0:MAX_TRIANGLES-1] [0:2] [0:2];
	output reg max_triangles;
	);
	
	localparam MAX_TRIANGLES = 4;
	localparam X = 0;
	localparam Y = 1;
	localparam Z = 2;
	
	initial begin
		max_triangles = MAX_TRIANGLES;
		
		world[0][0][X] = 100; // 0
		world[0][0][Y] = 100;
		world[0][0][Z] = 100;
		
		world[0][1][X] = 200;
		world[0][1][Y] = 100;
		world[0][1][Z] = 100;
		
		world[0][2][X] = 100;
		world[0][2][Y] = 200;
		world[0][2][Z] = 100;
		
		world[1][0][X] = 100; // 1
		world[1][0][Y] = 100;
		world[1][0][Z] = 100;
		
		world[1][1][X] = 200;
		world[1][1][Y] = 100;
		world[1][1][Z] = 100;
		
		world[1][2][X] = 100;
		world[1][2][Y] = 100;
		world[1][2][Z] = 200;
		
		world[2][0][X] = 100; // 2
		world[2][0][Y] = 100;
		world[2][0][Z] = 100;
		
		world[2][1][X] = 100;
		world[2][1][Y] = 200;
		world[2][1][Z] = 100;
		
		world[2][2][X] = 100;
		world[2][2][Y] = 100;
		world[2][2][Z] = 200;
		
		world[2][0][X] = 200; // 3
		world[2][0][Y] = 100;
		world[2][0][Z] = 100;
		
		world[2][1][X] = 100;
		world[2][1][Y] = 200;
		world[2][1][Z] = 100;
		
		world[2][2][X] = 100;
		world[2][2][Y] = 100;
		world[2][2][Z] = 200;
		end
	
endmodule

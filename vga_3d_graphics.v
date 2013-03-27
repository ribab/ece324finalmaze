/* NEXYS 2 VGA tester
   from Pong Chu, "FPGA Protyping by Verilog Examples"
   Listing 13.2
   
   Modified 07 March 2011 by JDL: Changed from 8 colors (3 bits) to 256 colors (8 bits)
*/   

module vga_3d_graphics
   (
    input wire clk, reset,
	input wire [31:0] triangle3d [0:MAX_TRIANGLES-1] [0:2] [0:2],
	input wire [31:0] camera_i [0:2], camera_j [0:2], camera_k [0:2],
			   camera_x, camera_y, camera_z;
    output wire hsync, vsync,
    output wire [7:0] rgb
   );
   
   parameter MAX_TRIANGLES = 20;
   parameter FOCAL_LENGTH = 200;
   
   parameter X = 0, Y = 1, Z = 2;

   //signal declaration
   wire video_on;
   wire [31:0] triangle_camera [0:MAX_TRIANGLES-1] [0:2] [0:2];
   reg [7:0] rgb_reg, rgb_next;
   reg [9:0] xpos, ypos;
   wire [7:0] pixel [0:639] [0:479];

   // instantiate vga sync circuit
   vga_sync vsync_unit
      (.clk(clk), .reset(reset), .hsync(hsync), .vsync(vsync),
       .video_on(video_on), .p_tick(), .pixel_x(xpos), .pixel_y(ypos));
	   
	// get relative coordinates from world and camera information
	world_view camera
		(.clk(clk), .triangle_world(triangle3d),
		 .camera_i(camera_i), .camera_j(camera_j), .camera_k(camera_k),
		 .camera_x(camera_x), .camera_y(camera_y), .camera_z(camera_z),
		 .triangle_camera(triangle_camera));
		 
	// get the pixel information from relative coordinates
	pixel_board draw_screen
		(.clk(clk), .triangle_camera(triangle_camera), .setpixel(pixel));
	  
   
   // rgb buffer
   always @(posedge clk, posedge reset) begin
      rgb_reg = pixel[xpos][ypos];
      end
	  
   // output
   assign rgb = (video_on) ? rgb_reg : 8'b0;

endmodule

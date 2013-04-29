// Listing 14.3
module font_test_top
   (
    input wire clk, reset,
	
      // VGA outputs
    output Vsync, Hsync,
    output [3:1] vgaRed, vgaGreen,
    output [3:2] vgaBlue
	 
    //output wire [2:0] rgb
   );

   // signal declaration
   wire [9:0] pixel_x, pixel_y;
   wire video_on, pixel_tick;
   reg [7:0] rgb_reg;
   wire [7:0] rgb_next;//, rgb_apple;

   // body
	
	
	
   // instantiate vga sync circuit
   vga_sync vsync_unit
      (.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync),
       .video_on(video_on), .p_tick(pixel_tick),
       .pixel_x(pixel_x), .pixel_y(pixel_y));
   // font generation circuit
   font_test_gen font_gen_unit
      (.clk(clk), .video_on(video_on), .pixel_x(pixel_x),
      .pixel_y(pixel_y), .rgb_text(rgb_next));
		 
	// font apple
	//font_apple crisp_and_sweet
    //  (.clk(clk), .video_on(video_on), .pixel_x(pixel_x),
     //  .pixel_y(pixel_y), .rgb_apple(rgb_next));
	
   // rgb buffer
   always @(posedge clk)
      if (pixel_tick)
         rgb_reg <= rgb_next;
   // output
   assign vgaRed = rgb_reg[7:5];
   assign vgaGreen = rgb_reg[4:2];
   assign vgaBlue = rgb_reg[1:0];

endmodule

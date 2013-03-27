/* NEXYS 2 VGA tester
   from Pong Chu, "FPGA Protyping by Verilog Examples"
   Listing 13.2
   
   Modified 07 March 2011 by JDL: Changed from 8 colors (3 bits) to 256 colors (8 bits)
*/   

module vga_test
   (
    input wire clk, reset,
    input wire [7:0] sw,
    output wire hsync, vsync,
    output wire [7:0] rgb
   );

   //signal declaration
   reg [7:0] rgb_reg;
   wire video_on;

   // instantiate vga sync circuit
   vga_sync vsync_unit
      (.clk(clk), .reset(reset), .hsync(hsync), .vsync(vsync),
       .video_on(video_on), .p_tick(), .pixel_x(), .pixel_y());
   // rgb buffer
   always @(posedge clk, posedge reset)
      if (reset)
         rgb_reg <= 0;
      else
         rgb_reg <= sw;
   // output
   assign rgb = (video_on) ? rgb_reg : 8'b0;

endmodule

/*********************************************************************
  ECE 324 Lab 8 starter kit 
  Dr. Lynch - 07 Mar 2011
  
*********************************************************************/
 
module fpga_top(
	input clk,
	input  [7:0] sw,
	input  [3:0] btn,
	output [7:0] Led,
 
    // 7-segment display outputs
    output [3:0] an,
    output [6:0] sseg,
    output dp,
    
    // VGA outputs
    output Vsync, Hsync,
    output [3:1] vgaRed, vgaGreen,
    output [3:2] vgaBlue
);

	// tie off unsed outputs
	assign an = 0;
	assign sseg = 0;
	assign dp = 0;
	
	// pass switch input on to Led outputs
	assign Led = sw;

	// instantiate VGA tester
	vga_test VG (
		.clk(clk), 
		.reset(1'b0),
		.sw(sw),
	    .hsync(Hsync), 
	    .vsync(Vsync), 
	    .rgb({vgaRed, vgaGreen, vgaBlue})
	);
	
endmodule


module keyboard_test_fpga_top(

	input clk,
	output [7:0] Led,
	
	  // PS2 bidirectional ports
    inout wire ps2d, ps2c
);

	// signal declarations
	wire [7:0] key_code;
	wire reset = 0; // reset is not used - tie it to zero
	
	//instantiate keyboard
	kb_code KB(
		.clk(clk), 
		.reset(reset),
		.ps2d(ps2d), 
		.ps2c(ps2c), 
		.rd_key_code(1),
		.key_code(key_code),
		.kb_buf_empty()
	);
   
	assign Led = key_code;
	
endmodule

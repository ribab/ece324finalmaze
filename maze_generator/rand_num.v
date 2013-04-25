/***********************************************
*  ECE324 Digital Systems Design:  Maze Generator
*  John Hofman, Candice Adsero, & Ricky Barella
*  rand_num
************************************************/


module rand_num(
	input clk, reset,
	output reg [1:0] rand
    );

parameter [7:0] base = 8'b10100101;

reg [7:0] base_reg;
wire a = base_reg[2], b = base_reg[5];
wire c = base_reg[7], d = base_reg[0];
wire ab = a ^ b, ac = a ^ c;
wire dc = d ^ c, bd = b & d;
	
always @ (posedge clk)
	begin
	rand = {ab | bd, ac | dc};
	base_reg = {base_reg[6:0],base_reg[7]}+1;
	end
endmodule

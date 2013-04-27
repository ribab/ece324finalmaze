/***********************************************
*  ECE324 Digital Systems Design:  Maze Generator
*  John Hofman, Candice Adsero, & Ricky Barella
*  rand_num
************************************************/


module rand_num(
	input clk,
	output [1:0] rand
    );
	
	reg [22:0] r1 = 23'b1010110100_1101101101_010;
	always @(posedge clk) begin
		r1 <= {r1[21:0], r1[22] ^ r1[15]};
	end
	
	reg [20:0] r2 = 21'b1011011010_0101010111_0;
	always @(posedge clk) begin
		r2 <= {r2[19:0], r2[20] ^ r2[11]};
	end
	
	assign rand = {r1[21], r2[19]};
	
endmodule
	
/*

//parameter [7:0] base = 8'b10100101;

reg [7:0] base_reg = 8'b10100101;
wire a = base_reg[2], b = base_reg[5];
wire c = base_reg[7], d = base_reg[0];
wire ab = a ^ b, ac = a ^ c;
wire dc = d ^ c, bd = b & d;
	
always @ (posedge clk)
	begin
	rand <= {ab | bd, ac | dc};
	base_reg <= {base_reg[6:0],base_reg[7]}+1;
	end
endmodule
*/
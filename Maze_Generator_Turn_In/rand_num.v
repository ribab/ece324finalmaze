/***********************************************
*  ECE324 Digital Systems Design:  Maze Generator
*  John Hofman, Candice Adsero, & Ricky Barella
*  rand_num
************************************************/


module rand_num(
    input clk,          // Clock Input
    output [1:0] rand   // Random number
    );
	
    // Random sequence for first bit
    reg [22:0] r1 = 23'b1010110100_1101101101_010;
    always @(posedge clk) begin
        r1 <= {r1[21:0], r1[22] ^ r1[15]};  // 2nd MSB + MSB xor'd with random bit
    end
	
    // Random sequence for second bit
    reg [20:0] r2 = 21'b1011011010_0101010111_0;
    always @(posedge clk) begin
        r2 <= {r2[19:0], r2[20] ^ r2[11]};  // 2nd MSB + MSB xor'd with random bit
    end
	
    assign rand = {r1[21], r2[19]};         // Concatenate the 2 bits
	
endmodule

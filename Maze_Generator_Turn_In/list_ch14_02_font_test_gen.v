//Pong Chu's "FPGA Protyping by Verilog Examples" Listing 14.2 & 14.5
//First modified by Madison Knowles & Breanne York
//Modified again by Candice Adsero, Ricky Barella & John Hofman for Maze Generator
//April 2013

module font_test_gen
   (
	input wire display,
    input wire clk,
    input wire video_on, // start screen enable
    input wire [9:0] pixel_x, pixel_y,
    output reg [7:0] rgb_text
   );

   // signal declaration
   wire [10:0] rom_addr;
   reg [6:0] char_addr, char_addr_o, char_addr_s, char_addr_h, char_addr_a, char_addr_w, char_addr_r;
   reg [3:0] row_addr;
   wire [3:0] row_addr_o, row_addr_s, row_addr_h, row_addr_a, row_addr_w, row_addr_r;
	reg [2:0] bit_addr;
   wire [2:0] bit_addr_o, bit_addr_s, bit_addr_h, bit_addr_a, bit_addr_w, bit_addr_r;
	wire [7:0] font_word;
   wire font_bit, text_bit_on, Game_over_on, Game_start_on, Hangman_on, Apple_on, Win_on, rule_on;
	wire [7:0] rule_random_addr;

   // body
   // instantiate font ROM
   font_rom font_unit
      (.clk(clk), .addr(rom_addr), .data(font_word));
   
	//title
		assign Hangman_on = (pixel_y[9:7] == 1) && (1 <= pixel_x [9:6]) && (pixel_x [9:6] <= 8);
		assign row_addr_h = pixel_y [6:3];
		assign bit_addr_h = pixel_x[5:2];
		always @*
			case (pixel_x [8:5])
				4'h3: char_addr_h = 7'h4D; //M
				4'h4: char_addr_h = 7'h41; //A
				4'h5: char_addr_h = 7'h5a; //Z
				4'h6: char_addr_h = 7'h45; //E
				4'h7: char_addr_h = 7'h00; //
				4'h8: char_addr_h = 7'h47; //G
				4'h9: char_addr_h = 7'h45; //E
				4'hA: char_addr_h = 7'h4E; //N
				4'hB: char_addr_h = 7'h45; //E
				4'hC: char_addr_h = 7'h52; //R
				4'hD: char_addr_h = 7'h41; //A
				4'hE: char_addr_h = 7'h54; //T
				4'hF: char_addr_h = 7'h4F; //O
				4'h0: char_addr_h = 7'h52; //R
				default: char_addr_h = 7'h00; //
			endcase
	
	//"press start"
	assign Game_start_on = (pixel_y[9:5] == 4) && (3 <= pixel_x [9:6]) && (pixel_x [9:6] <= 6);
	assign row_addr_s = pixel_y [4:1];
	assign bit_addr_s = pixel_x[3:1];
	always @*
		case (pixel_x [7:4])
			4'h4: char_addr_s = 7'h50; //P
			4'h5: char_addr_s = 7'h72; //r
			4'h6: char_addr_s = 7'h65; //e
			4'h7: char_addr_s = 7'h73; //s
			4'h8: char_addr_s = 7'h73; //s
			4'h9: char_addr_s = 7'h00; // 
			4'ha: char_addr_s = 7'h53; //S
			4'hb: char_addr_s = 7'h74; //t
			4'hc: char_addr_s = 7'h61; //a
			4'hd: char_addr_s = 7'h72; //r
			default: char_addr_s = 7'h74; //t
		endcase
	
	
	// font ROM interface
   assign rom_addr = {char_addr, row_addr};
   assign font_bit = font_word[~bit_addr];
   // "on" region limited to top-left corner
								
   // rgb multiplexing circuit
   always @*
        if (~video_on)
            rgb_text = 8'b11100010; // 
        else if (rule_on)
			 begin
				bit_addr = bit_addr_r;
				char_addr = char_addr_r;
				row_addr = row_addr_r;
				if (font_bit)
					rgb_text = 8'b11111111;  // white
			 end
        else if (Win_on)
			 begin
				bit_addr = bit_addr_w;
				char_addr = char_addr_w;
				row_addr = row_addr_w;
				if (font_bit)
					rgb_text = 8'b11111111;  // white
			 end
		else if (Hangman_on)
			 begin
				bit_addr = bit_addr_h;
				char_addr = char_addr_h;
				row_addr = row_addr_h;
				if (font_bit)
					rgb_text = 8'b11111111;  // white
			 end
			else if (Game_start_on)
			 begin
				bit_addr = bit_addr_s;
				char_addr = char_addr_s;
				row_addr = row_addr_s;
				if (font_bit)
					rgb_text = 8'b00000000;  // white
			 end

endmodule

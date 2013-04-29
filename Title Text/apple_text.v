module font_apple
   (
    input wire clk,
    input wire video_on,
    input wire [9:0] pixel_x, pixel_y,
    output reg [2:0] rgb_apple
   );

   // signal declaration
   wire [10:0] rom_addr;
   reg [6:0] char_addr;
   reg [6:0] char_addr_a, char_addr_p, char_addr_p2, char_addr_l, char_addr_e;
   reg [3:0] row_addr;
   wire [3:0] row_addr_a, row_addr_p, row_addr_p2, row_addr_l, row_addr_e;
	reg [2:0] bit_addr;
   wire [2:0] bit_addr_a, bit_addr_p, bit_addr_p2, bit_addr_l, bit_addr_e;
	wire [7:0] font_word;
	wire font_bit, apple_a_on, apple_p_on, apple_p2_on, apple_l_on, apple_e_on;
  

   // body
   // instantiate font ROM
   font_rom font_unit
      (.clk(clk), .addr(rom_addr), .data(font_word));
		
		
	assign apple_a_on = (pixel_y[9:5] == 1) && (pixel_x [9:6] == 4);
	assign row_addr_a = pixel_y [5:2];
	assign bit_addr_a = pixel_x[4:2];
	always @*
		case (pixel_x [7:4])
			default: char_addr_a = 7'h61; //a
		endcase
	
	
	assign apple_p_on = (pixel_y[9:5] == 1) && (pixel_x [9:6] == 5);
	assign row_addr_p = pixel_y [4:1];
	assign bit_addr_p = pixel_x[3:1];
	always @*
		case (pixel_x [7:4])
			default: char_addr_p = 7'h70; //p
		endcase
		
	assign apple_p2_on = (pixel_y[9:5] == 1) && (pixel_x [9:6] == 6);
	assign row_addr_p2 = pixel_y [4:1];
	assign bit_addr_p2 = pixel_x[3:1];
	always @*
		case (pixel_x [7:4])
			default: char_addr_p2 = 7'h70; //p
		endcase	
		
	assign apple_l_on = (pixel_y[9:5] == 1) && (pixel_x [9:6] == 7);
	assign row_addr_l = pixel_y [4:1];
	assign bit_addr_l = pixel_x[3:1];
	always @*
		case (pixel_x [7:4])
			default: char_addr_l = 7'h6c; //l
		endcase	
		
	assign apple_e_on = (pixel_y[9:5] == 1) && (pixel_x [9:6] == 8);
	assign row_addr_e = pixel_y [4:1];
	assign bit_addr_e = pixel_x[3:1];
	always @*
		case (pixel_x [7:4])
			default: char_addr_e = 7'h65; //e
		endcase	
	
   assign rom_addr = {char_addr, row_addr};
   
   assign font_bit = font_word[~bit_addr];
   
   
   // rgb multiplexing circuit
   always @*
      if (~video_on)
         rgb_apple = 3'b000; // blank
      else
         if (apple_a_on)
			 begin
				bit_addr = bit_addr_a;
				char_addr = char_addr_a;
				row_addr = row_addr_a;
				if (font_bit)
					rgb_apple = 3'b111;  // white
			 end
         else if (apple_p_on)
			 begin
				bit_addr = bit_addr_p;
				char_addr = char_addr_p;
				row_addr = row_addr_p;
				if (font_bit)
					rgb_apple = 3'b111;  // white
			 end
			   else if (apple_p2_on)
			 begin
				bit_addr = bit_addr_p2;
				char_addr = char_addr_p2;
				row_addr = row_addr_p2;
				if (font_bit)
					rgb_apple = 3'b111;  // white
			 end
          else if (apple_l_on)
			 begin
				bit_addr = bit_addr_l;
				char_addr = char_addr_l;
				row_addr = row_addr_l;
				if (font_bit)
					rgb_apple = 3'b111;  // white
			 end
			 else if (apple_e_on)
			 begin
				bit_addr = bit_addr_e;
				char_addr = char_addr_e;
				row_addr = row_addr_e;
				if (font_bit)
					rgb_apple = 3'b111;  // white
			 end
			 
endmodule

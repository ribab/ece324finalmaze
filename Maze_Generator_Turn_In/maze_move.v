
/***********************************************
*  ECE324 Digital Systems Design:  Maze Generator
*  John Hofman, Candice Adsero, & Ricky Barella
*  maze_move module
************************************************/

module maze_move
   (
	input wire clk,                     // clock input
	input wire reset,
	input wire enable,
    input wire [7:0] key_code,          // current key input
	input wire [16*16-1 :0] maze_data,  // maze input
	input wire [4:0] maze_width,        // maze dimensions
	input wire [4:0] maze_height,
	input wire [3:0] start_x,           // location of starting position
	input wire [3:0] start_y,
	output reg [3:0] curr_x,            // output location of current position
	output reg [3:0] curr_y
   );
	
//  **********
//  PARAMETERS
//  **********************************
    // keycode parameters
	parameter [6:0] LEFT = 7'b1101011;  // left  arrow key
	parameter [6:0] RIGHT = 7'b1110100; // right arrow key
	parameter [6:0] UP = 7'b1110101;    // up    arrow key
	parameter [6:0] DOWN = 7'b1110010;  // down  arrow key
    
    // wait time
	parameter [25:0] slow_time = 5_000_000;
//  **********************************
	
//  ******************
//  MOVEMENT REGISTERS
//  **************************
	reg [25:0] slow_count = 0;
//  **************************
    
//  **************
//  MOVEMENT LOGIC
//  ***************************
	always @(posedge clk) begin
	   
		if (slow_count == slow_time) begin 
			case(key_code[6:0])
				LEFT: // move left if left key and valid location
					begin
						if(maze_data[(curr_x - 1)+16*(curr_y)] == 1 && curr_x != 0)
							begin
								curr_x <= curr_x - 1; //move left
							end
					end
				RIGHT: // move right if right key and valid location
					begin
						if(maze_data[(curr_x + 1)+16*(curr_y)] == 1 && curr_x != (maze_width - 1))
							begin
								curr_x <= curr_x + 1;//move right
							end
					end
				UP: // move up if up key and valid location
					begin
						if(maze_data[(curr_x)+16*(curr_y - 1)] == 1 && curr_y != 0)
							begin
								curr_y <= curr_y - 1; //move up
							end
					end
				DOWN: // move down if down key and valid location
					begin
						if(maze_data[(curr_x)+16*(curr_y + 1)] == 1 && curr_y != (maze_height - 1))
							begin
								curr_y <= curr_y + 1; //move down
							end
					end
			endcase
			
			slow_count <= 0; // reset speed counter
		end else
			slow_count <= slow_count + 1; // increment speed counter
	end
//  *************************************

endmodule

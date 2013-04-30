
module maze_state
	(
		input clk,
		input start_btn,
		input finished_carve,
		output start,
		output carve,
		output move
	);
	
	localparam [1:0] START = 0;
	localparam [1:0] CARVE = 1;
	localparam [1:0] MOVE = 2;
	
	reg [1:0] state = START;
	
	assign start = (state == START) ? 1'b1 : 1'b0;
	assign carve = (state == CARVE) ? 1'b1 : 1'b0;
	assign move = (state == MOVE)   ? 1'b1 : 1'b0;
	
	always @(posedge clk) begin
		
		case (state)
			START:
				begin
					if (start_btn)
						state <= CARVE;
				end
			CARVE:
				begin
					if (finished_carve & !start_btn)
						state <= MOVE;
				end
			MOVE:
				begin
					if (start_btn)
						state <= CARVE;
				end
			default:
				state <= START;
		endcase
		
	end
	
endmodule

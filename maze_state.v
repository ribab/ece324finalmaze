
module maze_state
	(
		input clk;
		input start_btn;
		input finished_carve;
		output start;
		output carve;
		output move;
	);
	
	localparam [1:0] START = 0;
	localparam [1:0] CARVE = 1;
	localparam [1:0] MOVE = 2;
	
	reg start_btn_pressed = 0;
	
	reg [1:0] state == START;
	
	always @(posedge clk) begin
		
		case (state)
			START:
				begin
					if (start_btn_pressed)
						state <= CARVE;
				end
			CARVE:
				begin
					if (finished_carve)
						state <= MOVE;
				end
			MOVE:
				begin
					if (start_btn_pressed)
						state <= CARVE;
				end
			default:
				state <= START;
		endcase
					
		if (start_btn &&
			!start_btn_pressed &&
			!start_btn_press_started) begin
			start_btn_pressed <= 1;
			start_btn_pressed_started <= 1;
		end else
			start_btn_pressed <= 0;
		if (!start_btn)
			start_btn_press_started <= 0;
		
	end
	
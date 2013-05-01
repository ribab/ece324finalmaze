
/***********************************************
*  ECE324 Digital Systems Design:  Maze Generator
*  John Hofman, Candice Adsero, & Ricky Barella
*  maze_state module
************************************************/

module maze_state
	(
		input clk,              // clock input
		input start_btn,        // start button pressed
		input finished_carve,   // carving algorithm is done
		output start,           // maze_state is at start
		output carve,           // maze_state is at carve
		output move             // maze_state is at move
	);
	
    // state definitions
	localparam [1:0] START = 0;
	localparam [1:0] CARVE = 1;
	localparam [1:0] MOVE = 2;
	
    // state register
	reg [1:0] state = START;
	
    // assign outputs
	assign start = (state == START) ? 1'b1 : 1'b0;
    assign carve = (state == CARVE) ? 1'b1 : 1'b0;
    assign move = (state == MOVE)   ? 1'b1 : 1'b0;
	
    always @(posedge clk)
        case (state)
            START:      // maze generator starts out on start screen
                begin
                    if (start_btn)
                        state <= CARVE;
                end
            CARVE:      // start_btn activates carving algorithm
                begin
                    if (finished_carve & !start_btn)
                        state <= MOVE;
                end
            MOVE:       // when carving algorithm is finished, movement
                        // code is activated
                begin
                    if (start_btn)
                        state <= CARVE;
                end
            default:    // Go back to start screen when state machine
                        // fails
                state <= START;
        endcase
    
endmodule

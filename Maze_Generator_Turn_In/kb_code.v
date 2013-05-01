// From Pong Chu, "FPGA Protyping by Verilog Examples", Listing 9.3
// Modified by Lukas Boler, Johnny Ung - 22 Apr 2011
module kb_code
   #(parameter W_SIZE = 2)  // 2^W_SIZE words in FIFO
   (
    input wire clk, reset,
    input wire ps2d, ps2c, rd_key_code,
    output wire [7:0] key_code,
    output wire kb_buf_empty
   );

   // constant declaration
   localparam BRK = 8'hf0; // break code

   // symbolic state declaration
   localparam
      wait_brk = 1'b0,
      get_code = 1'b1;

   // signal declaration
   reg state_reg, state_next;
   wire [7:0] scan_out;
   reg got_code_tick;
   wire scan_done_tick;

   // body
   //====================================================
   // instantiation
   //====================================================
   // instantiate ps2 receiver
   ps2_rx ps2_rx_unit
      (.clk(clk), .reset(reset), .rx_en(1'b1),
       .ps2d(ps2d), .ps2c(ps2c),
		   .rx_done_tick(scan_done_tick), .dout(scan_out));

   // instantiate fifo buffer
   fifo #(.B(8), .W(W_SIZE)) fifo_key_unit
     (.clk(clk), .reset(reset), .rd(rd_key_code),
      .wr(got_code_tick), .w_data(scan_out),
      .empty(kb_buf_empty), .full(),
      .r_data(key_code));

   //=======================================================
   // FSM to get the scan code after F0 received
   //=======================================================
   // state registers
   always @(posedge clk, posedge reset)
      if (reset)
         state_reg <= wait_brk;
      else
         state_reg <= state_next;

   // next-state logic
   always @*
   begin
      got_code_tick = 1'b0;
      state_next = state_reg;
      case (state_reg)
         wait_brk:  //get the following scan code <--- Modified the existing state machine to output
						  //got_code_tick as 1 whenever scan_done_tick is receieved
						  //the state machine no longer functions as a state machine since all states are identical
						  //this change allows the make code from a key to be read without waiting for the
						  //break code (users don't have to let go of a key before it is read)
            if (scan_done_tick==1'b1)
              begin
               got_code_tick = 1'b1;
               state_next = get_code;
             end
         get_code:  //get the following scan code 
            if (scan_done_tick)
               begin
                  got_code_tick =1'b1;
                  state_next = wait_brk;
               end
      /*
      case (state_reg)
         wait_brk:  // wait for F0 of break code
            if (scan_done_tick==1'b1 && scan_out==BRK)
               state_next = get_code;
         get_code:  // get the following scan code
            if (scan_done_tick)
               begin
                  got_code_tick =1'b1;
                  state_next = wait_brk;
               end
               */
      endcase
   end

endmodule

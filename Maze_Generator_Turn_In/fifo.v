// From Pong Chu, "FPGA Protyping by Verilog Examples", Listing 4.20
// Modified by Lukas Boler, Johnny Ung 22 Apr 2011
module fifo
   #(
    parameter B=8, // number of bits in a word
              W=1  // number of address bits
   )
   (
    input wire clk, reset,
    input wire rd, wr,
    input wire [B-1:0] w_data,
    output wire empty, full,
    output wire [B-1:0] r_data
   );

   // constant declaration
   localparam BRK = 8'hf0; // break code

   //signal declaration
   reg [B-1:0] array_reg;  // register array
   reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
   reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
   reg full_reg, empty_reg, full_next, empty_next;
   wire wr_en;
   reg ignore_next=0;
	
   // body
   // register file write operation
   always @(posedge clk) begin
    if (wr_en && w_data==BRK) begin
         array_reg <= 8'b00000000;
         ignore_next <= 1;
       end
    else if (wr_en && ignore_next)
         ignore_next <= 0; 
    else if (wr_en && ~ignore_next)
         array_reg <= w_data;
		end
		//if (wr_en)
   //      array_reg <= w_data;
		
   // register file read operation
   assign r_data = array_reg;
   // write enabled only when FIFO is not full
   assign wr_en = wr;

   // fifo control logic
   // register for read and write pointers
   always @(posedge clk, posedge reset)
      if (reset)
         begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;
         end
      else
         begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
         end

   // next-state logic for read and write pointers
   always @*
   begin
      // successive pointer values
      w_ptr_succ = w_ptr_reg + 1;
      r_ptr_succ = r_ptr_reg + 1;
      // default: keep old values
      w_ptr_next = w_ptr_reg;
      r_ptr_next = r_ptr_reg;
      full_next = full_reg;
      empty_next = empty_reg;
      case ({wr, rd})
         // 2'b00:  no op
         2'b01: // read
            if (~empty_reg) // not empty
               begin
                  r_ptr_next = r_ptr_succ;
                  full_next = 1'b0;
                  if (r_ptr_succ==w_ptr_reg)
                     empty_next = 1'b1;
               end
         2'b10: // write
            if (~full_reg) // not full
               begin
                  w_ptr_next = w_ptr_succ;
                  empty_next = 1'b0;
                  if (w_ptr_succ==r_ptr_reg)
                     full_next = 1'b1;
               end
         2'b11: // write and read
            begin
               w_ptr_next = w_ptr_succ;
               r_ptr_next = r_ptr_succ;
            end
      endcase
   end

   // output
   assign full = full_reg;
   assign empty = empty_reg;

endmodule


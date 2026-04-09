module secure_read_write_register_bank #(
   parameter p_address_width = 8,
   parameter p_data_width    = 8,
   parameter p_unlock_code_0 = 8'hAB,
   parameter p_unlock_code_1 = 8'hCD
) (
   input  wire [p_address_width-1:0] i_addr,          // target address
   input  wire [p_data_width-1:0]    i_data_in,       // data input for write
   input  wire                       i_read_write_enable, // 0: write, 1: read
   input  wire                       i_capture_pulse,     // capture pulse (clock)
   input  wire                       i_rst_n,             // asynchronous active low reset
   output reg  [p_data_width-1:0]    o_data_out          // data output
);

   // Unlock state machine states:
   // 0: WAIT_FOR_UNLOCK0 (waiting for correct code at address 0)
   // 1: WAIT_FOR_UNLOCK1 (waiting for correct code at address 1)
   // 2: UNLOCKED
   reg [1:0] unlock_state;

   // Register to hold read data for output
   reg [p_data_width-1:0] read_data_reg;

   // Memory array for the register bank
   // Size is 2^(p_address_width) registers.
   reg [p_data_width-1:0] mem [(1<<p_address_width)-1:0];

   // Synchronous process triggered on the rising edge of i_capture_pulse or asynchronous reset.
   always @(posedge i_capture_pulse or negedge i_rst_n) begin
      if (!i_rst_n) begin
         // Reset: clear unlock state machine (and optionally clear memory)
         unlock_state <= 0;  // Set to WAIT_FOR_UNLOCK0
         // Optional: clear memory registers if desired.
      end
      else begin
         if (!i_read_write_enable) begin
            // Write operation
            if (unlock_state != 2) begin
               // Unlock sequence not complete: only addresses 0 and 1 are allowed.
               if ((i_addr == 0) || (i_addr == 1)) begin
                  // Check for correct unlock sequence based on current state.
                  if ((unlock_state == 0) && (i_addr == 0) && (i_data_in == p_unlock_code_0)) begin
                     // First unlock code received at address 0: transition to WAIT_FOR_UNLOCK1.
                     unlock_state <= 1;
                     mem[0] <= i_data_in;  // Store the unlock code.
                  end
                  else if ((unlock_state == 1) && (i_addr == 1) && (i_data_in == p_unlock_code_1)) begin
                     // Second unlock code received at address 1: unlock complete.
                     unlock_state <= 2;
                     mem[1] <= i_data_in;  // Store the trigger code.
                  end
                  else begin
                     // Incorrect code written to address 0 or 1: reset unlock sequence.
                     unlock_state <= 0;
                  end
               end
               // If i_addr is not 0 or 1, no write is performed.
            end
            else begin
               // Unlock sequence complete: allow writes to any address.
               mem[i_addr] <= i_data_in;
            end
         end
         else begin
            // Read operation
            if ((unlock_state == 2) && (i_addr != 0) && (i_addr != 1)) begin
               // Read allowed only for addresses other than 0 and 1.
               read_data_reg <= mem[i_addr];
            end
            else begin
               // Either not unlocked or attempting to read from address 0 or 1: output 0.
               read_data_reg <= 0;
            end
         end
      end
   end

   // Drive the output with the read data register.
   assign o_data_out = read_data_reg;

endmodule
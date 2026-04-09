module binary_multiplier #(
    parameter WIDTH = 32  // Bit-width of operands A and B
)(
    input  logic         clk,       // Clock signal
    input  logic         rst_n,     // Active-low asynchronous reset
    input  logic         valid_in,  // Indicates when inputs are valid
    input  logic [WIDTH-1:0] A,       // Operand A
    input  logic [WIDTH-1:0] B,       // Operand B
    output logic [2*WIDTH-1:0] Product,// Final multiplication result
    output logic         valid_out  // Indicates when Product is valid
);

   // Internal registers to latch inputs and hold computation results
   logic [WIDTH-1:0] A_reg;
   logic [WIDTH-1:0] B_reg;
   logic [2*WIDTH-1:0] acc; // Accumulator for the product
   integer i;               // Loop counter for sequential multiplication

   // State machine declaration
   typedef enum logic [1:0] {
      IDLE,   // Waiting for valid_in
      COMPUTE,// Performing the add-shift multiplication over WIDTH cycles
      WAIT,   // Waiting for an additional 2 cycles delay
      OUTPUT  // Latching the final result and asserting valid_out
   } state_t;
   state_t state;

   // Delay counter for the WAIT state (2-cycle delay)
   logic [1:0] delay_counter;

   // Sequential state machine: Implements a total latency of WIDTH+2 cycles.
   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         state            <= IDLE;
         A_reg            <= '0;
         B_reg            <= '0;
         acc              <= '0;
         i                <= 0;
         valid_out        <= 1'b0;
         Product          <= '0;
         delay_counter    <= 2'b00;
      end
      else begin
         case (state)
            IDLE: begin
               // Latch inputs and initialize when valid_in is asserted
               if (valid_in) begin
                  A_reg    <= A;
                  B_reg    <= B;
                  acc      <= '0;
                  i        <= 0;
                  valid_out<= 1'b0;
                  Product  <= '0;
                  delay_counter <= 2'b00;
                  state    <= COMPUTE;
               end
            end

            COMPUTE: begin
               // Perform the add-shift multiplication sequentially.
               // For each bit in A_reg, if the bit is 1, add (B_reg << i) to acc.
               if (i < WIDTH) begin
                  if (A_reg[i])
                     acc <= acc + (B_reg << i);
                  i <= i + 1;
               end
               else begin
                  // Completed the WIDTH-cycle computation; move to WAIT state.
                  state <= WAIT;
               end
            end

            WAIT: begin
               // Wait for 2 additional cycles before outputting the result.
               if (delay_counter < 2)
                  delay_counter <= delay_counter + 1;
               else
                  state <= OUTPUT;
            end

            OUTPUT: begin
               // Latch the final accumulated product and assert valid_out.
               Product   <= acc;
               valid_out <= 1'b1;
               // Transition back to IDLE for the next operation.
               state     <= IDLE;
            end

            default: state <= IDLE;
         endcase
      end
   end

endmodule
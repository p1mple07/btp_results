
module restoring_division #(parameter WIDTH = 6, parameter int LOG2_WIDTH = $clog2(WIDTH), parameter int MAX_ITER = ((1 << LOG2_WIDTH) == WIDTH) ? WIDTH : WIDTH+1) (
    input  logic         clk,
    input  logic         rst,   // active low asynchronous reset
    input  logic         start,
    input  logic [WIDTH-1:0] dividend,
    input  logic [WIDTH-1:0] divisor,
    output logic [WIDTH-1:0] quotient,
    output logic [WIDTH-1:0] remainder,
    output logic          valid
);

  // internal registers
  logic [WIDTH-1:0] dividend_reg;
  logic [WIDTH-1:0] quotient_reg;
  logic [WIDTH-1:0] remainder_reg;
  logic [LOG2_WIDTH:0] counter; // counter runs from MAX_ITER-1 downto 0

  typedef enum logic {IDLE, DIVIDE} state_t;
  state_t state, next_state;

  // temporary variable for quotient bit
  logic quotient_bit;

  // asynchronous reset
  always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
       state <= IDLE;
       dividend_reg <= '0;
       quotient_reg <= '0;
       remainder_reg <= '0;
       counter <= MAX_ITER - 1;
       valid <= 1'b0;
    end else begin
       state <= next_state;
       if (state == DIVIDE) begin
         if (counter == 0) begin
           // final cycle: output result and assert valid for one cycle
           quotient_reg <= quotient_reg; // hold
           remainder_reg <= remainder_reg; // hold
           valid <= 1'b1;
         end else begin
           valid <= 1'b0;
         end
       end
       // outputs assignment in always_ff block might be tricky because outputs are registered.
       // Instead, we assign outputs continuously.
    end
  end

  // Next state logic
  always_comb begin
     next_state = state;
     case (state)
       IDLE: begin
           if (start) begin
              next_state = DIVIDE;
           end else begin
              next_state = IDLE;
           end
       end
       DIVIDE: begin
           if (counter == 0)
              next_state = IDLE;
           else
              next_state = DIVIDE;
       end
       default: next_state = IDLE;
     endcase
  end

  // Division process
  always_ff @(posedge clk) begin
     if (state == DIVIDE) begin
       if (counter != 0) begin
         // Save old remainder for possible restoration
         logic [WIDTH-1:0] old_remainder;
         old_remainder <= remainder_reg;
         // Shift remainder left and append MSB of dividend_reg
         remainder_reg <= (remainder_reg << 1) | dividend_reg[WIDTH-1];
         // Shift dividend_reg left
         dividend_reg <= dividend_reg << 1;
         // Check if subtraction is valid
         if (remainder_reg >= divisor) begin
            remainder_reg <= remainder_reg - divisor;
            quotient_bit <= 1;
         end else begin
            remainder_reg <= old_remainder; // restore remainder
            quotient_bit <= 0;
         end
         // Update quotient_reg: shift left and add quotient_bit
         quotient_reg <= (quotient_reg << 1) | quotient_bit;
         counter <= counter - 1;
       end
     end else if (state == IDLE) begin
       // Load new inputs when start is asserted
       if (start) begin
         dividend_reg <= dividend;
         quotient_reg <= 0;
         remainder_reg <= 0;
         counter <= MAX_ITER - 1;
       end
     end
  end

  // Output assignment
  always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
       quotient <= '0;
       remainder <= '0;
       valid <= 1'b0;
    end else begin
       quotient <= quotient_reg;
       remainder <= remainder_reg;
       // valid is asserted only in the last cycle of DIVIDE state
       if (state == DIVIDE && counter == 0)
         valid <= 1'b1;
       else
         valid <= 1'b0;
    end
  end

endmodule

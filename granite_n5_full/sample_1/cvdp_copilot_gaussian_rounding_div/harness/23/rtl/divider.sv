module divider #(parameter WIDTH = 8) (
  input  wire  [WIDTH-1:0]    dividend,   // Dividend (numerator)
  input  wire  [WIDTH-1:0]    divisor,    // Divisor (denominator)
  output wire  [WIDTH-1:0]    quotient,   // Result of the division
  output wire  [WIDTH-1:0]    remainder,  // Remainder after division
  output wire                         valid       // Indicates output is valid
);

  // one extra bit for A
  localparam AW = WIDTH + 1;
  
  // Simple 3-state FSM
  localparam IDLE = 2'b00;
  localparam BUSY = 2'b01;
  localparam DONE = 2'b10;

  reg [1:0] state_reg, state_next;

  // A+Q combined into one WIDTH + 1 + WIDTH register:
  reg [AW+WIDTH-1 : 0] aq_reg,   aq_next;

  // Divisor register
  reg [AW-1 : 0]   m_reg,    m_next;

  // Iterate exactly WIDTH times
  reg [$clog2(WIDTH)-1:0]   n_reg, n_next;

  // Final outputs
  reg [WIDTH-1 : 0]   quotient_reg, quotient_next;
  reg [WIDTH-1 : 0]   remainder_reg, remainder_next;
  reg                       valid_reg, valid_next;

  //------------------------------------------------
  // SEQUENTIAL: State & register updates
  //------------------------------------------------
  always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
          state_reg     <= IDLE;
          aq_reg        <= 0;
          m_reg         <= 0;
          n_reg         <= $clog2(WIDTH);
          quotient_reg  <= 0;
          remainder_reg <= 0;
          valid_reg     <= 0;
      end
      else begin
          // Default "hold" behavior
          valid_reg     <= 1'b0;

          if (start) begin
              // Outputs not valid yet
              valid_reg     <= 1'b0;

              // Step-1: Initialize
              //                |  |a|   |a| value of |a|.
              //                |r|   |r|.
              //                |m|   |m|   |m|
              //                |n|   |n|   for N iterations.
              //
                //... (contents of directory)
                //...

endmodule
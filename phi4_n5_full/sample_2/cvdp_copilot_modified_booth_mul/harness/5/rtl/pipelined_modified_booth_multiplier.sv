module pipelined_modified_booth_multiplier (
    input         clk,
    input         rst,
    input         start,
    input signed [15:0] X,
    input signed [15:0] Y,
    output reg signed [31:0] result,
    output reg         done
);

  // Pipeline registers and temporary signals
  reg signed [31:0] partial_products [0:7];
  reg signed [15:0] X_reg, Y_reg;
  reg signed [31:0] s1, s2, s3, s4;
  // temp_products1 and temp_products2 are declared but not used in this implementation

  // Use a simple state machine to control the 5-stage pipeline.
  // State encoding:
  //   0: Idle / Input Latching
  //   1: Booth Encoding and Partial Product Generation
  //   2: Partial Product Reduction
  //   3: Sum of Sums
  //   4: Final Result
  reg [2:0] state;

  integer i;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      X_reg      <= 16'd0;
      Y_reg      <= 16'd0;
      state      <= 3'd0;
      done       <= 1'b0;
      result     <= 32'd0;
      for (i = 0; i < 8; i = i + 1)
        partial_products[i] <= 32'd0;
      s1 <= 32'd0; s2 <= 32'd0; s3 <= 32'd0; s4 <= 32'd0;
    end
    else begin
      case (state)
        3'd0: begin
          // Idle: Latch inputs when start is asserted.
          if (start) begin
            X_reg <= X;
            Y_reg <= Y;
            state <= 3'd1;
          end
        end

        3'd1: begin
          // Stage 1: Booth Encoding and Partial Product Generation.
          // Divide Y_reg into overlapping 3-bit groups.
          for (i = 0; i < 8; i = i + 1) begin
            case ({Y_reg[2*i+1], Y_reg[2*i], (i==0)? 1'b0 : Y_reg[2*i-1]})
              3'b000, 3'b111: partial_products[i] <= 32'd0;
              3'b001, 3'b010: partial_products[i] <= {{16{X_reg[15]}}, X_reg} >> (2*i);
              3'b011: partial_products[i] <= {{16{X_reg[15]}}, X_reg} >> (2*i + 1);
              3'b100: partial_products[i] <= -({{16{X_reg[15]}}, X_reg} >> (2*i + 1));
              3'b101, 3'b110: partial_products[i] <= -({{16{X_reg[15]}}, X_reg} >> (2*i));
              default: partial_products[i] <= 32'd0;
            endcase
          end
          state <= 3'd2;
        end

        3'd2: begin
          // Stage 2: Partial Product Reduction.
          s1 <= partial_products[0] + partial_products[1] + partial_products[2];
          s2 <= partial_products[3] + partial_products[4] + partial_products[5];
          state <= 3'd3;
        end

        3'd3: begin
          // Stage 3: Sum of Sums.
          s3 <= s1 + s2;
          s4 <= partial_products[6] + partial_products[7];
          state <= 3'd4;
        end

        3'd4: begin
          // Stage 4: Final Result.
          result <= s3 + s4;
          done   <= 1'b1;
          state  <= 3'd0;  // Return to idle for the next multiplication.
        end

        default: state <= 3'd0;
      endcase
    end
  end

endmodule
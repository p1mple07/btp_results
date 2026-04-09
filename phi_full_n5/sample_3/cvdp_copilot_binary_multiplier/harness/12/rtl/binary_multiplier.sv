module binary_multiplier #(
    parameter WIDTH = 32  // Set the width of inputs
) (
    input  logic clk,         // Clock signal
    input  logic rst_n,       // Active-low asynchronous reset
    input  logic valid_in,    // Indicates when inputs are valid
    input  logic [WIDTH-1:0] A, // Input A
    input  logic [WIDTH-1:0] B, // Input B
    output logic valid_out,   // Output valid
    output logic [2*WIDTH-1:0] Product // Output Product
);

  integer i;
  logic [2*WIDTH-1:0] sum;  // Intermediate sum for unsigned multiplication
  logic start, done;        // Control signals

  // Registers to hold inputs A and B
  logic [WIDTH-1:0] A_reg, B_reg;

  // State machine for sequential multiplication
  always_ff @(posedge clk, posedge rst_n) begin
    if (rst_n) begin
      sum <= 0;
      start <= 1'b0;
      done <= 1'b0;
    end else begin
      if (valid_in) begin
        A_reg <= A;
        B_reg <= B;
        start <= 1'b1;
      end else begin
        start <= 1'b0;
      end

      // Latches for the accumulation and final output stage
      @(posedge clk) begin
        if (start) begin
          sum <= 0;
          for (i = 0; i < WIDTH; i = i + 1) begin
            if (A_reg[i]) begin
              sum <= sum + (B_reg << i); // Add shifted value of B
            end
          end
          if (i == WIDTH) begin
            done <= 1'b1;
          end
        end
      end

      // Register the accumulated result and reset control
      @(posedge clk) begin
        if (done) begin
          Product <= sum;
          done <= 1'b0;
        end
        if (rst_n) begin
          sum <= 0;
          start <= 1'b0;
          done <= 1'b0;
        end
      end
    end

    // Output valid signal
    valid_out <= done;
  end

endmodule

module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,  // Width of the input data
    parameter SEQUENCE_LENGTH = 10 // Number of terms in the progression
)(
    input  logic clk,
    input  logic resetn,
    input  logic enable,
    input  logic [DATA_WIDTH-1:0] start_val,
    input  logic [DATA_WIDTH-1:0] step_size,
    output logic [WIDTH_OUT_VAL-1:0] out_val,
    output logic done
);

  // Define WIDTH_OUT_VAL conditionally to avoid math domain error when SEQUENCE_LENGTH == 0
  localparam WIDTH_OUT_VAL = (SEQUENCE_LENGTH == 0) ? DATA_WIDTH : ($clog2(SEQUENCE_LENGTH) + DATA_WIDTH);

  generate
    if (SEQUENCE_LENGTH == 0) begin : zero_seq
      // When SEQUENCE_LENGTH is 0, no sequence is generated.
      // out_val remains at its reset value (0) and done is never asserted.
      assign out_val = {DATA_WIDTH{1'b0}};
      assign done = 1'b0;
    end else begin : nonzero_seq
      // Internal signals for sequence generation
      logic [$clog2(SEQUENCE_LENGTH)-1:0] counter;
      logic [WIDTH_OUT_VAL-1:0] current_val;

      // Procedural block for arithmetic progression generation
      always_ff @(posedge clk or negedge resetn) begin
          if (!resetn) begin
              current_val <= 0;
              counter    <= 0;
              done       <= 1'b0;
          end else if (enable) begin
              if (!done) begin
                  if (counter == 0) begin
                      current_val <= start_val; // Initialize with start value
                  end else begin
                      current_val <= current_val + step_size; // Compute next term
                  end

                  if (counter < SEQUENCE_LENGTH - 1) begin
                      counter <= counter + 1; // Increment counter
                  end else begin
                      done <= 1'b1; // Mark completion
                  end
              end
          end
      end

      // Combinational assignment for output
      assign out_val = current_val;
    end
  endgenerate

endmodule
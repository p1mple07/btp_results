module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,  // Width of the input data
    parameter SEQUENCE_LENGTH = 10 // Number of terms in the progression
)(
    input clk,
    input logic resetn,
    input logic enable,
    input logic [DATA_WIDTH-1:0] start_val,
    input logic [DATA_WIDTH-1:0] step_size,
    output logic [WIDTH_OUT_VAL-1:0] out_val,
    output logic done
);

  // ----------------------------------------
  // - Local parameter definition
  // ----------------------------------------
  localparam WIDTH_OUT_VAL = DATA_WIDTH + SEQUENCE_LENGTH - 1;  // Calculate output width to avoid overflow

  // ----------------------------------------
  // - Interface Definitions
  // ----------------------------------------
    // (interface definitions remain the same)

  // ----------------------------------------
  // - Internal signals
  // ----------------------------------------
    logic [WIDTH_OUT_VAL-1:0] current_val;  // Register to hold the current value
    logic [$clog2(SEQUENCE_LENGTH)-1:0] counter;  // Counter to track sequence length

  // ----------------------------------------
  // - Procedural block
  // ----------------------------------------
  always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            current_val <= 0;
            counter <= 0;
            done <= 1'b0;
        end else if (enable) begin
            if (!done) begin
                current_val <= start_val + step_size * counter;  // Compute current_val
                if (counter == SEQUENCE_LENGTH - 1) begin
                    done <= 1'b1;  // Assert done when sequence length is reached
                end else begin
                    counter <= counter + 1;  // Increment counter
                end
            end
        end
    end

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
    assign out_val = current_val;

endmodule

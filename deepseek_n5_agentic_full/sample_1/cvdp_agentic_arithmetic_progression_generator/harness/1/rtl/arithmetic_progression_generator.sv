module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,
    parameter SEQUENCE_LENGTH = 10
)(
   clk,
    resetn,
    enable,
    start_val,
    step_size,
    out_val,
    done
);
  // Check for zero sequence length
  if (SEQUENCE_LENGTH == 0) begin
      current_val <= 0;
      out_val <= 0;
      done <= 0;
      return;
  end

  localparam WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH) + DATA_WIDTH;

  input logic [DATA_WIDTH-1:0] start_val;
  input logic [DATA_WIDTH-1:0] step_size;
  output logic [WIDTH_OUT_VAL-1:0] out_val;
  output logic done;

  logic [WIDTH_OUT_VAL-1:0] current_val;
  logic [$clog2(SEQUENCE_LENGTH)-1:0] counter;

  always_ff @(posedge clk or negedge resetn) begin
      if (!resetn) begin
          current_val <= 0;
          counter <= 0;
          done <= 1'b0;
      end else if (enable) begin
          if (!done) begin
              if (counter == 0) begin
                  current_val <= start_val;
              end else begin
                  // Saturation arithmetic to handle potential overflows
                  wire [WIDTH_OUT_VAL-1:0] temp_val = current_val + step_size;
                  if (temp_val > (1 << WIDTH_OUT_VAL - 1)) begin
                      temp_val <= (1 << WIDTH_OUT_VAL - 1);
                  end else if (temp_val < 0) begin
                      temp_val <= 0;
                  end
                  current_val <= temp_val;
              end

              if (counter < SEQUENCE_LENGTH - 1) begin
                  counter <= counter + 1;
              end else begin
                  done <= 1'b1;
              end
          end
      end
  end

  assign out_val = current_val;
endmodule
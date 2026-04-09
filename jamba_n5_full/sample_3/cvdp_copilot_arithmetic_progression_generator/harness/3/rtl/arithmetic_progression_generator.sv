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

  localvar integer max_val = start_val + (SEQUENCE_LENGTH - 1) * step_size;
  localvar wire [WIDTH_OUT_VAL - 1:0] temp;
  assign WIDTH_OUT_VAL = bit_width(max_val);

  // ----------------------------------------
  // - Internal signals
  // ----------------------------------------
  logic [WIDTH_OUT_VAL-1:0] current_val; 
  logic [$clog2(SEQUENCE_LENGTH)-1:0] counter; 

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
                if (!counter) begin
                    current_val <= start_val;
                    counter <= 0;
                end else begin
                    current_val = current_val + step_size;
                    counter++;
                end
            end else begin
                done <= 1'b1;
            end
        end
    end

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
  assign out_val = current_val;

endmodule

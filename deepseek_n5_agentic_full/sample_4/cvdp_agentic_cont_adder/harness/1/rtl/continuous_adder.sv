module continuous_adder #(
    parameter integer DATA_WIDTH       = 32,
    parameter integer ENABLE_THRESHOLD = 0,
    parameter integer THRESHOLD        = 16,
    parameter integer REGISTER_OUTPUT  = 0
)

    input  wire  [DATA_WIDTH-1:0] data_in,
    input  wire     clock,
    input  wire      rst_n,
    input  wire     valid_in,
    input  wire  [DATA_WIDTH-1:0] accumulate_enable,
    input  wire     flush,

    output reg   [DATA_WIDTH-1:0] sum_out,
    output reg   sum_valid
);

    // Internals
    reg     [DATA_WIDTH-1:0] sum_reg = 0;
    reg     [DATA_WIDTH-1:0] expected_sum;
    reg     [DATA_WIDTH-1:0] expected_sum_delay;

    always @posedge clock or posedge rst_n begin
        // Accumulate phase
        if (valid_in && accumulate_enable) begin
            sum_reg += data_in;
        end else if (flush) begin
            sum_reg = 0;
        end

        // Check threshold
        if (ENABLE_THRESHOLD > 0) begin
            if (sum_reg >= THRESHOLD && !sum_valid) begin
                sum_out = sum_reg;
                sum_valid = 1;
            end
        end
    end

    // Synchronize output if required
    always @posedge clock begin
        expected_sum_delay <= expected_sum;
        if (sum_valid) begin
            if (sum_out != expected_sum_delay) begin
                $display("Mismatch at %0t: expected=%h got=%h", $time, expected_sum_delay, sum_out);
            end else begin
                $display("Match at %0t: sum=%h", $time, sum_out);
            end
        end
    end
endmodule
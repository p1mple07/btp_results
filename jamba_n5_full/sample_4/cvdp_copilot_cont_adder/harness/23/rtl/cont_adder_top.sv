module continuous_adder #(
    parameter DATA_WIDTH = 32,
    parameter THRESHOLD_VALUE_1 = 50,
    parameter THRESHOLD_VALUE_2 = 100,
    parameter SIGNED_INPUTS = 1,
    parameter WEIGHT = 1,
    parameter WINDOW_SIZE = 5
) (
    input logic clk,
    input logic reset,
    input logic signed [DATA_WIDTH-1:0] data_in,
    input logic data_valid,
    output logic signed [DATA_WIDTH-1:0] sum_out,
    output logic sum_ready,
    output logic avg_out,
    output logic threshold_1,
    output logic threshold_2
);

    logic signed [DATA_WIDTH-1:0] sum_accum;
    logic signed [DATA_WIDTH-1:0] weighted_input;
    logic signed [DATA_WIDTH-1:0] sum_accum;

    always_ff @(posedge clk) begin
        if (reset) begin
            sum_accum         <= {DATA_WIDTH{1'b0}};
            sum_ready         <= 1'b0;
            sum_out           <= {DATA_WIDTH{1'b0}};
            threshold_1       <= 1'b0;
            threshold_2       <= 1'b0;
            avg_out           <= 0;
        end else begin
            if (data_valid) begin
                weighted_input = data_in * WEIGHT;
                sum_accum     <= sum_accum + weighted_input;

                if (SIGNED_INPUTS) begin
                    if ((sum_accum + data_in >= THRESHOLD_VALUE) || (sum_accum + data_in <= -1*THRESHOLD_VALUE)) begin
                        sum_ready <= 1'b1;
                        sum_out   <= sum_accum + data_in;
                        sum_accum <= {DATA_WIDTH{1'b0}};
                    end else begin
                        sum_ready <= 1'b0;
                    end
                end else begin
                    if (sum_accum + data_in >= THRESHOLD_VALUE) begin
                        sum_ready <= 1'b1;
                        sum_out   <= sum_accum + data_in;
                        sum_accum <= {DATA_WIDTH{1'b0}};
                    end else begin
                        sum_ready <= 1'b0;
                    end
                end
            end
        end
    end

    always_ff @(posedge clk) begin
        if (sum_ready) begin
            avg_out <= sum_accum / WINDOW_SIZE;
            sum_ready <= 1'b0;
        end else begin
            avg_out <= 0;
        end
    end

endmodule

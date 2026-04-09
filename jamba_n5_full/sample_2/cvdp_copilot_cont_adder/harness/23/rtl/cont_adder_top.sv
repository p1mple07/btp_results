module continuous_adder #(
    parameter DATA_WIDTH = 32,
    parameter THRESHOLD_VALUE_1 = 50,
    parameter THRESHOLD_VALUE_2 = 100,
    parameter SIGNED_INPUTS = 1,
    parameter WEIGHT = 1,
    parameter window_size = 5
) (
    input logic          clk,
    input logic          reset,
    input logic signed   [DATA_WIDTH-1:0] data_in,
    input logic          data_valid,
    output logic signed  [DATA_WIDTH-1:0] sum_out,
    output logic sum_ready,
    output logic [DATA_WIDTH-1:0] avg_out,
    output logic sum_ready_reg
);

    logic signed [DATA_WIDTH-1:0] sum_accum;
    logic signed [DATA_WIDTH-1:0] sum_out_temp;
    logic sum_ready_flag;
    logic sample_count;
    logic threshold_1_crossed, threshold_2_crossed;

    // Initialise internal registers
    initial begin
        sum_accum  = 0;
        sum_out     = 0;
        sum_ready   = 1'b0;
        avg_out     = 0;
        sum_ready_reg = 1'b1;
        sample_count = 0;
    end

    // Handle clock edge and reset
    always_ff @(posedge clk) begin
        if (reset) begin
            sum_accum  <= {DATA_WIDTH{1'b0}};
            sum_ready   = 1'b0;
            sum_out     = {DATA_WIDTH{1'b0}};
            sum_ready_reg = 1'b1;
        end
        else begin
            if (data_valid) begin
                if (SIGNED_INPUTS) begin
                    data_in = signed'(data_in);
                end
                weighted_input = data_in * WEIGHT;
                sum_accum        = sum_accum + weighted_input;

                // Detect threshold crossings
                threshold_1_crossed = sum_accum >= THRESHOLD_VALUE_1 ||
                                    sum_accum <= -THRESHOLD_VALUE_1;
                threshold_2_crossed = sum_accum >= THRESHOLD_VALUE_2 ||
                                    sum_accum <= -THRESHOLD_VALUE_2;

                // Update outputs based on mode
                if (ACCUM_MODE == 0) begin
                    if (threshold_1_crossed || threshold_2_crossed) begin
                        sum_ready = 1'b1;
                        sum_out     = sum_accum;
                        sum_ready_reg = 1'b1;
                    end
                    else begin
                        sum_ready = 1'b0;
                    end
                end
                else begin
                    if (sum_accum >= THRESHOLD_VALUE_1) begin
                        sum_ready_flag = 1'b1;
                        sum_out     = sum_accum + data_in;
                        sum_ready_reg = 1'b1;
                    end
                    else if (sum_accum >= THRESHOLD_VALUE_2) begin
                        sum_ready_flag = 1'b1;
                        sum_out     = sum_accum + data_in;
                        sum_ready_reg = 1'b1;
                    end
                    else begin
                        sum_ready_flag = 1'b0;
                    end
                end
            end
        end
    end

    // Output signals
    assign sum_out = sum_out_temp;
    assign avg_out  = sample_count == window_size ? avg_out_val : 0;
    assign sum_ready_reg = sum_ready_flag;
    assign sum_ready   = sum_ready_reg;

endmodule

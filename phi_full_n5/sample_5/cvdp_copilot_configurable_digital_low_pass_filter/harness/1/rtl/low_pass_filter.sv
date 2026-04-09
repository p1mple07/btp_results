module low_pass_filter #(
    parameter DATA_WIDTH = 16,
    parameter COEFF_WIDTH = 16,
    parameter NUM_TAPS = 8
) (
    input clk,
    input reset,
    input [DATA_WIDTH * NUM_TAPS - 1:0] data_in,
    input valid_in,
    input [COEFF_WIDTH * NUM_TAPS - 1:0] coeffs,
    output reg [DATA_WIDTH + COEFF_WIDTH + $clog2(NUM_TAPS) - 1:0] data_out,
    output reg valid_out
);

    // Calculate NBW_MULT
    localparam NBW_MULT = DATA_WIDTH + COEFF_WIDTH;

    // Internal signals
    reg [DATA_WIDTH * NUM_TAPS - 1:0] data_reg;
    reg [COEFF_WIDTH * NUM_TAPS - 1:0] coeffs_reg;
    reg [DATA_WIDTH + COEFF_WIDTH + $clog2(NUM_TAPS) - 1:0] data_out_reg;

    // Internal signal breakdown

    // Internal representation
    always @(posedge clk) begin
        if (reset) begin
            data_reg <= {DATA_WIDTH{0}}, {COEFF_WIDTH{0}};
            coeffs_reg <= {COEFF_WIDTH{0}};
        end else if (valid_in) begin
            data_reg <= data_in;
            coeffs_reg <= coeffs;
        end
    end

    // 2D Conversion
    always @(*) begin
        case ({DATA_WIDTH * NUM_TAPS - 1:0})
            // Assuming the data and coefficients are already in the correct order
            default: begin
                data_reg = {DATA_WIDTH{data_in[NUM_TAPS*DATA_WIDTH - 1:0]},
                            {DATA_WIDTH{data_in[NUM_TAPS*DATA_WIDTH - 2 - 1:0]}},
                            ...
                            {DATA_WIDTH{data_in[0]}}} &
                          {COEFF_WIDTH{coeffs[NUM_TAPS*COEFF_WIDTH - 1:0]},
                           {COEFF_WIDTH{coeffs[NUM_TAPS*COEFF_WIDTH - 2 - 1:0]}},
                           ...
                           {COEFF_WIDTH{coeffs[0]}}}
                // Additional logic to handle NBW_MULT and summation will be implemented here
            end
        endcase
    end

    // Output reg to handle pipeline latency
    always @(posedge clk) begin
        if (reset) begin
            data_out_reg <= 0;
        end else begin
            data_out_reg <= data_out;
        end
    end

    // Output logic
    assign data_out = data_out_reg;
    assign valid_out = valid_in;

endmodule

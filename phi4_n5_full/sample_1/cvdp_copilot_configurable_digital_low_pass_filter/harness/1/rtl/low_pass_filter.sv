module low_pass_filter #(
    parameter integer DATA_WIDTH = 16,
    parameter integer COEFF_WIDTH = 16,
    parameter integer NUM_TAPS = 8,
    // NBW_MULT is derived internally as DATA_WIDTH + COEFF_WIDTH
    parameter integer NBW_MULT = DATA_WIDTH + COEFF_WIDTH
)(
    input  logic clk,
    input  logic reset,
    // Packed input: NUM_TAPS samples of signed DATA_WIDTH-bit values
    input  logic [DATA_WIDTH*NUM_TAPS-1:0] data_in,
    input  logic valid_in,
    // Packed coefficients: NUM_TAPS samples of signed COEFF_WIDTH-bit values
    input  logic [COEFF_WIDTH*NUM_TAPS-1:0] coeffs,
    // Output width: NBW_MULT + $clog2(NUM_TAPS)
    output logic [NBW_MULT+$clog2(NUM_TAPS)-1:0] data_out,
    output logic valid_out
);

    // Calculate the number of bits needed to represent NUM_TAPS
    localparam int NUM_TAPS_LOG = $clog2(NUM_TAPS);
    // Define the output width to accommodate the sum of up to NUM_TAPS products
    localparam int OUT_WIDTH = NBW_MULT + NUM_TAPS_LOG;

    // Internal registers to hold the unpacked input data and coefficients.
    // These registers are updated only when valid_in is asserted, or cleared on reset.
    logic signed [DATA_WIDTH-1:0] data_reg [0:NUM_TAPS-1];
    logic signed [COEFF_WIDTH-1:0] coeff_reg [0:NUM_TAPS-1];

    // Synchronous process: Register input data and coefficients.
    // If valid_in is high, unpack the packed vectors into the internal arrays.
    // Otherwise, retain the previously registered values.
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < NUM_TAPS; i++) begin
                data_reg[i] <= '0;
                coeff_reg[i] <= '0;
            end
            valid_out <= 1'b0;
        end else begin
            if (valid_in) begin
                for (int i = 0; i < NUM_TAPS; i++) begin
                    // Unpack the packed bit vectors into arrays.
                    // Each element is extracted using a part-select with the -: operator.
                    data_reg[i] <= data_in[((i+1)*DATA_WIDTH)-1 -: DATA_WIDTH];
                    coeff_reg[i] <= coeffs[((i+1)*COEFF_WIDTH)-1 -: COEFF_WIDTH];
                end
            end
            // The valid signal is registered to introduce a one-cycle latency.
            valid_out <= valid_in;
        end
    end

    // Combinational logic to perform the FIR convolution.
    // The coefficients are applied in reverse order relative to the input data.
    // Intermediate multiplication results are computed in NBW_MULT bits.
    // The summation is performed in an adder tree to accumulate the products.
    logic signed [NBW_MULT-1:0] product;
    logic signed [OUT_WIDTH-1:0] sum;
    always_comb begin
        sum = '0;
        for (int i = 0; i < NUM_TAPS; i++) begin
            // Multiply data_reg[i] with the corresponding reversed coefficient.
            product = data_reg[i] * coeff_reg[NUM_TAPS-1-i];
            sum = sum + product;
        end
    end

    // Register the computed sum to produce the final output.
    // This introduces a one-cycle latency, ensuring that data_out and valid_out are synchronized.
    always_ff @(posedge clk) begin
        if (reset)
            data_out <= '0;
        else
            data_out <= sum;
    end

endmodule
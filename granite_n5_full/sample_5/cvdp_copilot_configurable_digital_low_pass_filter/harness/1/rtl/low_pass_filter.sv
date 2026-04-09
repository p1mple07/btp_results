module low_pass_filter #(
    // parameters
)(
    // ports
);
    // register signals
    reg [DATA_WIDTH*NUM_TAPS-1:0] data_reg;
    reg [COEFF_WIDTH*NUM_TAPS-1:0] coeffs_reg;
    reg valid_reg;
    wire ready_wire;

    // convert inputs to 2D array
    wire [DATA_WIDTH-1:0] data_array[NUM_TAPS-1:0];
    wire [COEFF_WIDTH-1:0] coeffs_array[NUM_TAPS-1:0];
    
    // perform element-wise multiplication and summation
    assign ready_wire = valid_reg;
    generate
        genvar i;
        for (i=0; i<NUM_TAPS; ++i) begin
            assign data_array[i] = data_in[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i];
            assign coeffs_array[i] = coeffs[COEFF_WIDTH*(i+1)-1:COEFF_WIDTH*i];
        end
    endgenerate
    assign valid_out = valid_in & ready_wire;
    assign data_out = $signed(data_array) * $signed(coeffs_array) + data_array[0];
endmodule
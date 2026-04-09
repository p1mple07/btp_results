module poly_decimator #(
    parameter M            = 4,    // Decimation factor
    parameter TAPS         = 8,    // Taps per phase
    parameter COEFF_WIDTH  = 16,   // Coefficient bit width
    parameter DATA_WIDTH   = 16,   // Sample data bit width
    parameter ACC_WIDTH     = DATA_WIDTH + COEFF_WIDTH + $clog2(TAPS)
) (
    input                          clk,
    input                          arst_n,
    input                          sample_buffer [0:M-1],
    input                          valid_in,
    input                          phase,
    output                         filter_out,
    output                         valid
);

    // 1. Shift register to hold the last M samples
    shift_register #(.TAPS(TAPS), .DATA_WIDTH(DATA_WIDTH)) u_shift (
        .clk(clk),
        .arst_n(arst_n),
        .load(valid_in),
        .new_sample(sample_buffer),
        .data_out(shift_data),
        .data_out_val(data_out_val)
    );

    // 2. Phase register to select coefficients
    logic [DATA_WIDTH-1:0] phase_reg;
    always_ff @(posedge clk) phase_reg <= phase;

    // 3. Coefficient RAM (inside a generate block)
    logic [COEFF_WIDTH-1:0] coeff [0:TAPS-1];
    genvar j;
    generate
        for (j = 0; j < TAPS; j = j + 1) begin : coeff_ram_inst
            logic [$clog2(M*TAPS)-1:0] addr;
            assign addr = phase_reg * TAPS + j;
            coeff_ram #(.NUM_COEFFS(M*TAPS), .DATA_WIDTH(COEFF_WIDTH)) u_coeff_ram (
                .clk(clk),
                .addr(addr),
                .data_out(coeff[j])
            );
        end
    endgenerate

    // 4. Adder tree for the M branches
    logic [ACC_WIDTH-1:0] sum_acc;
    logic valid_adder;
    adder_tree #(.NUM_INPUTS(TAPS)) u_adder_tree (
        .clk(clk),
        .arst_n(arst_n),
        .valid_in(valid_stage1),
        .data_in(products),
        .sum_out(sum_acc),
        .valid_out(valid_adder)
    );

    // 5. Final output
    logic [DATA_WIDTH-1:0] sum_result;
    assign sum_result = sum_acc;

    // 6. Output generation
    always_comb begin
        valid = data_out_val;
        filter_out = sum_result;
    end

endmodule

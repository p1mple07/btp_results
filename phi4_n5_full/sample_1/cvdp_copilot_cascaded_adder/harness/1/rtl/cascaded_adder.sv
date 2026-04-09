module cascaded_adder #(
    parameter IN_DATA_WIDTH = 16,
    parameter IN_DATA_NS    = 4
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic         i_valid,
    input  logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] i_data,
    output logic         o_valid,
    output logic [ (IN_DATA_WIDTH + $clog2(IN_DATA_NS)) - 1:0] o_data
);

    // Calculate the output data width to accommodate the full sum without overflow.
    localparam integer O_DATA_WIDTH = IN_DATA_WIDTH + $clog2(IN_DATA_NS);

    // Internal registers for pipelining.
    // r_data: Latches the flattened input data when i_valid is high.
    // r_sum:  Holds the computed cumulative sum.
    // r_valid: Indicates that the output sum is valid.
    logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] r_data;
    logic [O_DATA_WIDTH-1:0]             r_sum;
    logic                                r_valid;

    // Combinational block to perform cascaded addition on the registered data.
    // The input vector is divided into IN_DATA_NS segments, each of width IN_DATA_WIDTH.
    // The sum is computed as: sum = a0 + a1 + ... + a(IN_DATA_NS-1)
    logic [O_DATA_WIDTH-1:0] sum;
    always_comb begin
        // Start with the first element.
        sum = r_data[IN_DATA_WIDTH-1:0];
        // Cascaded addition for remaining elements.
        for (int i = 1; i < IN_DATA_NS; i++) begin
            sum = sum + r_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH];
        end
    end

    // Sequential logic: Two-stage pipeline.
    // Stage 1: Latch input data when i_valid is asserted.
    // Stage 2: Compute and register the cumulative sum (introducing a one-cycle delay).
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_data  <= '0;
            r_sum   <= '0;
            r_valid <= 1'b0;
        end else begin
            // Latch the input data.
            if (i_valid) begin
                r_data <= i_data;
            end

            // Pipeline stage: register the computed sum.
            // When r_valid is high, the output remains valid.
            // When i_valid is high and r_valid is not set, compute and register the new sum.
            if (r_valid) begin
                // Hold the current output.
            end else if (i_valid) begin
                r_sum  <= sum;       // Register the computed sum.
                r_valid <= 1'b1;     // Indicate that the output sum is valid.
            end else begin
                r_valid <= 1'b0;     // Deassert valid when no new data is processed.
            end
        end
    end

    // Drive the output ports.
    assign o_valid = r_valid;
    assign o_data  = r_sum;

endmodule
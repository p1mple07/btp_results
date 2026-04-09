module generic_counter #(parameter N = 8) (
    input  logic         clk_in,          // Clock input
    input  logic         rst_in,          // Active HIGH Reset input (synchronous)
    input  logic [2:0]   mode_in,         // Mode input (3 bits)
    input  logic         enable_in,       // Enable input
    input  logic [N-1:0] ref_modulo,      // Reference modulo value for Modulo-N counter
    output logic [N-1:0] o_count          // Output count (N bits)
);

    logic [N-1:0] count_bin_up, count_bin_down, count_modulo, count_johnson, count_gray, count_ring;

    // Simplified counter logic
    always_ff @(posedge clk_in) begin
        if (rst_in)
            count_bin_up <= {N{1'b0}};
        else if (enable_in)
            count_bin_up <= count_bin_up + (mode_in == BINARY_UP ? 1 : -1);
        else
            count_bin_up <= count_bin_up;

        if (rst_in)
            count_bin_down <= {N{1'b0}};
        else if (enable_in)
            count_bin_down <= count_bin_down - (mode_in == BINARY_DOWN ? 1 : 0);
        else
            count_bin_down <= count_bin_down;

        if (rst_in)
            count_modulo <= {N{1'b0}};
        else if (enable_in) begin
            if (count_modulo == ref_modulo)
                count_modulo <= {N{1'b0}};
            else
                count_modulo <= count_modulo + 1;
        end else
            count_modulo <= count_modulo;

        count_johnson <= ~count_johnson[0] ^ count_johnson[N-1:1];
        count_gray <= count_gray + (mode_in == GRAY ? 1 : 0);
        count_ring <= {{(N-1){1'b0}}, 1'b1} when (count_ring == {N{1'b0}});
        else count_ring <= count_ring;

        count_mux = count_bin_up;
        if (mode_in != BINARY_UP && mode_in != BINARY_DOWN && mode_in != MODULO_N &&
            mode_in != JOHNSON && mode_in != GRAY && mode_in != RING)
            count_mux = {N{1'b0}};

        assign o_count = count_mux ^ (count_mux >> 1);
    end

endmodule

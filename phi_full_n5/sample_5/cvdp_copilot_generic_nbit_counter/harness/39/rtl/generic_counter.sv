module generic_counter #(parameter N = 8) (
    input  logic         clk_in,          // Clock input
    input  logic         rst_in,          // Active HIGH Reset input (synchronous)
    input  logic [2:0]   mode_in,         // Mode input (3 bits)
    input  logic         enable_in,       // Enable input
    input  logic [N-1:0] ref_modulo,      // Reference modulo value for Modulo-N counter
    output logic [N-1:0] o_count          // Output count (N bits)
);

    // Define mode-specific counts with combinational logic
    logic [N-1:0] count_bin_up, count_bin_down, count_modulo, count_johnson, count_gray, count_ring;

    // BINARY_UP count logic
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in)
            count_bin_up <= {N{1'b0}};
        else if (enable_in)
            count_bin_up <= count_bin_up + 1;
    end

    // BINARY_DOWN count logic
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in)
            count_bin_down <= {N{1'b0}};
        else if (enable_in)
            count_bin_down <= count_bin_down - 1;
    end

    // MODULO_N count logic
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in)
            count_modulo <= {N{1'b0}};
        else if (enable_in) begin
            if (count_modulo == ref_modulo)
                count_modulo <= {N{1'b0}};
            else
                count_modulo <= count_modulo + 1;
        end else
            count_modulo <= count_modulo;
    end

    // JOHNSON count logic
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in)
            count_johnson <= {N{1'b0}};
        else if (enable_in)
            count_johnson <= {~count_johnson[0], count_johnson[N-1:1]};
        else
            count_johnson <= count_johnson;
    end

    // GRAY count logic (internal count)
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in)
            count_gray <= {N{1'b0}};
        else if (enable_in)
            count_gray <= count_gray + 1;
        else
            count_gray <= count_gray;
    end

    // RING count logic
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in)
            count_ring <= {N{1'b0}};
        else if (enable_in) begin
            if (count_ring == {N{1'b0}})
                count_ring <= {{(N-1){1'b0}}, 1'b1};
            else
                count_ring <= {count_ring[N-2:0], count_ring[N-1]};
        end else
            count_ring <= count_ring;
    end

    // Multiplexer to select the count based on mode_in
    assign o_count = (mode_in == GRAY) ? (count_gray ^ (count_gray >> 1)) : count_gray;

endmodule

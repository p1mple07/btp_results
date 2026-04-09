module generic_counter #(parameter N = 8) (
    input  logic         clk_in,          // Clock input
    input  logic         rst_in,          // Active HIGH Reset input (synchronous)
    input  logic [2:0]   mode_in,         // Mode input (3 bits)
    input  logic         enable_in,       // Enable input
    input  logic [N-1:0] ref_modulo,      // Reference modulo value for Modulo-N counter
    output logic [N-1:0] o_count          // Output count (N bits)
);

    logic [N-1:0] count_mux;
    logic [N-1:0] count_bin_up;
    logic [N-1:0] count_bin_down;
    logic [N-1:0] count_modulo;
    logic [N-1:0] count_johnson;
    logic [N-1:0] count_gray;
    logic [N-1:0] count_ring;

    // Initialize count variables
    initial begin
        count_bin_up <= {N{1'b0}};
        count_bin_down <= {N{1'b0}};
        count_modulo <= {N{1'b0}};
        count_johnson <= {N{1'b0}};
        count_gray <= {N{1'b0}};
        count_ring <= {N{1'b0}};
    end

    // Combined sequential and combinational logic
    always_ff @(posedge clk_in) begin
        if (rst_in)
            count_bin_up <= {N{1'b0}};
        else if (enable_in) begin
            case (mode_in)
                BINARY_UP:   count_bin_up <= count_bin_up + 1;
                BINARY_DOWN: count_bin_down <= count_bin_down - 1;
                MODULO_N:    if (count_modulo == ref_modulo) count_modulo <= {N{1'b0}};
                              else count_modulo <= count_modulo + 1;
                JOHNSON:     count_johnson <= {~count_johnson[0], count_johnson[N-1:1]};
                GRAY:        count_gray <= count_gray + 1;
                RING:        if (count_ring == {N{1'b0}}) count_ring <= {{(N-1){1'b0}}, 1'b1};
                default:      count_bin_up <= {N{1'b0}};
            endcase
        end
    end

    // Combinational logic for output selection
    always_comb begin
        count_mux = mode_in == GRAY ? (count_gray ^ (count_gray >> 1)) : (mode_in == MODULO_N ? count_modulo :
                                   mode_in == JOHNSON ? count_johnson :
                                   mode_in == BINARY_DOWN ? count_bin_down :
                                   mode_in == BINARY_UP ? count_bin_up :
                                   {N{1'b0}});
    end

    assign o_count = count_mux;

endmodule

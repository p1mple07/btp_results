module generic_counter #(parameter N = 8) (
    input  logic         clk_in,          // Clock input
    input  logic         rst_in,          // Active HIGH Reset input (synchronous)
    input  logic [2:0]   mode_in,         // Mode input (3 bits)
    input  logic         enable_in,       // Enable input
    input  logic [N-1:0] ref_modulo,      // Reference modulo value for Modulo-N counter
    output logic [N-1:0] o_count          // Output count (N bits)
);

    parameter BINARY_UP   = 3'b000;
    parameter BINARY_DOWN = 3'b001;
    parameter MODULO_N    = 3'b010;
    parameter JOHNSON     = 3'b011;
    parameter GRAY        = 3'b100;
    parameter RING        = 3'b101;

    logic [N-1:0] count_mux;
    logic [N-1:0] count_bin_up;
    logic [N-1:0] count_bin_down;
    logic [N-1:0] count_modulo;
    logic [N-1:0] count_johnson;
    logic [N-1:0] count_gray;
    logic [N-1:0] count_ring;

    always_ff @(posedge clk_in) begin
        if (rst_in)
            count_bin_up <= {N{1'b0}};
        else if (enable_in)
            count_bin_up <= count_bin_up + 1;
        else
            count_bin_up <= count_bin_up;
    end

    always_ff @(posedge clk_in) begin
        if (rst_in)
            count_bin_down <= {N{1'b0}};
        else if (enable_in)
            count_bin_down <= count_bin_down - 1;
        else
            count_bin_down <= count_bin_down;
    end

    always_ff @(posedge clk_in) begin
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

    always_ff @(posedge clk_in) begin
        if (rst_in)
            count_johnson <= {N{1'b0}};
        else if (enable_in)
            count_johnson <= {~count_johnson[0], count_johnson[N-1:1]};
        else
            count_johnson <= count_johnson;
    end

    always_ff @(posedge clk_in) begin
        if (rst_in)
            count_gray <= {N{1'b0}};
        else if (enable_in)
            count_gray <= count_gray + 1;
        else
            count_gray <= count_gray;
    end

    always_ff @(posedge clk_in) begin
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

    always_comb begin
        case (mode_in)
            BINARY_UP:   count_mux = count_bin_up;
            BINARY_DOWN: count_mux = count_bin_down;
            MODULO_N:    count_mux = count_modulo;
            JOHNSON:     count_mux = count_johnson;
            GRAY:        count_mux = count_gray;
            RING:        count_mux = count_ring;
            default:     count_mux = {N{1'b0}};
        endcase
    end

    assign o_count = (mode_in == GRAY) ? (count_mux ^ (count_mux >> 1)) : count_mux;

endmodule

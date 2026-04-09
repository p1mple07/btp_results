module generic_counter #(parameter N = 8) (
    input  logic         clk_in,
    input  logic         rst_in,
    input  logic [2:0]   mode_in,
    input  logic         enable_in,
    input  logic [N-1:0] ref_modulo,
    output logic [N-1:0] o_count
);

    // Mode parameters
    parameter BINARY_UP   = 3'b000;
    parameter BINARY_DOWN = 3'b001;
    parameter MODULO_N    = 3'b010;
    parameter JOHNSON     = 3'b011;
    parameter GRAY        = 3'b100;
    parameter RING        = 3'b101;

    // Counters for each mode
    logic [N-1:0] count_bin_up;
    logic [N-1:0] count_bin_down;
    logic [N-1:0] count_modulo;
    logic [N-1:0] count_johnson;
    logic [N-1:0] count_gray;
    logic [N-1:0] count_ring;

    // Single sequential block to update all counters and compute the output.
    // Merging the multiple always_ff blocks and the always_comb block reduces both cell and wire count.
    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            count_bin_up   <= {N{1'b0}};
            count_bin_down <= {N{1'b0}};
            count_modulo   <= {N{1'b0}};
            count_johnson  <= {N{1'b0}};
            count_gray     <= {N{1'b0}};
            count_ring     <= {N{1'b0}};
            o_count        <= {N{1'b0}};
        end
        else begin
            // Update counters only when enable_in is asserted.
            if (enable_in) begin
                count_bin_up   <= count_bin_up + 1;
                count_bin_down <= count_bin_down - 1;
                if (count_modulo == ref_modulo)
                    count_modulo <= {N{1'b0}};
                else
                    count_modulo <= count_modulo + 1;
                count_johnson  <= {~count_johnson[0], count_johnson[N-1:1]};
                count_gray     <= count_gray + 1;
                if (count_ring == {N{1'b0}})
                    count_ring <= {{(N-1){1'b0}}, 1'b1};
                else
                    count_ring <= {count_ring[N-2:0], count_ring[N-1]};
            end

            // Compute the selected counter value in a temporary variable.
            logic [N-1:0] mux_out;
            case (mode_in)
                BINARY_UP:   mux_out = count_bin_up;
                BINARY_DOWN: mux_out = count_bin_down;
                MODULO_N:    mux_out = count_modulo;
                JOHNSON:     mux_out = count_johnson;
                GRAY:        mux_out = count_gray;
                RING:        mux_out = count_ring;
                default:     mux_out = {N{1'b0}};
            endcase

            // Apply Gray code conversion only when mode_in is GRAY.
            o_count <= (mode_in == GRAY) ? (mux_out ^ (mux_out >> 1)) : mux_out;
        end
    end

endmodule
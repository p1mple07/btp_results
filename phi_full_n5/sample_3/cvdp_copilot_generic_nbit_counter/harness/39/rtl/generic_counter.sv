module generic_counter #(parameter N = 8) (
    input  logic         clk_in,          // Clock input
    input  logic         rst_in,          // Active HIGH Reset input (synchronous)
    input  logic [2:0]   mode_in,         // Mode input (3 bits)
    input  logic         enable_in,       // Enable input
    input  logic [N-1:0] ref_modulo,      // Reference modulo value for Modulo-N counter
    output logic [N-1:0] o_count          // Output count (N bits)
);

    // Counting modes
    localparam BINARY_UP   = 3'b000;
    localparam BINARY_DOWN = 3'b001;
    localparam MODULO_N    = 3'b010;
    localparam JOHNSON     = 3'b011;
    localparam GRAY        = 3'b100;
    localparam RING        = 3'b101;

    // Single always block for sequential logic
    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            count_bin_up <= {N{1'b0}};
            count_bin_down <= {N{1'b0}};
            count_modulo <= {N{1'b0}};
            count_johnson <= {N{1'b0}};
            count_gray <= {N{1'b0}};
            count_ring <= {N{1'b0}};
        end else if (enable_in) begin
            case (mode_in)
                BINARY_UP:
                    count_bin_up <= count_bin_up + 1;
                BINARY_DOWN:
                    count_bin_down <= count_bin_down - 1;
                MODULO_N:
                    if (count_modulo == ref_modulo)
                        count_modulo <= {N{1'b0}};
                    else
                        count_modulo <= count_modulo + 1;
                JOHNSON:
                    count_johnson <= {~count_johnson[0], count_johnson[N-1:1]};
                GRAY:
                    count_gray <= count_gray + 1;
                RING:
                    if (count_ring == {N{1'b0}})
                        count_ring <= {{(N-1){1'b0}}, 1'b1};
                    else
                        count_ring <= count_ring + 1;
                default:
                    // No-operation for default mode
            endcase
        end
    end

    // Combinational logic to select the output
    assign o_count = (mode_in == GRAY) ? (count_gray ^ (count_gray >> 1)) : count_mux;

endmodule

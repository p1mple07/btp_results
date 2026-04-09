module generic_counter #(parameter N = 8) (
    input  logic         clk_in,          // Clock input
    input  logic         rst_in,          // Active HIGH Reset input (synchronous)
    input  logic [2:0]   mode_in,         // Mode input (3 bits)
    input  logic         enable_in,       // Enable input
    input  logic [N-1:0] ref_modulo,      // Reference modulo value for Modulo-N counter
    output logic [N-1:0] o_count          // Output count (N bits)
);

    // Mode parameters
    parameter BINARY_UP   = 3'b000;
    parameter BINARY_DOWN = 3'b001;
    parameter MODULO_N    = 3'b010;
    parameter JOHNSON     = 3'b011;
    parameter GRAY        = 3'b100;
    parameter RING        = 3'b101;

    // Single register for all counter modes
    logic [N-1:0] count;

    // Single always_ff block to update the counter based on mode
    always_ff @(posedge clk_in) begin
        if (rst_in)
            count <= '0;
        else if (enable_in)
            case (mode_in)
                BINARY_UP:   count <= count + 1;
                BINARY_DOWN: count <= count - 1;
                MODULO_N:    count <= (count == ref_modulo) ? '0 : count + 1;
                JOHNSON:     count <= {~count[0], count[N-1:1]};
                RING:        count <= (count == '0) ? { {(N-1){1'b0}}, 1'b1 } : {count[N-2:0], count[N-1]};
                default:     count <= count;
            endcase
    end

    // Single always_comb block to compute the output.
    // For GRAY mode, perform Gray code conversion; otherwise, pass the count directly.
    always_comb begin
        if (mode_in == GRAY)
            o_count = (count ^ (count >> 1));
        else
            o_count = count;
    end

endmodule
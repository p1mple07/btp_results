module generic_counter #(parameter N = 8) (
    input  logic         clk_in,          // Clock input
    input  logic         rst_in,          // Active HIGH Reset input (synchronous)
    input  logic [2:0]   mode_in,         // Mode input (3 bits)
    input  logic         enable_in,       // Enable input
    input  logic [N-1:0] ref_modulo,      // Reference modulo value for Modulo-N counter
    output logic [N-1:0] o_count          // Output count (N bits)
);

    parameter JOHNSON = 3'b011;
    parameter GRAY    = 3'b100;
    parameter RING     = 3'b101;

    logic [N-1:0] count_mux;
    logic [N-1:0] count;
    logic [N-1:0] shift_count;

    // Counter logic
    always_ff @(posedge clk_in) begin
        if (rst_in)
            count <= {N{1'b0}};
    end else if (enable_in) begin
        case (mode_in)
            BINARY_UP:   count = count + 1;
            BINARY_DOWN: count = count - 1;
            MODULO_N:    count = ref_modulo;
            JOHNSON:     count = ~count[0], count[N-1:1];
            GRAY:        count = count ^ (count >> 1);
            RING:        if (count == {N{1'b0}}) count = {(N-1){1'b0}, 1'b1};
        endcase
    end else
        count <= count;
    end

    // Output logic
    always_comb begin
        case (mode_in)
            GRAY:    o_count = count ^ (count >> 1);
            default: o_count = count;
        endcase
    end

    assign shift_count = count >> 1;
    assign o_count = (mode_in == GRAY) ? (count ^ shift_count) : count;
endmodule
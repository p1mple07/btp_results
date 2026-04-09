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

    logic [N-1:0] count;
    logic direction;

    // Mode to direction mapping
    logic [2:0] to_dir = case (mode_in)
        BINARY_UP: 1'b1; // UP
        BINARY_DOWN: 1'b0; // DOWN
        MODULO_N: 1'b1; // UP
        JOHNSON: 1'b1; // UP
        GRAY: 1'b1; // UP
        RING: 1'b1; // UP
        default: 1'b1; // Default
    endcase

    // Counter logic
    always_ff @(posedge clk_in) begin
        if (rst_in)
            count <= {N{1'b0}};
        else if (enable_in)
            count <= count + direction;
        else
            count <= count;
    end

    // Output logic
    always_comb begin
        case (mode_in)
            BINARY_UP: o_count = count;
            BINARY_DOWN: o_count = rotate_right(count, 1);
            MODULO_N: o_count = count == ref_modulo ? {N{1'b0}} : count;
            JOHNSON: o_count = count;
            GRAY: o_count = count ^ (count >> 1);
            RING: o_count = count;
            default: o_count = {N{1'b0}};
        endcase
    end

    assign direction = to_dir;

endmodule
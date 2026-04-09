module generic_counter #(parameter N = 8) (
    input  logic         clk_in,          // Clock input
    input  logic         rst_in,          // Active HIGH Reset input (synchronous)
    input  logic [2:0]   mode_in,         // Mode input (3 bits)
    input  logic         enable_in,       // Enable input
    input  logic [N-1:0] ref_modulo,      // Reference modulo value for Modulo-N counter
    output logic [N-1:0] o_count          // Output count (N bits)
);

    // Define counting modes
    parameter BINARY_UP   = 3'b000;
    parameter BINARY_DOWN = 3'b001;
    parameter MODULO_N    = 3'b010;
    parameter JOHNSON     = 3'b011;
    parameter GRAY        = 3'b100;
    parameter RING        = 3'b101;

    // Shared counter logic
    reg [N-1:0] count_shared;

    // Combinational logic to select and update the counter
    always_comb begin
        case (mode_in)
            BINARY_UP:   count_shared = count_shared + 1;
            BINARY_DOWN: count_shared = count_shared - 1;
            MODULO_N:    count_shared = (count_shared == ref_modulo) ? {N{1'b0}} : count_shared + 1;
            JOHNSON:     count_shared = {~count_shared[0], count_shared[N-1:1]};
            GRAY:        count_shared = count_shared ^ (count_shared >> 1);
            RING:        count_shared = count_shared << 1 | count_shared[N-1];
            default:     count_shared = {N{1'b0}};
        endcase
    end

    // Select output based on mode_in
    assign o_count = count_shared;

endmodule

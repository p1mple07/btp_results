module generic_counter #(parameter N = 8) (
    input  logic         clk_in,
    input  logic         rst_in,
    input  logic [2:0]   mode_in,
    input  logic         enable_in,
    input  logic [N-1:0] ref_modulo,
    output logic [N-1:0] o_count
);

    // Define mode parameters
    localparam BINARY_UP   = 3'b000;
    localparam BINARY_DOWN = 3'b001;
    localparam MODULO_N    = 3'b010;
    localparam JOHNSON     = 3'b011;
    localparam GRAY        = 3'b100;
    localparam RING        = 3'b101;

    // Single counter register for all modes
    logic [N-1:0] count;

    // Combined sequential block: update count based on mode_in.
    // This replaces multiple always_ff blocks, reducing both cell and wire count.
    always_ff @(posedge clk_in) begin
        if (rst_in)
            count <= '0;
        else if (enable_in)
            case (mode_in)
                BINARY_UP:   count <= count + 1;
                BINARY_DOWN: count <= count - 1;
                MODULO_N:    count <= (count == ref_modulo) ? '0 : count + 1;
                JOHNSON:     count <= {~count[0], count[N-1:1]};
                RING:        count <= (count == '0) ? {{(N-1){1'b0}}, 1'b1} : {count[N-2:0], count[N-1]};
                GRAY:        count <= count + 1;
                default:     count <= count; // Do not update on invalid mode
            endcase
    end

    // Combinational output logic:
    // For valid modes, output count directly (or Gray conversion for GRAY mode).
    // For any undefined mode, force output to zero.
    assign o_count = (((mode_in == BINARY_UP) || (mode_in == BINARY_DOWN) ||
                       (mode_in == MODULO_N) || (mode_in == JOHNSON) ||
                       (mode_in == RING) || (mode_in == GRAY))) ?
                      ((mode_in == GRAY) ? (count ^ (count >> 1)) : count) : '0;

endmodule
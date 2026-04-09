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
    logic [N-1:0] up_count;
    logic [N-1:0] down_count;
    logic [N-1:0] mod_count;
    logic [N-1:0] johnson_count;
    logic [N-1:0] gray_count;
    logic [N-1:0] ring_count;

    // Counter with direction control
    always_ff @(posedge clk_in) begin
        if (rst_in)
            count <= {N{1'b0}};
        else if (enable_in) begin
            if (mode_in == BINARY_UP)
                count <= count + 1;
            else if (mode_in == BINARY_DOWN)
                count <= count - 1;
            else
                count <= count;
        end else
            count <= count;
    end

    // Modulo-N counting
    always_ff @(posedge clk_in) begin
        if (rst_in)
            mod_count <= {N{1'b0}};
        else if (enable_in) begin
            mod_count <= (mod_count + 1) % ref_modulo;
        end else
            mod_count <= mod_count;
    end

    // Johnson counter
    always_ff @(posedge clk_in) begin
        if (rst_in)
            johnson_count <= {N{1'b0}};
        else if (enable_in) begin
            johnson_count <= (johnson_count ^ {1'b0, N-1{1'b0}});
        end else
            johnson_count <= johnson_count;
    end

    // Gray code counter
    always_comb begin
        gray_count = count ^ (count >> 1);
    end

    // Ring counter
    always_ff @(posedge clk_in) begin
        if (rst_in)
            ring_count <= {N{1'b0}};
        else if (enable_in) begin
            ring_count <= (ring_count + 1) << (N-1) | (ring_count >> (N-1));
        end else
            ring_count <= ring_count;
    end

    // Select count based on mode
    always_comb begin
        case (mode_in)
            BINARY_UP:   o_count = up_count;
            BINARY_DOWN: o_count = down_count;
            MODULO_N:    o_count = mod_count;
            JOHNSON:     o_count = johnson_count;
            GRAY:        o_count = gray_count;
            RING:        o_count = ring_count;
            default:     o_count = count;
        endcase
    end

    assign up_count = count;
    assign down_count = count;
    assign mod_count = count;
    assign johnson_count = count;
    assign gray_count = count;
    assign ring_count = count;
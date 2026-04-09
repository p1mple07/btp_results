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
    logic [N-1:0] mode Control;

    // Mode Control
    always_ff @(posedge clk_in) begin
        if (rst_in)
            count <= {N{1'b0}};
            mode <= BINARY_UP;
        else if (enable_in)
            mode <= mode_in;
        else
            mode <= BINARY_UP;
    end

    // Counter
    always_ff @(posedge clk_in) begin
        if (mode == BINARY_UP)
            count <= count + 1;
        else if (mode == BINARY_DOWN)
            count <= count - 1;
        else if (mode == MODULO_N)
            count <= (count + 1) % ref_modulo;
        else if (mode == JOHNSON)
            count <= {count[1:N-1], count[0]};
        else if (mode == GRAY)
            count <= count ^ (count >> 1);
        else if (mode == RING)
            count <= (count + 1) & ~(count == {N{1'b0}});
        else
            count <= count;
    end

    assign o_count = count;

endmodule
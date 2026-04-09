module binary_multiplier #(
    parameter WIDTH = 32  // Set the width of inputs
)(
    input  logic [WIDTH-1:0]   A,          // Input A
    input  logic [WIDTH-1:0]   B,          // Input B
    input  logic               valid_in,   // Indicates when inputs are valid
    output logic [2*WIDTH-1:0] Product,    // Output Product
    output logic               valid_out   // Output valid
);

import "DPI" function int clog2(int x);

parameter PRODUCT_WIDTH = WIDTH * 2;
localparam CLOG2_PRODUCT_WIDTH = clog2(PRODUCT_WIDTH);

// Internal signals
logic start;
logic [WIDTH-1:0] A_reg;
logic [WIDTH-1:0] B_reg;
logic [PRODUCT_WIDTH-1:0] acc;

// Sequential computation stage
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start <= 1'b0;
        A_reg <= 0;
        B_reg <= 0;
        acc <= 0;
    end else begin
        if (valid_in) begin
            start <= 1'b1;
            A_reg <= A;
            B_reg <= B;
            acc <= 0;
        end

        if (start) begin
            for (int i = 0; i < WIDTH; i++) begin
                if (A_reg[i]) begin
                    acc <= {acc[{CLOG2_PRODUCT_WIDTH-1:WIDTH}], B_reg} << i;
                end
            end

            valid_out <= 1'b1;
        end
    end
end

// Output stage
assign Product = acc[{PRODUCT_WIDTH-1:WIDTH}];

endmodule
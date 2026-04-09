module binary_multiplier #(
    parameter WIDTH = 32  // bit width of A and B
)(
    input  logic clk,       // clock
    input  logic rst_n,     // active-low reset
    input  logic valid_in,  // active high valid input
    input  logic [WIDTH-1:0] A,   // operand A
    input  logic [WIDTH-1:0] B,   // operand B
    output logic [2*WIDTH-1:0] Product, // output product
    output logic valid_out   // output valid
);

    // Internal signal to track start of operation
    logic start;
    logic [WIDTH-1:0] sum;
    integer i;

    // On positive clock edge, if reset is not active, and valid_in is asserted, set start and shift
    initial begin
        start = 0;
    end

    sensitive always @(posedge clk or posedge rst_n) begin
        if (!rst_n) begin
            start <= 0;
            Product <= 0;
            valid_out <= 1'b0;
        end else begin
            if (valid_in) begin
                start <= 1;
                sum = 0;
                Product = 0;
                valid_out = 1'b0;
            end
        end
    end

    // Shift and accumulate in a loop for WIDTH iterations
    always @(posedge clk) begin
        if (~start) begin
            sum = 0;
            Product = 0;
            valid_out = 1'b0;
        end else begin
            for (i = 0; i < WIDTH; i = i + 1) begin
                if (A[i]) begin
                    sum = sum + (B << i);
                end
            end
            Product = sum;
            valid_out = 1'b1;
        end
    end

endmodule

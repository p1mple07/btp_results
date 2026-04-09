Module declaration
module scrambler_descrambler (
    parameter POLY_LENGTH = 31,
    parameter POLY_TAP = 3,
    parameter WIDTH = 16,
    parameter CHECK_MODE = 0
)

// Port declarations
input logic clk;
input logic rst;
input logic bypass_scrambling;
input [WIDTH-1:0] data_in;
input logic valid_in;
output logic [WIDTH-1:0] data_out;
output logic valid_out;
output [32-1:0] bit_count;

// Logic variables
reg logic [WIDTH-1:0] xor_result;
reg logic [WIDTH-1:0] prbs;
reg logic [WIDTH-1:0] shifted_prbs;
reg logic [WIDTH-1:0] prbs_data;
reg logic [WIDTH-1:0] prbs_reg;

// Conditional assignment for data_in based on CHECK_MODE
if (CHECK_MODE == 0)
    data_in <= 0;
else 
    data_in <= data_in;
endif

// Instantiate the PRBS generator/checker
prbs_gen_check #(
    parameter CHECK_MODE  = CHECK_MODE,
    parameter POLY_LENGTH = POLY_LENGTH,
    parameter POLY_TAP    = POLY_TAP,
    parameter WIDTH       = WIDTH
) ( 
    .clk(clk),
    .rst(rst),
    .data_in(prbs_data),
    .data_out(data_out)
);

// XOR logic for scrambling
always_ff @ (posedge clk) begin
    if (rst) begin
        // Initialization
        prbs_reg <= {(POLY_LENGTH){1'b1}};
        prbs <= {(WIDTH){1'b1}};
        data_out <= {(WIDTH){1'b1}};
        bit_count <= 0;
        valid_out <= 0;
    else begin
        // Shift register update
        prbs_reg <= prbs[WIDTH];
        // Generate the new PRBS bit
        xor_result <= data_in ^ prbs[0];
        prbs <= {
            (xor_result >> 1) + ((xor_result & (1 << (WIDTH-1))) ? (1 << (WIDTH-1)) : 0)
        };
        // Update data_out
        data_out <= prbs;
    end
end

// Always block for valid_out and bit_count
always @* begin
    if (valid_in) begin
        // Increment bit_count after valid data has been processed
        bit_count +='WIDTH';
        valid_out <= 1;
    end
end

endmodule
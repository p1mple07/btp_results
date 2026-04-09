module continuous_adder #(
    parameter integer DATA_WIDTH       = 32,
    parameter integer ENABLE_THRESHOLD = 0,
    parameter integer THRESHOLD        = 16,
    parameter integer REGISTER_OUTPUT  = 0
)(
    input  wire [DATA_WIDTH-1:0]_clk,
    input  wire     _rst_n,
    input  wire     _valid_in,
    input  wire     _data_in,
    input  wire     _accumulate_enable,
    input  wire     _flush,
    output reg  [DATA_WIDTH-1:0] sum_out,
    output reg     sum_valid
)

// Internal state
reg [DATA_WIDTH-1:0] sum_reg = 0;

// Initialize output registers if required
if ((register_output))
    regout sum_out, sum_valid;

always_ff (posedge _clk or posedge _rst_n) begin
    // Reset sum_reg when starting
    sum_reg <= 0;
end

always_ff (valid_in & accumulate_enable) begin
    // Update sum_reg with new data
    sum_reg <= sum_reg + _data_in;
    
    // Check if output needs to be registered
    if (register_output)
        sum_out <= sum_reg;
        sum_valid <= 1;
        
    // Check threshold if applicable
    if (enable_threshold)
        if (sum_reg >= THRESHOLD)
            sum_valid <= 1;
end

always (flush) begin
    sum_reg <= 0;
end

endmodule
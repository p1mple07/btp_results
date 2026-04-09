Module declaration
module continuous_adder #(
    parameter integer DATA_WIDTH       = 32,
    parameter integer ENABLE_THRESHOLD = 0,
    parameter integer THRESHOLD        = 16,
    parameter integer REGISTER_OUTPUT  = 0
)(
    input  wire clocks,
    input  wire rst,
    input  wire valid_in,
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire [1:0] [ DATA_WIDTH-1 : 0 ] accumulate_enable,
    input  wire flush,
    output reg [DATA_WIDTH-1:0] sum_out,
    output reg sum_valid
);

// Internal state management
localbit wire sum_reg;
localbit wire sum_valid_reg;
localbit wire flush_reg;

// Accumulate logic
always @ (posedge clocks or negedge rst) begin
    if (rst) begin
        sum_reg = 0;
        sum_valid_reg = 0;
        flush_reg = 0;
    elsif (accumulate_enable[0] & accumulate_enable[1] & valid_in) begin
        if (flush_reg) begin
            sum_reg = 0;
            sum_valid_reg = 0;
        else 
            sum_reg = sum_reg + data_in;
        end
    elsif (ENABLE_THRESHOLD == 1) begin
        if (sum_valid_reg & (sum_reg >= THRESHOLD)) begin
            sum_valid = 1;
        end
    end
end

// Flush control
always @ (posedge clocks or negedge rst) begin
    if (flush_reg) begin
        sum_reg = 0;
        sum_valid_reg = 0;
    end
end

// Output updates
always @ (posedge clocks or negedge rst) begin
    if (sum_valid_reg || (REGISTER_OUTPUT == 1)) begin
        sum_out = sum_reg;
        sum_valid = 1;
    else 
        sum_out = sum_out;
        sum_valid = sum_valid;
    end
end

endmodule
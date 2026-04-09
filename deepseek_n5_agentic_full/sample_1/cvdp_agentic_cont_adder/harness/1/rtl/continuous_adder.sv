module continuous_adder(
    parameter integer DATA_WIDTH       = 32,
    parameter integer ENABLE_THRESHOLD = 0,
    parameter integer THRESHOLD        = 16,
    parameter integer REGISTER_OUTPUT  = 0
)
    (input  wire clk,
     input  wire rst_n,
     input  wire valid_in,
     input  wire [DATA_WIDTH-1:0] data_in,
     input  wire [DATA_WIDTH-1:0] accumulate_enable,
     input  wire flush,
     output reg [DATA_WIDTH-1:0] sum_out,
     output reg sum_valid
    );

    // Initialize sum register to 0 on first valid accumulate_enable assertion
    integer sum_reg = 0;

    always @posedge rst_n or posedge clk begin
        if (rst_n) begin
            sum_reg = 0;
        end else if (flush) begin
            sum_reg = 0;
        end else if (valid_in && accumulate_enable) begin
            sum_reg += data_in;
            
            // Check threshold condition
            if (ENABLE_THRESHOLD == 1 && sum_reg >= THRESHOLD) begin
                sum_valid = 1;
                sum_out = sum_reg;
            end
        end
    end
endmodule
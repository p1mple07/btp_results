module continuous_adder #(
    parameter DATA_WIDTH = 32,                  // Parameter for data width, default is 32 bits
    parameter THRESHOLD_VALUE = 100,            // Parameter for threshold value, default is 100
    parameter SIGNED_INPUTS = 1                 // Parameter to enable signed inputs (1 = signed, 0 = unsigned)
) (
    input logic                          clk,        // Clock signal
    input logic                          reset,      // Reset signal, Active high and Synchronous
    input logic signed [DATA_WIDTH-1:0]  data_in,    // Signed or unsigned input data stream, parameterized width
    input logic                          data_valid, // Input data valid signal
    output logic signed [DATA_WIDTH-1:0] sum_out,    // Signed or unsigned output, parameterized width
    output logic                         sum_ready   // Signal to indicate sum is output and accumulator is reset
);

    logic signed [DATA_WIDTH-1:0] sum_accum;    // Internal accumulator to store the running sum

    always_ff @(posedge clk) begin
        if (reset) begin
            sum_accum         <= {DATA_WIDTH{1'b0}};
            sum_ready         <= 1'b0;
            sum_out           <= {DATA_WIDTH{1'b0}};
        end
        else begin
            if (data_valid) begin
                sum_accum     <= sum_accum + data_in;
                if (sum_accum + data_in >= THRESHOLD_VALUE || sum_accum + data_in <= -1*THRESHOLD_VALUE) begin
                    sum_out   <= sum_accum + data_in; 
                    sum_ready <= 1'b1;                
                    sum_accum <= {DATA_WIDTH{1'b0}};  
                end
                else begin
                     sum_ready <= 1'b0;                
                end
            end
        end
    end
endmodule
module nbit_swizzling #(parameter DATA_WIDTH = 16)(
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    // 2-bit selection signal 
    output reg [DATA_WIDTH+1:0] data_out                                    // Output data of size DATA_WIDTH 
);

integer i;
reg [DATA_WIDTH-1:0] parity_bit;

// Calculate the parity bit
generate
    if(DATA_WIDTH > 1) begin : generate_parity_bit
        always @(*) begin
            parity_bit = 0;
            
            for(int i = 0; i < DATA_WIDTH-1; i++) begin
                parity_bit ^= data_in[i];
            end
        end
    end
endgenerate

// Append the parity bit to the output data
assign data_out = {parity_bit, data_in};

endmodule
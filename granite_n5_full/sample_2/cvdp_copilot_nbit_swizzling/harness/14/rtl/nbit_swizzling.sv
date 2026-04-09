module nbit_swizzling #(parameter DATA_WIDTH = 16)(
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    // 2-bit selection signal 
    output reg [DATA_WIDTH+1:0] data_out                                    // Output data of size DATA_WIDTH with parity bit
);

integer i; 

always @(*) begin
    case(sel)
        default: begin
            data_out = data_in;												    		        
            data_out[DATA_WIDTH] = ^data_out[0:(DATA_WIDTH-1)];			            
        end
    endcase
end

endmodule
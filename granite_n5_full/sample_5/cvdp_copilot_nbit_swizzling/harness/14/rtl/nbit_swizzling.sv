module nbit_swizzling #(parameter DATA_WIDTH = 16)(
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    // 2-bit selection signal 
    output reg [DATA_WIDTH+1:0] data_out                                    // Output data of size DATA_WIDTH 
);

integer i; 

always @(*) begin
    case(sel)
        `NBIT_SWIZZLING_SELECTOR_BITS: begin
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                data_out[i] = data_in[DATA_WIDTH-1-i];                      
            end
            
            data_out[DATA_WIDTH] = ^data_in & 1'b1;                           
        end
        
        default: begin
            data_out = data_in; 	                                            
        end
    endcase
end

endmodule
module nbit_swizzling #(parameter DATA_WIDTH = 64)(
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    //  2-bit selection signal 
    output reg [DATA_WIDTH-1:0] data_out                                    // Output data of size DATA_WIDTH 
);

always @(*) begin
    case(sel)
        2'b00: begin
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                data_out[i] = data_in[DATA_WIDTH-1-i];                      
            end
        end
        
        2'b01: begin
            for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
                data_out[i]                = data_in[DATA_WIDTH/2-1-i];     
                data_out[DATA_WIDTH/2 + i] = data_in[DATA_WIDTH/2+i];       
            end
        end
        
        2'b10: begin
            for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
                data_out[i] = data_in[DATA_WIDTH/4-1-i]; 		            
                data_out[DATA_WIDTH/4 + i]   = data_in[DATA_WIDTH/2-1-i];   
                data_out[DATA_WIDTH/2 + i]   = data_in[3*DATA_WIDTH/4-1-i]; 
                data_out[3*DATA_WIDTH/4 + i] = data_in[DATA_WIDTH-1-i];     
            end
        end
        
        2'b11: begin
            // Compute parity of all input bits
            localvar logic [DATA_WIDTH-1:0] parity;
            parity = 0;
            for (int i = 0; i < DATA_WIDTH; i++) begin
                parity ^= data_in[i];
            end
            data_out[DATA_WIDTH-1] = parity;
        endcase
    endcase
end

endmodule

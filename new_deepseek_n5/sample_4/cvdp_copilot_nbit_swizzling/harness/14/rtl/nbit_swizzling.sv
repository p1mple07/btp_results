module nbit_swizzling #(parameter DATA_WIDTH = 64)(
    input [DATA_WIDTH-1:0] data_in, 
    input [1:0] sel, 
    output reg [DATA_WIDTH:0] data_out); 

integer i;

wire parity_bit = data_in.reduce(^);

always @(*) begin
    case(sel)
        2'b00: begin
            data_out[0] = parity_bit;
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                data_out[1 + i] = data_in[DATA_WIDTH-1 - i];
            end
        end
        
        2'b01: begin
            data_out[0] = parity_bit;
            for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
                data_out[1 + i]                = data_in[DATA_WIDTH/2-1 -i];     
                data_out[DATA_WIDTH/2 + 1 + i] = data_in[DATA_WIDTH-1 -i];       
            end
        end
        
        2'b10: begin
            data_out[0] = parity_bit;
            for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
                data_out[1 + i] = data_in[DATA_WIDTH/4-1 -i];            
                data_out[DATA_WIDTH/4 + 1 + i]   = data_in[DATA_WIDTH/2-1 -i];   
                data_out[DATA_WIDTH/2 + 1 + i]   = data_in[3*DATA_WIDTH/4-1 -i]; 
                data_out[3*DATA_WIDTH/4 + 1 + i] = data_in[DATA_WIDTH-1 -i];     
            end
        end
        
        2'b11: begin
            data_out[0] = parity_bit;
            for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                data_out[1 + i]                  = data_in[DATA_WIDTH/8-1 -i];   
                data_out[DATA_WIDTH/8 + 1 + i]   = data_in[DATA_WIDTH/4-1 -i];   
                data_out[DATA_WIDTH/4 + 1 + i]   = data_in[3*DATA_WIDTH/8-1 -i]; 
                data_out[3*DATA_WIDTH/8 + 1 + i] = data_in[DATA_WIDTH/2-1 -i];   
                data_out[DATA_WIDTH/2 + 1 + i]   = data_in[5*DATA_WIDTH/8-1 -i]; 
                data_out[5*DATA_WIDTH/8 + 1 + i] = data_in[3*DATA_WIDTH/4-1 -i]; 
                data_out[3*DATA_WIDTH/4 + 1 + i] = data_in[7*DATA_WIDTH/8-1 -i]; 
                data_out[7*DATA_WIDTH/8 + 1 + i] = data_in[DATA_WIDTH-1 -i];     
            end
        end
        default: begin
            data_out[0] = parity_bit;
            data_out[1:DATA_WIDTH] = data_in;						                        
        end
    endcase
end
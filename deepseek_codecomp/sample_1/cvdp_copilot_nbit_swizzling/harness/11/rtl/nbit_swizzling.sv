module nbit_swizzling #(parameter DATA_WIDTH = 64)(
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    //  2-bit selection signal 
    output reg [DATA_WIDTH-1:0] data_out                                    // Output data of size DATA_WIDTH 
);

integer i; //Loop counter

always @(*) begin
    case(sel)
        2'b00: begin
            // Reverse entire data_in
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                data_out[i] = data_in[DATA_WIDTH-1-i];                      // Reversing all bits
            end
        end
        
        2'b01: begin
            // Reverse two halves of data_in
            for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
                data_out[i]                = data_in[DATA_WIDTH/2-1-i];     // First half reversed
                data_out[DATA_WIDTH/2 + i] = data_in[DATA_WIDTH-1-i];       // Second half reversed
            end
        end
        
        2'b10: begin
            // Reverse four sets of data_in
            for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
                data_out[i] = data_in[DATA_WIDTH/4-1-i]; 		            // First set reversed
                data_out[DATA_WIDTH/4 + i]   = data_in[DATA_WIDTH/2-1-i];   // Second set reversed
                data_out[DATA_WIDTH/2 + i]   = data_in[3*DATA_WIDTH/4-1-i]; // Third set reversed
                data_out[3*DATA_WIDTH/4 + i] = data_in[DATA_WIDTH-1-i];     // Fourth set reversed
            end
        end
        
        2'b11: begin
            // Reverse eight sets of data_in
            for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                data_out[i]                  = data_in[DATA_WIDTH/8-1-i];   // First set reversed
                data_out[DATA_WIDTH/8 + i]   = data_in[DATA_WIDTH/4-1-i];   // Second set reversed
                data_out[DATA_WIDTH/4 + i]   = data_in[3*DATA_WIDTH/8-1-i]; // Third set reversed
                data_out[3*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH/2-1-i];   // Fourth set reversed
                data_out[DATA_WIDTH/2 + i]   = data_in[5*DATA_WIDTH/8-1-i]; // Fifth set reversed
                data_out[5*DATA_WIDTH/8 + i] = data_in[3*DATA_WIDTH/4-1-i]; // Sixth set reversed
                data_out[3*DATA_WIDTH/4 + i] = data_in[7*DATA_WIDTH/8-1-i]; // Seventh set reversed
                data_out[7*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH-1-i];     // Eighth set reversed
            end
        end

        default: begin
            data_out = data_in;						                        // Default case
        end
    endcase
end

endmodule 
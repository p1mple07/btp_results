module nbit_swizzling #(parameter DATA_WIDTH = 16) (
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    //  2-bit selection signal 
    output reg [DATA_WIDTH + $clog2(DATA_WIDTH):0] ecc_out                   // Encoded output with parity bits
);

integer i; 
wire [PARITY_BITS-1:0] parity_bits;                                                            


assign parity_bits = ^data_in;

always @(*) begin
    case(sel)
        2'b00: begin
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                ecc_out[i] = data_in[DATA_WIDTH-1-i];                      
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b01: begin
            for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
                ecc_out[i]                = data_in[DATA_WIDTH/2-1-i];     
                ecc_out[DATA_WIDTH/2 + i] = data_in[DATA_WIDTH-1-i];       
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b10: begin
            for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
                ecc_out[i] = data_in[DATA_WIDTH/4-1-i]; 		            
                ecc_out[DATA_WIDTH/4 + i]   = data_in[3*DATA_WIDTH/4-1-i];   
                ecc_out[3*DATA_WIDTH/4 + i]   = data_in[DATA_WIDTH/2-1-i];   
                ecc_out[3*DATA_WIDTH/4 + i]   = parity_bits[i];
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b11: begin
            for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                ecc_out[i]                  = data_in[DATA_WIDTH/8-1-i];   
                ecc_out[DATA_WIDTH/8 + i]   = data_in[3*DATA_WIDTH/8-1-i];   
                ecc_out[3*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH/4-1-i];   
                ecc_out[DATA_WIDTH/4 + i]   = data_in[5*DATA_WIDTH/8-1-i]; 
                ecc_out[5*DATA_WIDTH/8 + i] = data_in[3*DATA_WIDTH/4-1-i]; 
                ecc_out[3*DATA_WIDTH/4 + i] = data_in[7*DATA_WIDTH/8-1-i]; 
                ecc_out[7*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH-1-i];     
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        default: begin
            for (i = DATA_WIDTH; i > 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
            ecc_out[0] = parity_bits[0];
        end
    endcase
end

endmodule module nbit_swizzling #(parameter DATA_WIDTH = 16) (
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    //  2-bit selection signal 
    output reg [DATA_WIDTH + $clog2(DATA_WIDTH):0] ecc_out                   // Encoded output with parity bits
);

integer i; 
wire [PARITY_BITS-1:0] parity_bits;                                                            


assign parity_bits = ^data_in;

always @(*) begin
    case(sel)
        2'b00: begin
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                ecc_out[i] = data_in[DATA_WIDTH-1-i];                      
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b01: begin
            for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
                ecc_out[i]                = data_in[DATA_WIDTH/2-1-i];     
                ecc_out[DATA_WIDTH/2 + i] = data_in[DATA_WIDTH-1-i];       
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b10: begin
            for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
                ecc_out[i] = data_in[DATA_WIDTH/4-1-i]; 		            
                ecc_out[DATA_WIDTH/4 + i]   = data_in[3*DATA_WIDTH/4-1-i];   
                ecc_out[3*DATA_WIDTH/4 + i]   = data_in[DATA_WIDTH/2-1-i];   
                ecc_out[3*DATA_WIDTH/4 + i]   = parity_bits[i];
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b11: begin
            for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                ecc_out[i]                  = data_in[DATA_WIDTH/8-1-i];   
                ecc_out[DATA_WIDTH/8 + i]   = data_in[3*DATA_WIDTH/8-1-i];   
                ecc_out[3*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH/4-1-i];   
                ecc_out[DATA_WIDTH/4 + i]   = data_in[5*DATA_WIDTH/8-1-i]; 
                ecc_out[5*DATA_WIDTH/8 + i] = data_in[3*DATA_WIDTH/4-1-i]; 
                ecc_out[3*DATA_WIDTH/4 + i] = data_in[7*DATA_WIDTH/8-1-i]; 
                ecc_out[7*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH-1-i];     
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        default: begin
            for (i = DATA_WIDTH; i > 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
            ecc_out[0] = parity_bits[0];
        end
    endcase
end

endmodule module nbit_swizzling #(parameter DATA_WIDTH = 16) (
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    //  2-bit selection signal 
    output reg [DATA_WIDTH + $clog2(DATA_WIDTH):0] ecc_out                   // Encoded output with parity bits
);

integer i; 
wire [PARITY_BITS-1:0] parity_bits;                                                            


assign parity_bits = ^data_in;

always @(*) begin
    case(sel)
        2'b00: begin
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                ecc_out[i] = data_in[DATA_WIDTH-1-i];                      
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b01: begin
            for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
                ecc_out[i]                = data_in[DATA_WIDTH/2-1-i];     
                ecc_out[DATA_WIDTH/2 + i] = data_in[DATA_WIDTH-1-i];       
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b10: begin
            for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
                ecc_out[i] = data_in[DATA_WIDTH/4-1-i]; 		            
                ecc_out[DATA_WIDTH/4 + i]   = data_in[3*DATA_WIDTH/4-1-i];   
                ecc_out[3*DATA_WIDTH/4 + i]   = data_in[DATA_WIDTH/2-1-i];   
                ecc_out[3*DATA_WIDTH/4 + i]   = parity_bits[i];
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b11: begin
            for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                ecc_out[i]                  = data_in[DATA_WIDTH/8-1-i];   
                ecc_out[DATA_WIDTH/8 + i]   = data_in[3*DATA_WIDTH/8-1-i];   
                ecc_out[3*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH/4-1-i];   
                ecc_out[3*DATA_WIDTH/8 + i]   = data_in[5*DATA_WIDTH/8-1-i]; 
                ecc_out[5*DATA_WIDTH/8 + i] = data_in[3*DATA_WIDTH/4-1-i]; 
                ecc_out[3*DATA_WIDTH/4 + i] = data_in[7*DATA_WIDTH/8-1-i]; 
                ecc_out[7*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH-1-i];     
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        default: begin
            for (i = DATA_WIDTH; i > 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
            ecc_out[0] = parity_bits[0];
        end
    endcase
end

endmodule

// Calculate PARITY_BITS
parameter PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1);

// Assuming PARITY_BITS is calculated and set before the module definition
// It should be set in the top module or within the same module before the always block
// For example:
// parameter PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1);
// or within the always block like this:
// assign PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1);
// Then use PARITY_BITS as shown above in the module definition
 module nbit_swizzling #(parameter DATA_WIDTH = 16) (
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    //  2-bit selection signal 
    output reg [DATA_WIDTH + PARITY_BITS-1:0] ecc_out                   // Encoded output with parity bits
);

integer i; 
wire [PARITY_BITS-1:0] parity_bits;                                                            

initial begin
    // Calculate PARITY_BITS based on DATA_WIDTH
    PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1);
end

always @(*) begin
    case(sel)
        2'b00: begin
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                ecc_out[i] = data_in[DATA_WIDTH-1-i];                      
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b01: begin
            for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
                ecc_out[i]                = data_in[DATA_WIDTH/2-1-i];     
                ecc_out[DATA_WIDTH/2 + i] = data_in[DATA_WIDTH-1-i];       
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b10: begin
            for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
                ecc_out[i] = data_in[DATA_WIDTH/4-1-i]; 		            
                ecc_out[DATA_WIDTH/4 + i]   = data_in[3*DATA_WIDTH/4-1-i];   
                ecc_out[3*DATA_WIDTH/4 + i]   = data_in[DATA_WIDTH/2-1-i];   
                ecc_out[3*DATA_WIDTH/4 + i]   = parity_bits[i];
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b11: begin
            for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                ecc_out[i]                  = data_in[DATA_WIDTH/8-1-i];   
                ecc_out[DATA_WIDTH/8 + i]   = data_in[3*DATA_WIDTH/8-1-i];   
                ecc_out[3*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH/4-1-i];   
                ecc_out[3*DATA_WIDTH/8 + i]   = data_in[5*DATA_WIDTH/8-1-i]; 
                ecc_out[5*DATA_WIDTH/8 + i] = data_in[3*DATA_WIDTH/4-1-i]; 
                ecc_out[3*DATA_WIDTH/4 + i] = data_in[7*DATA_WIDTH/8-1-i]; 
                ecc_out[7*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH-1-i];     
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        default: begin
            for (i = DATA_WIDTH; i > 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
            ecc_out[0] = parity_bits[0];
        end
    endcase
end

endmodule

// In the instantiation of the module, DATA_WIDTH should be defined, e.g.:
// nbit_swizzling myModuleInstance (DATA_WIDTH = 16);
// Note: The actual instantiation will depend on the specific design and requirements of the project. module nbit_swizzling #(parameter DATA_WIDTH = 16) (
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    //  2-bit selection signal 
    output reg [DATA_WIDTH + PARITY_BITS-1:0] ecc_out                   // Encoded output with parity bits
);

integer i; 
wire [PARITY_BITS-1:0] parity_bits;                                                            

// Calculate PARITY_BITS within the module
parameter PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1);

always @(*) begin
    case(sel)
        2'b00: begin
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                ecc_out[i] = data_in[DATA_WIDTH-1-i];                      
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b01: begin
            for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
                ecc_out[i]                = data_in[DATA_WIDTH/2-1-i];     
                ecc_out[DATA_WIDTH/2 + i] = data_in[DATA_WIDTH-1-i];       
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b10: begin
            for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
                ecc_out[i] = data_in[DATA_WIDTH/4-1-i]; 		            
                ecc_out[DATA_WIDTH/4 + i]   = data_in[3*DATA_WIDTH/4-1-i];   
                ecc_out[3*DATA_WIDTH/4 + i]   = data_in[DATA_WIDTH/2-1-i];   
                ecc_out[3*DATA_WIDTH/4 + i]   = parity_bits[i];
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        
        2'b11: begin
            for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                ecc_out[i]                  = data_in[DATA_WIDTH/8-1-i];   
                ecc_out[DATA_WIDTH/8 + i]   = data_in[3*DATA_WIDTH/8-1-i];   
                ecc_out[3*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH/4-1-i];   
                ecc_out[3*DATA_WIDTH/8 + i]   = data_in[5*DATA_WIDTH/8-1-i]; 
                ecc_out[5*DATA_WIDTH/8 + i] = data_in[3*DATA_WIDTH/4-1-i]; 
                ecc_out[3*DATA_WIDTH/4 + i] = data_in[7*DATA_WIDTH/8-1-i]; 
                ecc_out[7*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH-1-i];     
            end
            for (i = PARITY_BITS-1; i >= 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
        end
        default: begin
            for (i = DATA_WIDTH; i > 0; i = i - 1) begin
                ecc_out[i] = parity_bits[i];
            end
            ecc_out[0] = parity_bits[0];
        end
    endcase
end

endmodule
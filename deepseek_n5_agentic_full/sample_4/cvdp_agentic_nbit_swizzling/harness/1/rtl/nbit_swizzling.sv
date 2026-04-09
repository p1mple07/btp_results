Module definition with documentation
module nbit_swizzling(
    // Data inputs
    parameter DATA_WIDTH,
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,

    // Data outputs
    output [DATA_WIDTH-1:0] data_out,
    output [DATA_WIDTH-1:0] gray_out
);

    // Description of the swizzling pattern based on sel
    // Description of the Gray code generation process

    // Configuration handling for sel value
    parameter DEFAULTSel = 2'b00;
    
    // Generate the data_out based on sel value
    case(sel)
        DEFAULTSel:
            // Reverse entire input data
            data_out = data_in ^ ((1 << DATA_WIDTH) - 1); // Equivalent to bitwise NOT followed by +1
        
        2'b01:
            // Split into two halves and reverse each
            integer half_width = DATA_WIDTH / 2;
            
            // Lower half reversal
            data_out[0 : half_width - 1] = data_in[half_width : DATA_WIDTH-1];
            
            // Upper half reversal
            data_out[half_width : DATA_WIDTH-1] = data_in[0 : half_width - 1];
        
        2'b10:
            // Split into four quarters and reverse each
            integer quarter_width = DATA_WIDTH / 4;
            
            // First quarter reversal
            data_out[0 : quarter_width - 1] = data_in[DATA_WIDTH-1 : DATA_WIDTH - quarter_width];
            
            // Second quarter reversal
            data_out[quarter_width : 2*quarter_width - 1] = data_in[DATA_WIDTH - quarter_width : DATA_WIDTH - 2*quarter_width];
            
            // Third quarter reversal
            data_out[2*quarter_width : 3*quarter_width - 1] = data_in[2*quarter_width : 3*quarter_width -1];
            
            // Fourth quarter reversal
            data_out[3*quarter_width : DATA_WIDTH-1] = data_in[3*quarter_width : DATA_WIDTH-1];
        
        2'b11:
            // Split into eight segments and reverse each
            integer seg_width = DATA_WIDTH / 8;
            
            // Reverse each segment
            for (integer i = 0; i < 8; i++) {
                data_out[i*seg_width : (i+1)*seg_width -1]
                    = data_in[DATA_WIDTH - (i+1)*seg_width : DATA_WIDTH - i*seg_width];
            }
        
        // Invalid sel value - default pass-through
        default:
            data_out = data_in;
    endcase

    // Generate Gray code from data_out
    generate
        // Gray code formula: G(i) = D(i) XOR D(i+1)
        for (integer i = DATA_WIDTH-1; i > 0; i--) {
            gray_out[i] = data_out[i] ^ data_out[i+1];
        }
        // MSB remains the same
        gray_out[0] = data_out[0];
    endgenerate
endmodule
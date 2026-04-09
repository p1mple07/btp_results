// Module declaration
module rtl/nbit_swizzling(
    parameter wire [DATA_WIDTH-1:0] data_in,
    parameter wire [1:0] sel,
    wire [DATA_WIDTH-1:0] data_out,
    wire [DATA_WIDTH-1:0] gray_out
);

// Description
// The nbit_swizzling module performs bit rearrangement (swizzling) and Gray code conversion on an input data bus.
// The module offers four swizzling patterns controlled by a 2-bit selection signal.
// After the swizzling operation, an additional logic block generates the Gray-coded version of the swizzled output.

// Swizzling patterns
case (sel)
    2'b00: // Reverse entire input
        data_out = reverse(data_in);
        gray_out = gray_code(data_out);
    2'b01: // Split into two halves and reverse each half
        // First half reversal
        local [DATA_WIDTH/2-1:0] first_half = data_in[(DATA_WIDTH/2-1):0];
        local [DATA_WIDTH/2-1:0] reversed_first = reverse(first_half);
        
        // Second half reversal
        local [DATA_WIDTH/2-1:DATA_WIDTH-1] second_half = data_in[(DATA_WIDTH/2):DATA_WIDTH-1];
        local [DATA_WIDTH/2-1:DATA_WIDTH-1] reversed_second = reverse(second_half);
        
        data_out = (reversed_second)[(DATA_WIDTH/2):DATA_WIDTH-1] | (reversed_first)[0:DATA_WIDTH/2-1];
        gray_out = gray_code(data_out);
    2'b10: // Split into four quarters and reverse each quarter
        // Quarter 1 reversal
        local [DATA_WIDTH/4-1:0] q1 = data_in[(DATA_WIDTH/4-1):0];
        local [DATA_WIDTH/4-1:0] rq1 = reverse(q1);
        
        // Quarter 2 reversal
        local [DATA_WIDTH/4-1:DATA_WIDTH/4-1 + DATA_WIDTH/4 -1] q2 = data_in[(DATA_WIDTH/4):DATA_WIDTH/4 + DATA_WIDTH/4 -1];
        local [DATA_WIDTH/4-1:DATA_WIDTH/4 + DATA_WIDTH/4 -1] rq2 = reverse(q2);
        
        // Quarter 3 reversal
        local [DATA_WIDTH/4-1: DATA_WIDTH/4*2 -1] q3 = data_in[(DATA_WIDTH/4*2): DATA_WIDTH/4*2 + DATA_WIDTH/4 -1];
        local [DATA_WIDTH/4-1: DATA_WIDTH/4*2 -1] rq3 = reverse(q3);
        
        // Quarter 4 reversal
        local [DATA_WIDTH/4-1: DATA_WIDTH/4*3 -1] q4 = data_in[(DATA_WIDTH/4*3): DATA_WIDTH/4*3 + DATA_WIDTH/4 -1];
        local [DATA_WIDTH/4-1: DATA_WIDTH/4*3 -1] rq4 = reverse(q4);
        
        data_out = (
            rq4)[DATA_WIDTH/4*3 : DATA_WIDTH/4*3 + DATA_WIDTH/4 -1] |
            (
                rq3)[DATA_WIDTH/4*2 : DATA_WIDTH/4*2 + DATA_WIDTH/4 -1] |
            (
                rq2)[DATA_WIDTH/4 : DATA_WIDTH/4 + DATA_WIDTH/4 -1] |
            rq1[0:DATA_WIDTH/4 -1];
        gray_out = gray_code(data_out);
    2'b11: // Split into eight segments and reverse each segment
        // Segment 1 reversal
        local [DATA_WIDTH/8-1:0] s1 = data_in[(DATA_WIDTH/8-1):0];
        local [DATA_WIDTH/8-1:0] rs1 = reverse(s1);
        
        // Segment 2 reversal
        local [DATA_WIDTH/8-1:DATA_WIDTH/8-1 + DATA_WIDTH/8 -1] s2 = data_in[(DATA_WIDTH/8):DATA_WIDTH/8 + DATA_WIDTH/8 -1];
        local [DATA_WIDTH/8-1:DATA_WIDTH/8 + DATA_WIDTH/8 -1] rs2 = reverse(s2);
        
        // Segment 3 reversal
        local [DATA_WIDTH/8-1: DATA_WIDTH/8*2 -1] s3 = data_in[(DATA_WIDTH/8*2): DATA_WIDTH/8*2 + DATA_WIDTH/8 -1];
        local [DATA_WIDTH/8-1: DATA_WIDTH/8*2 -1] rs3 = reverse(s3);
        
        // Segment 4 reversal
        local [DATA_WIDTH/8-1: DATA_WIDTH/8*3 -1] s4 = data_in[(DATA_WIDTH/8*3): DATA_WIDTH/8*3 + DATA_WIDTH/8 -1];
        local [DATA_WIDTH/8-1: DATA_WIDTH/8*3 -1] rs4 = reverse(s4);
        
        // Segment 5 reversal
        local [DATA_WIDTH/8-1: DATA_WIDTH/8*4 -1] s5 = data_in[(DATA_WIDTH/8*4): DATA_WIDTH/8*4 + DATA_WIDTH/8 -1];
        local [DATA_WIDTH/8-1: DATA_WIDTH/8*4 -1] rs5 = reverse(s5);
        
        // Segment 6 reversal
        local [DATA_WIDTH/8-1: DATA_WIDTH/8*5 -1] s6 = data_in[(DATA_WIDTH/8*5): DATA_WIDTH/8*5 + DATA_WIDTH/8 -1];
        local [DATA_WIDTH/8-1: DATA_WIDTH/8*5 -1] rs6 = reverse(s6);
        
        // Segment 7 reversal
        local [DATA_WIDTH/8-1: DATA_WIDTH/8*6 -1] s7 = data_in[(DATA_WIDTH/8*6): DATA_WIDTH/8*6 + DATA_WIDTH/8 -1];
        local [DATA_WIDTH/8-1: DATA_WIDTH/8*6 -1] rs7 = reverse(s7);
        
        // Segment 8 reversal
        local [DATA_WIDTH/8-1: DATA_WIDTH/8*7 -1] s8 = data_in[(DATA_WIDTH/8*7): DATA_WIDTH/8*7 + DATA_WIDTH/8 -1];
        local [DATA_WIDTH/8-1: DATA_WIDTH/8*7 -1] rs8 = reverse(s8);
        
        data_out = (
            rs8)[DATA_WIDTH/8*7 : DATA_WIDTH/8*7 + DATA_WIDTH/8 -1] |
            (
                rs7)[DATA_WIDTH/8*6 : DATA_WIDTH/8*6 + DATA_WIDTH/8 -1] |
            (
                rs6)[DATA_WIDTH/8*5 : DATA_WIDTH/8*5 + DATA_WIDTH/8 -1] |
            (
                rs5)[DATA_WIDTH/8*4 : DATA_WIDTH/8*4 + DATA_WIDTH/8 -1] |
            (
                rs4)[DATA_WIDTH/8*3 : DATA_WIDTH/8*3 + DATA_WIDTH/8 -1] |
            (
                rs3)[DATA_WIDTH/8*2 : DATA_WIDTH/8*2 + DATA_WIDTH/8 -1] |
            (
                rs2)[DATA_WIDTH/8 : DATA_WIDTH/8 + DATA_WIDTH/8 -1] |
            rs1[0:DATA_WIDTH/8 -1];
        gray_out = gray_code(data_out);
    default:
        // No change if sel is invalid
        data_out = data_in;
        gray_out = data_out;
        break;
endcase

// Helper function to reverse a portion of the data
function [DATA_WIDTH-1:0] reverse(input [DATA_WIDTH-1:0] data) {
    local [DATA_WIDTH-1:0] reversed = 0;
    for (integer i = 0; i < DATA_WIDTH; i++) {
        reversed |= ((data >> i) & 1) << (DATA_WIDTH - 1 - i);
    }
    return reversed;
}

// Helper function to generate Gray code from data
function [DATA_WIDTH-1:0] gray_code(input [DATA_WIDTH-1:0] data) {
    local [DATA_WIDTH-1:0] gray = 0;
    gray = data ^ (data >> 1);
    return gray;
}

// End of module
Module definition
module rtl/nbit_swizzling(
    parameter wire [DATA_WIDTH-1:0] data_out,
    parameter wire [DATA_WIDTH-1:0] gray_out,
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel
);

// Description
// The nbit_swizzling module performs bit rearrangement (swizzling) on an input data bus
// of variable width based on a 2-bit selection signal. After swizzling, a Gray code
// conversion is generated from the reversed output.

// Swizzling control
if (sel == 2'b00) {
    // Reverse entire input data
    data_out = reverse_data(data_in, DATA_WIDTH);
} else if (sel == 2'b01) {
    // Split into two halves and reverse each
    local wire [DATA_WIDTH/2 -1:0] lower_half, upper_half;
    lower_half = data_in[(DATA_WIDTH/2):0];
    upper_half = data_in[(DATA_WIDTH-1):DATA_WIDTH/2];
    
    data_out = reverse_half(lower_half, DATA_WIDTH/2) | reverse_half(upper_half, DATA_WIDTH/2);
} else if (sel == 2'b10) {
    // Split into four quarters and reverse each
    local wire [DATA_WIDTH/4 -1:0] q1, q2, q3, q4;
    q1 = data_in[(DATA_WIDTH/2 + DATA_WIDTH/4):0];
    q2 = data_in[(DATA_WIDTH/2 -1):DATA_WIDTH/2];
    q3 = data_in[(DATA_WIDTH/4 -1):DATA_WIDTH/2 -1];
    q4 = data_in[(DATA_WIDTH-1):(DATA_WIDTH/2)];
    
    q1 = reverse_quarter(q1, DATA_WIDTH/4);
    q2 = reverse_quarter(q2, DATA_WIDTH/4);
    q3 = reverse_quarter(q3, DATA_WIDTH/4);
    q4 = reverse_quarter(q4, DATA_WIDTH/4);
    
    data_out = q1 | q2 | q3 | q4;
} else if (sel == 2'b11) {
    // Split into eight segments and reverse each
    local wire [DATA_WIDTH/8 -1:0] s1,s2,s3,s4,s5,s6,s7,s8;
    s1 = data_in[(DATA_WIDTH/4 + DATA_WIDTH/8):0];
    s2 = data_in[(DATA_WIDTH/4 -1):DATA_WIDTH/4];
    s3 = data_in[(DATA_WIDTH/2 -1):DATA_WIDTH/4 -1];
    s4 = data_in[(DATA_WIDTH/2 - DATA_WIDTH/8 -1):DATA_WIDTH/2 - DATA_WIDTH/8];
    s5 = data_in[(DATA_WIDTH-1):(DATA_WIDTH/4)];
    s6 = data_in[(DATA_WIDTH/2 -1):DATA_WIDTH/4];
    s7 = data_in[(DATA_WIDTH/4 -1):DATA_WIDTH/2 - DATA_WIDTH/8];
    s8 = data_in[(DATA_WIDTH-1):DATA_WIDTH/2];
    
    s1 = reverse_eighth(s1, DATA_WIDTH/8);
    s2 = reverse_eighth(s2, DATA_WIDTH/8);
    s3 = reverse_eighth(s3, DATA_WIDTH/8);
    s4 = reverse_eighth(s4, DATA_WIDTH/8);
    s5 = reverse_eighth(s5, DATA_WIDTH/8);
    s6 = reverse_eighth(s6, DATA_WIDTH/8);
    s7 = reverse_eighth(s7, DATA_WIDTH/8);
    s8 = reverse_eighth(s8, DATA_WIDTH/8);
    
    data_out = s1 | s2 | s3 | s4 | s5 | s6 | s7 | s8;
} else {
    // Default case: no change
    data_out = data_in;
}

// Generate Gray code
if (DATA_WIDTH > 1) {
    gray_out = data_out >> 1 ^ data_out;
}
endmodule
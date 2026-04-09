Module Implementation: nbit_swizzling

module rtl.nbit_swizzling(
    parameter DATA_WIDTH,
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output [DATA_WIDTH-1:0] data_out,
    output [DATA_WIDTH-1:0] gray_out
);

// Description: Perform bit rearrangement (swizzling) on the input data based on the sel signal
// and generate Gray coded output from the rearranged data.

// Swizzling Logic Implementation
always_comb begin
    // Case sel = 00: Reverse entire input
    if (sel == 2'b00) begin
        data_out = data_in[data_width-1:0];
    end
    // Case sel = 01: Split into two halves and reverse each half
    else if (sel == 2'b01) begin
        // Lower half of data_in
        wire [DATA_WIDTH/2-1:0] lower_half = data_in[(DATA_WIDTH/2):0];
        wire [DATA_WIDTH/2-1:0] reversed_lower = lower_half[::-1];
        
        // Upper half of data_in
        wire [DATA_WIDTH/2-1:0] upper_half = data_in[(DATA_WIDTH):DATA_WIDTH/2];
        wire [DATA_WIDTH/2-1:0] reversed_upper = upper_half[::-1];
        
        // Combine reversed halves
        data_out = (reversed_upper << (DATA_WIDTH/2)) | reversed_lower;
    end
    // Case sel = 10: Split into four quarters and reverse each quarter
    else if (sel == 2'b10) begin
        // Q1: Bits 0-7
        wire [DATA_WIDTH/4-1:0] q1 = data_in[(DATA_WIDTH/4):0];
        wire [DATA_WIDTH/4-1:0] rev_q1 = q1[::-1];
        
        // Q2: Bits 8-15
        wire [DATA_WIDTH/4-1:0] q2 = data_in[((DATA_WIDTH/4)+8):((DATA_WIDTH/4)+8)+8];
        wire [DATA_WIDTH/4-1:0] rev_q2 = q2[::-1];
        
        // Q3: Bits 16-23
        wire [DATA_WIDTH/4-1:0] q3 = data_in[((DATA_WIDTH/4)*3):((DATA_WIDTH/4)*3)+8];
        wire [DATA_WIDTH/4-1:0] rev_q3 = q3[::-1];
        
        // Q4: Bits 24-31
        wire [DATA_WIDTH/4-1:0] q4 = data_in[((DATA_WIDTH/4)*4):((DATA_WIDTH/4)*4)+8];
        wire [DATA_WIDTH/4-1:0] rev_q4 = q4[::-1];
        
        // Combine reversed quarters
        data_out = rev_q4 << (2*DATA_WIDTH/4) | rev_q3 << (DATA_WIDTH/4) | rev_q2 | rev_q1;
    end
    // Case sel = 11: Split into eight segments and reverse each segment
    else if (sel == 2'b11) begin
        // Segment size calculation
        local int seg_size = DATA_WIDTH / 8;
        
        // Segment reversal implementation
        for (int i = 0; i < 8; i++) begin
            wire [seg_size-1:0] segment = data_in[((i * seg_size) + seg_size-1): (i * seg_size)];
            wire [seg_size-1:0] rev_segment = segment[::-1];
            data_out[(i * seg_size): (i * seg_size + seg_size)] = rev_segment;
        end
    end
    // Default case: Pass through data_in
    else begin
        data_out = data_in;
    end
end

// Gray Code Generation Logic
always_comb begin
    if (data_out != data_in) begin
        // Generate Gray code
        gray_out = data_out & ~((1 << DATA_WIDTH) - 1); // Set MSB
        
        for (int i = DATA_WIDTH-2; i >= 0; i--) begin
            gray_out[i] = data_out[i] ^ data_out[i+1];
        end
    end
end

endmodule
module nbit_swizzling #(
    parameter int DATA_WIDTH = 64
)(
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic [1:0] sel,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic [DATA_WIDTH-1:0] gray_out
);

// Helper function to reverse a subarray of bits
function logic [DATA_WIDTH-1:0] reverse_slice(input logic [DATA_WIDTH-1:0] mem);
    logic [DATA_WIDTH-1:0] result;
    assign result = mem[DATA_WIDTH-1:0];
    if (sel == 2'b00) begin
        // reverse entire
        for (int i = 0; i < DATA_WIDTH / 2; i++) begin
            swap result[i], result[DATA_WIDTH-1-i];
        end
    end else if (sel == 2'b01) begin
        // split into two halves, reverse each
        logic [DATA_WIDTH/2-1:0] low, high;
        assign low = mem[0:(DATA_WIDTH/2)-1];
        assign high = mem[(DATA_WIDTH/2):DATA_WIDTH-1];
        // reverse low and high
        for (int i = 0; i < (DATA_WIDTH/2); i++) begin
            swap low[i], low[DATA_WIDTH-1-i];
            swap high[i], high[DATA_WIDTH-1-i];
        end
        assign result = low + high;
    end else if (sel == 2'b10) begin
        // split into four quarters
        logic [DATA_WIDTH/4-1:0] q1, q2, q3, q4;
        assign q1 = mem[0:(DATA_WIDTH/4)-1];
        assign q2 = mem[(DATA_WIDTH/4):(2*DATA_WIDTH/4)-1];
        assign q3 = mem[(2*DATA_WIDTH/4):(3*DATA_WIDTH/4)-1];
        assign q4 = mem[(3*DATA_WIDTH/4):DATA_WIDTH-1];
        // reverse each quarter
        for (int i = 0; i < (DATA_WIDTH/4); i++) begin
            swap q1[i], q1[DATA_WIDTH/4-1-i];
            swap q2[i], q2[DATA_WIDTH/4-1-i];
            swap q3[i], q3[DATA_WIDTH/4-1-i];
            swap q4[i], q4[DATA_WIDTH/4-1-i];
        end
        // combine
        result = q4 + q3 + q2 + q1;
    end else if (sel == 2'b11) begin
        // eight segments
        logic [DATA_WIDTH/8-1:0] seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
        assign seg1 = mem[0:(DATA_WIDTH/8)-1];
        assign seg2 = mem[(DATA_WIDTH/8):(2*DATA_WIDTH/8)-1];
        assign seg3 = mem[(2*DATA_WIDTH/8):(3*DATA_WIDTH/8)-1];
        assign seg4 = mem[(3*DATA_WIDTH/8):(4*DATA_WIDTH/8)-1];
        assign seg5 = mem[(4*DATA_WIDTH/8):(5*DATA_WIDTH/8)-1];
        assign seg6 = mem[(5*DATA_WIDTH/8):(6*DATA_WIDTH/8)-1];
        assign seg7 = mem[(6*DATA_WIDTH/8):(7*DATA_WIDTH/8)-1];
        assign seg8 = mem[(7*DATA_WIDTH/8):DATA_WIDTH-1];
        // reverse each segment
        for (int i = 0; i < (DATA_WIDTH/8); i++) begin
            swap seg1[i], seg1[DATA_WIDTH/8-1-i];
            swap seg2[i], seg2[DATA_WIDTH/8-1-i];
            swap seg3[i], seg3[DATA_WIDTH/8-1-i];
            swap seg4[i], seg4[DATA_WIDTH/8-1-i];
            swap seg5[i], seg5[DATA_WIDTH/8-1-i];
            swap seg6[i], seg6[DATA_WIDTH/8-1-i];
            swap seg7[i], seg7[DATA_WIDTH/8-1-i];
            swap seg8[i], seg8[DATA_WIDTH/8-1-i];
        end
        // combine
        result = seg8 + seg7 + seg6 + seg5 + seg4 + seg3 + seg2 + seg1;
    end else begin
        // default: pass through
        data_out = data_in;
    end

endfunction

// Gray code generation: XOR adjacent bits
logic [DATA_WIDTH-1:0] gray;
always @(*) begin
    gray = data_out[DATA_WIDTH-2:0];
    for (int j = DATA_WIDTH-2; j >= 0; j--) begin
        gray[j] = data_out[j+1] ^ data_out[j];
    end
end

endmodule

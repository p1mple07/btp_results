module nbit_swizzling #(
    parameter data_width = 64
) (
    input logic [data_width-1:0] data_in,
    input logic sel,
    output logic [data_width-1:0] data_out,
    output logic gray_out
);

    // Helper function to reverse a slice of bits
    function logic [data_width-1:0] reverse_slice(input logic [data_width-1:0] src);
        logic [data_width-1:0] rev;
        for (int i = 0; i < data_width; i++) begin
            rev[i] = src[data_width - 1 - i];
        end
        return rev;
    endfunction

    // Process based on sel
    always @(*) begin
        if (sel == 2'b00) begin
            data_out = reverse_slice(data_in);
        end else if (sel == 2'b01) begin
            // Split into two halves
            logic [data_width/2-1:0] left, right;
            assign left = data_in[0 : data_width/2 - 1];
            assign right = data_in[data_width/2 : data_width - 1];
            logic [data_width/2-1:0] rev_left, rev_right;
            for (int i = 0; i < data_width/2; i++) begin
                rev_left[i] = left[data_width - 1 - i];
                rev_right[i] = right[data_width - 1 - i];
            end
            data_out = rev_left[::] + rev_right[::];
        end else if (sel == 2'b10) begin
            // Four quarters
            logic [data_width/4-1:0] quarter1, quarter2, quarter3, quarter4;
            assign quarter1 = data_in[0 : data_width/4 - 1];
            assign quarter2 = data_in[data_width/4 : data_width/2 - 1];
            assign quarter3 = data_in[data_width/2 : data_width*3/4 - 1];
            assign quarter4 = data_in[data_width*3/4 : data_width - 1];
            logic [data_width/4-1:0] rev_q1, rev_q2, rev_q3, rev_q4;
            for (int i = 0; i < data_width/4; i++) begin
                rev_q1[i] = quarter1[data_width - 1 - i];
                rev_q2[i] = quarter2[data_width - 1 - i];
                rev_q3[i] = quarter3[data_width - 1 - i];
                rev_q4[i] = quarter4[data_width - 1 - i];
            end
            data_out = rev_q1[::] + rev_q2[::] + rev_q3[::] + rev_q4[::];
        end else if (sel == 2'b11) begin
            // Eighths
            logic [data_width/8-1:0] eighth1, eighth2, eighth3, eighth4, eighth5, eighth6, eighth7, eighth8;
            assign eighth1 = data_in[0 : data_width/8 - 1];
            assign eighth2 = data_in[data_width/8 : data_width/4 - 1];
            assign eighth3 = data_in[data_width/4 : data_width*3/8 - 1];
            assign eighth4 = data_in[data_width*3/8 : data_width*7/8 - 1];
            assign eighth5 = data_in[data_width*7/8 : data_width*15/16 - 1];
            assign eighth6 = data_in[data_width*15/16 : data_width*31/32 - 1];
            assign eighth7 = data_in[data_width*31/32 : data_width*63/64 - 1];
            assign eighth8 = data_in[data_width*63/64 : data_width - 1];
            logic [data_width/8-1:0] rev_e1, rev_e2, rev_e3, rev_e4, rev_e5, rev_e6, rev_e7, rev_e8;
            for (int i = 0; i < data_width/8; i++) begin
                rev_e1[i] = eighth1[data_width - 1 - i];
                rev_e2[i] = eighth2[data_width - 1 - i];
                rev_e3[i] = eighth3[data_width - 1 - i];
                rev_e4[i] = eighth4[data_width - 1 - i];
                rev_e5[i] = eighth5[data_width - 1 - i];
                rev_e6[i] = eighth6[data_width - 1 - i];
                rev_e7[i] = eighth7[data_width - 1 - i];
                rev_e8[i] = eighth8[data_width - 1 - i];
            end
            data_out = rev_e1[::] + rev_e2[::] + rev_e3[::] + rev_e4[::] + rev_e5[::] + rev_e6[::] + rev_e7[::] + rev_e8[::];
        end else begin
            data_out = data_in;
        end
    end

    // Gray code conversion
    logic [data_width-1:0] gray_out;
    for (int i = 0; i < data_width; i++) begin
        gray_out[i] = data_out[i+1] ^ data_out[i];
    end

endmodule

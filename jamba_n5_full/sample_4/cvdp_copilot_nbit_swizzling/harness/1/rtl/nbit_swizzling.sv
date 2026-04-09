module nbit_swizzling #(parameter DATA_WIDTH=64) (
    input logic [DATA_WIDTH-1:0] data_in,
    input logic [1:0] sel,
    output logic [DATA_WIDTH-1:0] data_out
);

    // Helper routine to reverse a contiguous block of bits
    function logic [DATA_WIDTH-1:0] reverse_bits(logic [DATA_WIDTH-1:0] val, int len);
        logic [DATA_WIDTH-1:0] reversed = val;
        for (int i = 0; i < len/2; i++) begin
            swap(reversed[i], reversed[len-1-i]);
        end
        return reversed;
    endfunction

    localparam int num_sections = 8;
    localparam int half_size = DATA_WIDTH / 2;
    localparam int quarter_size = DATA_WIDTH / 4;
    localparam int eighth_size = DATA_WIDTH / 8;

    always @(*) begin
        if (sel == 0) begin
            data_out = reverse_bits(data_in, DATA_WIDTH);
        end else if (sel == 1) begin
            logic [DATA_WIDTH/2-1:0] first = data_in[0 : half_size - 1];
            logic [DATA_WIDTH/2-1:0] second = data_in[half_size : DATA_WIDTH - 1];
            data_out = reverse_bits(first, half_size) & reverse_bits(second, half_size);
        end else if (sel == 2) begin
            logic [quarter_size-1:0] q1 = data_in[0 : quarter_size - 1];
            logic [quarter_size-1:0] q2 = data_in[quarter_size - 1 : quarter_size];
            logic [quarter_size-1:0] q3 = data_in[quarter_size : 2*quarter_size - 1];
            logic [quarter_size-1:0] q4 = data_in[2*quarter_size - 1 : DATA_WIDTH - 1];
            data_out = reverse_bits(q1, quarter_size) & reverse_bits(q2, quarter_size) & reverse_bits(q3, quarter_size) & reverse_bits(q4, quarter_size);
        end else if (sel == 3) begin
            logic [eighth_size-1:0] s1 = data_in[0 : eighth_size - 1];
            logic [eighth_size-1:0] s2 = data_in[eighth_size - 1 : eighth_size];
            logic [eighth_size-1:0] s3 = data_in[eighth_size : 2*eighth_size - 1];
            logic [eighth_size-1:0] s4 = data_in[2*eighth_size - 1 : DATA_WIDTH - 1];
            data_out = reverse_bits(s1, eighth_size) & reverse_bits(s2, eighth_size) & reverse_bits(s3, eighth_size) & reverse_bits(s4, eighth_size);
        end else if (sel == 4) begin // Default behaviour matches sel=0
            data_out = data_in;
        end else begin
            data_out = data_in;
        end
    end

endmodule

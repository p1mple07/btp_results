module dbi_enc(
    input [39:0] data_in,
    input clk,
    input rst_n,
    output reg [39:0] data_out,
    output reg [1:0] dbi_cntrl
);

reg [20:0] prev_group_1, prev_group_0;

initial begin
    dbi_cntrl = 2'b00;
    data_out = 40'h0000_0000;
    prev_group_1 = 20'h0000_0000;
    prev_group_0 = 20'h0000_0000;
end

always @(posedge clk) begin
    if (rst_n) begin
        prev_group_1 <= 20'h0000_0000;
        prev_group_0 <= 20'h0000_0000;
        dbi_cntrl <= 2'b00;
        data_out <= 40'h0000_0000;
    end else begin
        if (prev_group_1 != data_in[39:20]) begin
            if (bit_count(data_in[39:20] ^ prev_group_1) > 10) begin
                dbi_cntrl[1] = 1'b1;
                data_out[39:20] = ~data_in[39:20];
            end else begin
                dbi_cntrl[1] = 1'b0;
                data_out[39:20] = data_in[39:20];
            end
        end

        if (prev_group_0 != data_in[19:0]) begin
            if (bit_count(data_in[19:0] ^ prev_group_0) > 10) begin
                dbi_cntrl[0] = 1'b1;
                data_out[19:0] = ~data_in[19:0];
            end else begin
                dbi_cntrl[0] = 1'b0;
                data_out[19:0] = data_in[19:0];
            end
        end

        prev_group_1 <= data_in[39:20];
        prev_group_0 <= data_in[19:0];
    end
end

endmodule

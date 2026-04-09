module dbi_enc(
    input clk,
    input rst_n,
    input [39:0] data_in,
    output reg [39:0] data_out,
    output reg [1:0] dbi_cntrl
);

    reg [20:0] prev_group1, prev_group0;

    initial begin
        prev_group1 = 32'h0000_0000;
        prev_group0 = 32'h0000_0000;
    end

    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            data_out <= 32'h0000_0000;
            dbi_cntrl <= 2'b00;
        end else begin
            if (prev_group1 != data_in[39:20]) begin
                dbi_cntrl[1] <= (prev_group1 ^ data_in[39:20]) > 10;
                if (dbi_cntrl[1]) begin
                    data_out[39:20] <= ~data_in[39:20];
                end else begin
                    data_out[39:20] <= data_in[39:20];
                end
            end

            if (prev_group0 != data_in[19:0]) begin
                dbi_cntrl[0] <= (prev_group0 ^ data_in[19:0]) > 10;
                if (dbi_cntrl[0]) begin
                    data_out[19:0] <= ~data_in[19:0];
                end else begin
                    data_out[19:0] <= data_in[19:0];
                end
            end

            prev_group1 <= data_in[39:20];
            prev_group0 <= data_in[19:0];
        end
    end

endmodule

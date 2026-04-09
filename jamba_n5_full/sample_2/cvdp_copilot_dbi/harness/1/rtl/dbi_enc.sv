module dbi_enc (
    input  logic [39:0] data_in,
    input  logic         clk,
    input  negedge rst_n,
    output reg [39:0] data_out,
    output dbi_cntrl [1:0] dbi_cntrl
);

    localparam first_op = ~rst_n;

    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            data_out <= 40'd0;
            dbi_cntrl[1:0] = 2'b00;
            prev_data <= 40'd0;
            first_op = 1'b1;
        end else begin
            if (first_op) begin
                first_op = 1'b0;
                data_out <= data_in;
                dbi_cntrl[1:0] = 2'b00;
                prev_data <= data_in;
            end else begin
                logic diff_group1;
                diff_group1 = data_in xor prev_data;
                int cnt1 = #(diff_group1);
                dbi_cntrl[1] = cnt1 > 10 ? 1 : 0;

                logic diff_group0;
                diff_group0 = data_in[19:0] xor prev_data[19:0];
                int cnt0 = #(diff_group0);
                dbi_cntrl[0] = cnt0 > 10 ? 1 : 0;

                if (dbi_cntrl[1]) data_out[39:20] = (~data_in[39:20]);
                else data_out[39:20] = data_in[39:20];

                if (dbi_cntrl[0]) data_out[19:0] = (~data_in[19:0]);
                else data_out[19:0] = data_in[19:0];
            end
        end
    end

endmodule

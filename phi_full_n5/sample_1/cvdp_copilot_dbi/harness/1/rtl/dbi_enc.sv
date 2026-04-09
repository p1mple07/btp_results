module dbi_enc(
    input [39:0] data_in,
    input clk,
    input rst_n,
    output reg [39:0] data_out,
    output reg [1:0] dbi_cntrl
);

    reg [39:0] prev_data_g1, prev_data_g0;

    initial begin
        dbi_cntrl <= 2'b00;
        data_out <= 40'h0000_0000;
        prev_data_g1 <= 40'h0000_0000;
        prev_data_g0 <= 40'h0000_0000;
    end

    always @(posedge clk) begin
        if (rst_n) begin
            prev_data_g1 <= 40'h0000_0000;
            prev_data_g0 <= 40'h0000_0000;
            data_out <= 40'h0000_0000;
            dbi_cntrl <= 2'b00;
        end else begin
            prev_data_g1 <= data_in[39:20];
            prev_data_g0 <= data_in[19:0];

            dbi_cntrl[1] = (data_in[39:20] != prev_data_g1) && (data_in[39:20] != 40'h0000_0000);
            dbi_cntrl[0] = (data_in[19:0] != prev_data_g0) && (data_in[19:0] != 40'h0000_0000);

            if (dbi_cntrl[1]) begin
                data_out[39:20] = ~data_in[39:20];
            end
            if (dbi_cntrl[0]) begin
                data_out[19:0] = ~data_in[19:0];
            end
        end
    end

endmodule

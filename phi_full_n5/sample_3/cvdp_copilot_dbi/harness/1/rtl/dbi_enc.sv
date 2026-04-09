module dbi_enc(
    input  [39:0] data_in,
    input  clk,
    input  rst_n,
    output reg [39:0] data_out,
    output reg [1:0] dbi_cntrl
);

    reg [20:0] prev_group1, prev_group0;

    // Initialization on reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 40'h00_0000_0000;
            dbi_cntrl <= 2'b00;
            prev_group1 <= 20'h0000_0000;
            prev_group0 <= 20'h0000_0000;
        end else begin
            prev_group1 <= prev_group1;
            prev_group0 <= prev_group0;
        end
    end

    // Comparison and output logic
    always @(posedge clk) begin
        if (!rst_n) begin
            prev_group1 <= 20'h0000_0000;
            prev_group0 <= 20'h0000_0000;
        end else begin
            if (data_in[39:20] != prev_group1) begin
                dbi_cntrl[1] = data_in[39:20] != prev_group1;
            end
            if (data_in[19:0] != prev_group0) begin
                dbi_cntrl[0] = data_in[19:0] != prev_group0;
            end

            prev_group1 <= data_in[39:20];
            prev_group0 <= data_in[19:0];

            case (dbi_cntrl)
                2'b01: data_out[39:20] = ~data_in[39:20];
                2'b10: data_out[19:0] = ~data_in[19:0];
                default: data_out = data_in;
            endcase
        end
    end

endmodule

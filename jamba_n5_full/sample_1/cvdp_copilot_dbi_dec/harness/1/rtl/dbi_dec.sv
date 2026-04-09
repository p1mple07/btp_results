module dbi_dec (
    input  wire        rst_n,
    input  wire        clk,
    input  wire [39:0] data_in,
    input  wire [1:0]  dbi_cntrl,
    output wire [39:0] data_out
);

    reg [39:0] group0, group1;
    reg [1:0] inv0, inv1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 40'b0;
            group0 <= 32'b0;
            group1 <= 32'b0;
            inv0 <= 32'b0;
            inv1 <= 32'b0;
        end else begin
            group0 <= data_in[39:20];
            group1 <= data_in[19:0];

            inv0 = dbi_cntrl[0] ? ~group0 : 32'b0;
            inv1 = dbi_cntrl[1] ? ~group1 : 32'b0;

            data_out = inv0 | inv1;
        end
    end

endmodule

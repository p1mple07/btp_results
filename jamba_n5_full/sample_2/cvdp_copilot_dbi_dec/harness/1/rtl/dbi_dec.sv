module dbi_dec (
    input  wire        rst_n,
    input  wire        clk,
    input  wire [39:0] data_in,
    input  wire [1:0] dbi_cntrl,
    output wire [39:0] data_out
);

    assign data_out = 40'b0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 40'b0;
        end else begin
            reg [39:20] group0, group1;
            assign group0 = data_in[39:20];
            assign group1 = data_in[19:0];

            if (dbi_cntrl[0]) group0 = ~group0;
            if (dbi_cntrl[1]) group1 = ~group1;

            data_out = group0 | group1;
        end
    end

endmodule

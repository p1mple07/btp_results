module dbi_dec (
    input  wire        rst_n,
    input  wire        clk,
    input  wire [39:0] data_in,
    input  wire [1:0] dbi_cntrl,
    output wire [39:0] data_out
);

    assign data_out = 40'b0;

    always @(posedge clk or posedge rst_n) begin
        if (rst_n)
            data_out <= 40'b0;
        else
        begin
            reg [19:0] group0, group1;

            group0 = data_in[39:20];
            group1 = data_in[19:0];

            group0 = ~dbi_cntrl[0] & group0;
            group1 = ~dbi_cntrl[1] & group1;

            data_out = group0 + group1;
        end
    end

endmodule

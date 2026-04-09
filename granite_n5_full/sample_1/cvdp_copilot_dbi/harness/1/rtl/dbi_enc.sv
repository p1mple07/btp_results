module dbi_enc(
    input wire [39:0] data_in,
    input wire clk,
    input wire rst_n,
    output reg [39:0] data_out,
    output reg [1:0] dbi_cntrl
);

reg [39:0] prev_data;
reg [19:0] group_1_inv;
reg [19:0] group_0_inv;
reg [19:0] group_1;
reg [19:0] group_0;
reg [19:0] diff_group_1;
reg [19:0] diff_group_0;

// Splitting incoming data
assign group_1 = data_in[39:20];
assign group_0 = data_in[19:0];

// Comparison with previous data
always @(posedge clk or posedge rst_n) begin
    if (!rst_n) begin
        prev_data <= 40'd0;
    end else begin
        prev_data <= data_out;
    end
end

// Control signal generation
assign diff_group_1 = group_1 ^ prev_data[39:20];
assign diff_group_0 = group_0 ^ prev_data[19:0];

assign dbi_cntrl[1] = |diff_group_1[19:10];
assign dbi_cntrl[0] = |diff_group_0[19:10];

// Generating data_out
always @* begin
    if (dbi_cntrl[1]) begin
        group_1_inv = ~group_1;
        data_out[39:20] = group_1_inv;
    end else begin
        data_out[39:20] = group_1;
    end

    if (dbi_cntrl[0]) begin
        group_0_inv = ~group_0;
        data_out[19:0] = group_0_inv;
    end else begin
        data_out[19:0] = group_0;
    end
end

endmodule
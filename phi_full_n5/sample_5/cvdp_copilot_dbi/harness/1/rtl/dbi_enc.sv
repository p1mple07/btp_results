module dbi_enc(
    input [39:0] data_in,
    input clk,
    input rst_n,
    output reg [39:0] data_out,
    output reg [1:0] dbi_cntrl
);

    reg [39:0] prev_data_group0, prev_data_group1;

    always @(posedge clk) begin
        if (rst_n) begin
            data_out <= 40'b0;
            dbi_cntrl <= 2'b00;
            prev_data_group0 <= 20'b0;
            prev_data_group1 <= 20'b0;
        end else begin
            prev_data_group0 <= prev_data_group0;
            prev_data_group1 <= prev_data_group1;

            // Split incoming data
            {prev_data_group0[39:20], prev_data_group1[39:20]} <= prev_data_group0[19:0];
            {data_in[39:20], data_in[19:0]} <= data_in;

            // Calculate differences
            int diff_group0 = |prev_data_group0 ^ data_in[19:0];
            int diff_group1 = |prev_data_group1 ^ data_in[39:20];

            // Determine control bits
            dbi_cntrl[1] <= (diff_group1 > 10);
            dbi_cntrl[0] <= (diff_group0 > 10);

            // Generate data_out
            if (dbi_cntrl[1]) begin
                data_out[39:20] <= ~data_in[39:20];
            end else begin
                data_out[39:20] <= data_in[39:20];
            end

            if (dbi_cntrl[0]) begin
                data_out[19:0] <= ~data_in[19:0];
            end else begin
                data_out[19:0] <= data_in[19:0];
            end

            // Update previous data
            prev_data_group0 <= data_out[39:20];
            prev_data_group1 <= data_out[19:0];
        end
    end
endmodule

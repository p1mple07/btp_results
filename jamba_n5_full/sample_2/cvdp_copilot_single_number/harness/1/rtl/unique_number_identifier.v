module unique_number_identifier #(
    parameter p_bit_width = 8,
    parameter p_max_numbers = 16
)(
    input wire i_clk,
    input wire i_rst_n,
    input wire i_ready,
    input wire [p_bit_width-1:0] i_number,
    output reg [p_bit_width-1:0] o_unique_number
);

reg [p_bit_width-1:0] prev_num;
reg cnt;
reg unique;

initial begin
    o_unique_number = 0;
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (i_rst_n) begin
        prev_num <= 0;
        cnt <= 0;
        unique <= 0;
    end else begin
        if (i_ready) begin
            if (i_number == prev_num) begin
                cnt++;
            end else begin
                prev_num <= i_number;
                cnt = 1;
                if (cnt == 1) unique <= i_number;
            end
        end
    end
end

always_ff @(posedge i_clk) begin
    if (i_ready && !i_rst_n) begin
        prev_num <= i_number;
        cnt = 1;
        unique <= i_number;
    end
end

endmodule

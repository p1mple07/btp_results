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
reg seen;
reg unique_candidate;

always @(posedge i_clk) begin
    if (i_rst_n) begin
        o_unique_number <= 0;
        prev_num <= 0;
        seen <= 0;
        unique_candidate <= 0;
    end else begin
        if (i_ready) begin
            if (i_number == prev_num) begin
                seen++;
                if (seen == 2) unique_candidate <= prev_num;
            end else begin
                prev_num <= i_number;
            end
        end
    end
end

always @(*) begin
    if (i_ready) begin
        if (seen == 2) begin
            o_unique_number <= unique_candidate;
        end else if (seen == 1) begin
            o_unique_number <= 0;
        end else begin
            o_unique_number <= 0;
        end
    end
end

endmodule

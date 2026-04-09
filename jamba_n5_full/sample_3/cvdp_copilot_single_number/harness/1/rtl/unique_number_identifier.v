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

reg [p_bit_width-1:0] seen[p_bit_width];
reg [3:0] unique_num;
reg [3:0] seen_index;

initial begin
    seen[:] = 0;
    unique_num = 0;
end

always @(posedge i_clk) begin
    if (i_rst_n) begin
        seen[:] = 0;
        unique_num = 0;
    end else begin
        if (i_ready) begin
            if (i_number != 0) begin
                seen_index = i_number;
                seen[seen_index] = 1;
                if (seen[seen_index] == 0)
                    unique_num = i_number;
            end
        end
    end
end

always @(*) begin
    o_unique_number = unique_num;
end

endmodule

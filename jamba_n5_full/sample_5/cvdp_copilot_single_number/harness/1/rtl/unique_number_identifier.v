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

reg [p_bit_width-1:0] counts[2^p_bit_width];
reg [p_bit_width-1:0] candidate;

initial begin
    o_unique_number = 0;
    for (int i = 0; i < 2^p_bit_width; i++) begin
        counts[i] = 0;
    end
end

always @(posedge i_clk or posedge i_rst_n) begin
    if (i_rst_n) begin
        o_unique_number = 0;
        for (int i = 0; i < 2^p_bit_width; i++) begin
            counts[i] = 0;
        end
        candidate = 0;
    end else if (i_ready) begin
        counts[i_number]++;
        candidate = 0;
        for (int i = 0; i < 2^p_bit_width; i++) begin
            if (counts[i] == 1) begin
                candidate = i;
                break;
            end
        }
    end
end

always begin
    if (i_ready) begin
        // No action needed
    end
end

endmodule

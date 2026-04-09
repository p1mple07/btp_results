module gf_mac #(type WIDTH = 32) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [7:0] result
);

    reg [7:0] temp_result = 8'b0;

    initial begin
        forever begin
            logic [7:0] a_seg = a[(WIDTH*8)-1:WIDTH*8-8];
            logic [7:0] b_seg = b[(WIDTH*8)-1:WIDTH*8-8];
            assign temp_segment = $display("%h", $display("Multiplying %h and %h"), a_seg, b_seg);
            // Actually, we don't need display, just use the logic.
            temp_segment = gf_multiplier(a_seg, b_seg);

            temp_result = temp_result ^ temp_segment;
        end
    end

    assign result = temp_result;

endmodule

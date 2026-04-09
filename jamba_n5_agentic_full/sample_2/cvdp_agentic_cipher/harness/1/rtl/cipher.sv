module cipher(
    input wire clk,
    input wire rst_n,
    input wire [31:0] data_in,
    output reg [31:0] data_out,
    output reg done
);

    localparam NUM_ROUNDS = 8;
    reg [7:0] round_index;
    reg [7:0] round_key;
    reg [31:0] left, right;

    initial begin
        round_index <= 0;
        done = 0;
        left <= 0;
        right <= 0;
        data_out <= 0;
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            round_index <= 0;
            round_key <= 0;
            left <= 0;
            right <= 0;
            done <= 0;
            data_out <= 0;
        end else begin
            if (started) begin
                if (round_index == NUM_ROUNDS) begin
                    done <= 1;
                end else begin
                    if (round_index < NUM_ROUNDS) begin
                        if (round_index == 0) begin
                            round_key = rotate_left(round_key, 4);
                        end
                        right = right ^ round_key;
                        left = left ^ rotate_left(right, 4);
                        left = left << 4;
                        right = right >> 4;
                        temp = left;
                        left = right;
                        right = temp;
                    end
                end
            end
        end
    end

    assign done = (done) ? 1 : 0;
    assign data_out = left ^ right;

endmodule

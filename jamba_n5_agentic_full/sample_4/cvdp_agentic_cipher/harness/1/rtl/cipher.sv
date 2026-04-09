module cipher(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [31:0] data_in,
    input logic [15:0] key,
    output logic [31:0] data_out,
    output logic done
);

    localparam NUM_ROUNDS = 8;
    reg [3:0] round_num;
    reg round_key;
    logic [15:0] left, right;
    logic [31:0] data_out_tmp;
    logic done_flag;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            round_num <= 0;
            round_key <= 0;
            left <= 32'd0;
            right <= 32'd0;
            data_out_tmp <= 0;
            done_flag <= 1'b1;
        end else if (start) begin
            round_num <= 0;
            round_key <= 0;
            left <= data_in[31:16];
            right <= data_in[0:15];
            data_out_tmp <= 0;
            done_flag <= 1'b0;
        end else begin
            round_num <= round_num + 1;
            // Generate round key: rotate key by round_num bits.
            round_key <= rotate_left(key, round_num);

            // Feistel processing: XOR right with round_key, then rotate
            // For simplicity, we do a dummy transformation.
            right <= right ^ round_key;  // XOR with round key
            // Rotate right half by some amount? Maybe not necessary.

            // Swap left and right for next round.
            data_out_tmp <= right;
            data_out <= data_out_tmp;
            done_flag <= 1'b1;
        end
    end

endmodule

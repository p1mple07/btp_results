module cipher #(
    parameter WIDTH = 32
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input logic [WIDTH-1:0] data_in,
    input logic [WIDTH-1:0] key,
    output reg data_out[WIDTH-1:0],
    output wire done
);

    localparam NUM_ROUNDS = 8;
    reg [NUM_ROUNDS:0] round_index;
    reg [31:0] left, right;
    reg [7:0] round_key;
    reg [7:0] subkey;
    reg [7:0] temp;
    logic done_flag;

    initial begin
        round_index = 0;
        left = data_in[WIDTH/2 - 1 : 0];
        right = data_in[WIDTH/2 : WIDTH-1];
        round_key = 0;
        subkey = 0;
        done_flag = 1'b0;
    end

    always_ff @(posedge clk) begin
        case (state)
            IDLE: begin
                if (start) begin
                    state <= ROUND;
                    done_flag = 1'b0;
                end
                end
            end

            ROUND: begin
                round_index <= round_index + 1;

                // Generate round key? Not needed here.

                // Apply round transformation: rotate right, XOR, rotate left.
                round_key = rotate_right(round_key, round_index * 4);
                subkey = rotate_right(subkey, round_index * 2);

                // Rotate right half
                right = rotate_left(right, round_index);
                right = rotate_right(right, 4);
                right = xor(right, round_key);

                // Left half XOR with right, swap
                left = xor(left, right);
                left = rotate_right(left, round_index);
                left = rotate_left(left, 4);

                // Assign output
                data_out = {left, right};
                done_flag = 1'b1;

                if (round_index == NUM_ROUNDS - 1) begin
                    state <= FINISH;
                end else begin
                    state <= ROUND;
                end
            end

            FINISH: begin
                state <= IDLE;
                done <= 1'b1;
            end

        endcase
    end

    assign done = done_flag;

endmodule

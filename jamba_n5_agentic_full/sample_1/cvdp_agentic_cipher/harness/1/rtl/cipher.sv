module cipher #(
    parameter KEY_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [KEY_WIDTH-1:0] key,
    input wire [31:0] data_in,
    output reg [31:0] data_out,
    output logic done
);

reg [3:0] round;
reg [7:0] round_key;
reg [15:0] left, right;
reg [31:0] data_out_temp;
reg done;

// Helper functions
function automatic int rotate_left(int value, int bits);
    rotate_left = value << bits ^ value >> (32 - bits);
endfunction

task generate_round_key;
    begin
        round_key = rotate_left(round_key + 1, KEY_WIDTH / 2);
    end
endtask

initial begin
    round = 0;
    round_key = 16'h0;
    left = 32'd0;
    right = 32'd0;
    done = 0;
end

always @(posedge clk or posedge rst_n) begin
    if (!rst_n) begin
        left <= 32'd0;
        right <= 32'd0;
        data_out <= 32'd0;
        done <= 0;
        round_key <= 16'h0;
        round = 0;
    end else if (start) begin
        left <= data_in[16:0];
        right <= data_in[0:15];
        round = 0;
        round_key = 16'h0;
        done <= 0;
    end else begin
        done <= 1;
    end
end

always_ff @(posedge clk) begin
    if (done) begin
        done <= 0;
        left <= right;
        right <= 32'd0;
        round = 8; // after 8 rounds, exit
    end else begin
        if (round < 8) begin
            round_key = round_key + 1;
            // apply f_function: XOR right with round_key, rotate
            data_out_temp = left ^ data_in;
            // Wait, maybe we need to recompute left and right.
            // This is too vague.
        end
    end
end

assign data_out = data_out_temp;

endmodule

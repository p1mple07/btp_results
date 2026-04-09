module cipher (
    input clk,
    input rst_n,
    input start,
    input [31:0] data_in,
    input [15:0] key,
    output reg [31:0] data_out,
    output wire done
);

localparam NUM_ROUNDS = 8;

always_ff @(posedge clk) begin
    if (!rst_n) begin
        data_out <= 32'd0;
        done <= 1;
        state <= IDLE;
    end else if (start) begin
        state <= ROUND;
    end else begin
        state <= FINISH;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        round_idx <= 0;
        data_out <= 32'd0;
        done <= 1;
        state <= IDLE;
    end
end

case (state)
    IDLE: begin
        if (start) begin
            state <= ROUND;
        end
    end

    ROUND: begin
        localvar left = {[31:16] data_in[31]};
        localvar right = {[31:16] data_in[15]};

        right = right >> 4;
        right = right | ((~right) << 28);

        localvar new_left = left ^ right;

        left <= right;
        right <= new_left;

        done <= 1;
    end

    FINISH: begin
        state <= IDLE;
    end
endcase

endmodule

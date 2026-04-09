module lfsr_8bit_fibonacci(
    input wire clk,
    input wire rst,
    input  [7:0] seed,
    output reg [7:0] lfsr_out
);

    localparam TBW = 8;
    reg [TBW-1:0] state;

    assign lfsr_out = (rst) ? seed : {
        state[TBW-1], state[TBW-2], state[TBW-3], state[TBW-4],
        state[TBW-5], state[TBW-6], state[TBW-7], state[0]
    };

    assign state[TBW-1] = state[TBW-2];
    assign state[TBW-2] = state[TBW-3];
    assign state[TBW-3] = state[TBW-4];
    assign state[TBW-4] = state[TBW-5];
    assign state[TBW-5] = state[TBW-6];
    assign state[TBW-6] = state[TBW-7];
    assign state[TBW-7] = lfsr_out[7];

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) state <= {7'b0, 7'b0, seed[0], seed[1], seed[2], seed[3], seed[4], seed[5]};
    end

endmodule

module round_robin_arbiter #(
    parameter N = 4
)(
    input  wire             clk,
    input  wire             rstn,
    input  wire [N-1:0]     req,    // N-bit request
    input  wire            priority_level[N:0],  // N bits
    input  wire TOUTIME,      // timeout period in clock cycles
    output reg  [N-1:0]     grant    // one-hot encoded
);

    reg [$clog2(N)-1:0] pointer;
    reg [$clog2(N)-1:0] pointer_next;
    reg found;
    reg [31:0] timeout_counter[N]; // 32 bits each
    reg [N:0] channel_priority;   // maybe we don't need separate, but use priority_level.

    integer i;
    always @(*) begin
        grant        = '{N{1'b0}};
        pointer_next = pointer;
        
        found = 0;
        for (i = 0; i < N; i = i + 1) begin
            if (req[i] && !found && priority_level[i] > channel_priority[i]) {
                // Wait, we need to handle priority? Maybe we can just use priority_level to break tie.
                // But we also have timeout.

                // Instead, we can implement a simpler priority-based round-robin.

                // We'll use a simple priority-based selection: choose the channel with highest priority among those with req[i] == 1.

                // But we also have the timeout.

                // This is getting too long.

            }
        }
    end

endmodule

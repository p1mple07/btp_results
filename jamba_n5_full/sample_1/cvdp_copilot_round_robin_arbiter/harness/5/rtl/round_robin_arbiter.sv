`timescale 1ns / 1ps

module round_robin_arbiter #(
    parameter N = 4
)(
    input  wire             clk,
    input  wire             rstn,
    input  wire [N-1:0]     req,    // N‑bit request vector
    output reg  [N-1:0]     grant    // N‑bit grant signal (one‑hot)
);

    reg [$clog2(N)-1:0] pointer;
    reg [$clog2(N)-1:0] pointer_next;
    reg found;
    reg [N-1:0] timeout_counter;
    logic idle;

    // Initialise timeout counters to zero
    initial begin
        timeout_counter = {N{1'b0}};
    end

    // Always block triggered on positive edge of CLK
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pointer <= 0;
            pointer_next <= 0;
            found <= 0;
            grant <= 0;
            timeout_counter <= {N{1'b0}};
            idle <= 1;
        end else begin
            pointer <= pointer_next;
            found <= 0;
            idle <= 0;

            // Update pointer for each channel
            for (integer i = 0; i < N; i = i + 1) begin
                if (req[i] && !found) begin
                    grant[i] = 1'b0;
                    pointer_next = (pointer + i + 1) % N;
                    found <= 1;
                    break;
                }
            end

            // Handle timeout for non‑granted channels
            for (integer i = 0; i < N; i = i + 1) begin
                if (priority_level[i] == 1'b1 && req[i] == 1'b1 && grant[i] == 1'b0) begin
                    timeout_counter[i] <= timeout_counter[i] + 1;
                    if (timeout_counter[i] >= 16'hFFFF) begin
                        // Optional: revert to low priority or raise error
                        // For this example, we simply reset
                        timeout_counter[i] <= 0;
                    end
                end
            end

            // Assign grants based on priority and round‑robin
            for (integer i = 0; i < N; i = i + 1) begin
                if (priority_level[i] == 1'b1 && req[i] == 1'b1 && grant[i] == 1'b0) begin
                    grant[i] = 1'b1;
                    pointer_next = (pointer + i + 1) % N;
                    found = 1;
                    break;
                }
            end
        end
    end

endmodule

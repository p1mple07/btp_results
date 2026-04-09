
module round_robin_arbiter #(
    parameter N = 4
)(
    input  wire             clk,
    input  wire             rstn,
    input  wire [N-1:0]     req,
    input  wire [N-1:0]     priority_level,
    output reg  [N-1:0]     grant,
    output reg  idle
);

    reg [$clog2(N)-1:0] pointer;
    reg [$clog2(N)-1:0] pointer_next;
    reg found;
    reg [31:0] timeout_counter[0:N-1]; // Timeout counters for each channel

    integer i;

    // Timeout mechanism
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pointer <= 0;
            timeout_counter <= 32'd0; // Reset timeout counters
        end else begin
            if (timeout_counter[N-1] >= TIMEOUT) begin
                // Temporarily elevate priority for timeout handling
                priority_level <= priority_level + 1;
                // Grant the request that has been waiting longest
                for (i = 0; i < N; i = i + 1) begin
                    if (!found && req[(pointer + i) % N] == 1'b1 && priority_level[(pointer + i) % N] == 1'b1) begin
                        grant[(pointer + i) % N] = 1'b1;
                        pointer_next = (pointer + i + 1) % N;
                        found = 1'b1;
                        break;
                    end
                end
            end else begin
                // Regular arbiter logic
                if (req != 0) begin
                    found = 1'b0;
                    for (i = 0; i < N; i = i + 1) begin
                        if (!found && req[(pointer + i) % N] == 1'b1) begin
                            grant[(pointer + i) % N] = 1'b1;
                            pointer_next = (pointer + i + 1) % N;
                            found = 1'b1;
                            break;
                        end
                    end
                end
            end
        end
    end

    // Idle signal logic
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            idle <= 1;
        end else begin
            if (req == 0) begin
                idle <= 1;
            end else begin
                idle <= 0;
            end
        end
    end

endmodule

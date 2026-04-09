module round_robin_arbiter #(
    parameter N        = 4,
    parameter TIMEOUT  = 16  // Timeout in clock cycles for low-priority channels
)(
    input  wire             clk,
    input  wire             rstn,
    input  wire [N-1:0]     req,           
    input  wire [N-1:0]     priority_level, // 1 = high priority, 0 = low priority
    output reg  [N-1:0]     grant,         
    output reg              idle            // 1: no active requests; 0: at least one request active
);

    // Pointer for round-robin ordering
    reg [$clog2(N)-1:0] pointer;
    reg [$clog2(N)-1:0] pointer_next;
    reg found;
    // Register to hold the index of the granted channel (used for updating timeout counters)
    reg [$clog2(N)-1:0] granted_channel;

    // Timeout counters for each channel (32 bits each)
    reg [31:0] timeout_counter [0:N-1];

    // ---------------------------------------------------------------------
    // Combinational Logic: Determine grant signal and update pointer_next.
    // Effective priority is defined as:
    //   - A channel is considered high priority if either its input priority is 1,
    //     OR it is low priority (0) but its timeout counter has reached or exceeded TIMEOUT.
    // The arbiter first searches for any active request with effective high priority,
    // starting from the current pointer. If none is found, it falls back to normal round-robin.
    // ---------------------------------------------------------------------
    always @(*) begin
        grant        = {N{1'b0}};
        pointer_next = pointer;
        found        = 1'b0;
        granted_channel = pointer;  // default value

        if (req != 0) begin
            // First pass: Look for active channels with effective high priority.
            integer j;
            for (j = 0; j < N; j = j + 1) begin
                integer idx = (pointer + j) % N;
                if (req[idx] &&
                    ((priority_level[idx] == 1) || 
                     ((priority_level[idx] == 0) && (timeout_counter[idx] >= TIMEOUT)))
                   ) begin
                    grant[idx]       = 1'b1;
                    pointer_next     = (idx + 1) % N;
                    granted_channel  = idx;
                    found            = 1'b1;
                    break;
                end
            end

            // Second pass: If no effective high priority request was found,
            // grant the first active request in round-robin order.
            if (!found) begin
                for (j = 0; j < N; j = j + 1) begin
                    integer idx = (pointer + j) % N;
                    if (req[idx]) begin
                        grant[idx]       = 1'b1;
                        pointer_next     = (idx + 1) % N;
                        granted_channel  = idx;
                        found            = 1'b1;
                        break;
                    end
                end
            end
        end
    end

    // ---------------------------------------------------------------------
    // Sequential Logic: Update pointer and timeout counters.
    // - The pointer is updated with pointer_next.
    // - For each channel:
    //     * If its request is removed, its timeout counter is reset.
    //     * If it is granted, its timeout counter is reset.
    //     * If it is active, low-priority, and not granted, its timeout counter increments.
    // High-priority channels (priority_level == 1) do not count timeouts.
    // ---------------------------------------------------------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pointer <= 0;
            integer k;
            for (k = 0; k < N; k = k + 1)
                timeout_counter[k] <= 32'd0;
        end else begin
            // Update round-robin pointer.
            pointer <= pointer_next;

            // Update timeout counters for each channel.
            integer k;
            for (k = 0; k < N; k = k + 1) begin
                if (!req[k]) begin
                    // Request removed: reset timeout counter.
                    timeout_counter[k] <= 32'd0;
                end else if (grant[k]) begin
                    // Request granted: reset timeout counter.
                    timeout_counter[k] <= 32'd0;
                end else if (priority_level[k] == 0) begin
                    // Low-priority channel waiting: increment timeout counter.
                    timeout_counter[k] <= timeout_counter[k] + 1;
                end
                // For high-priority channels (priority_level == 1), no timeout counter update.
            end
        end
    end

    // ---------------------------------------------------------------------
    // Combinational Logic: Determine idle signal.
    // idle = 1 if there are no active requests; otherwise, idle = 0.
    // ---------------------------------------------------------------------
    always @(*) begin
        if (req == 0)
            idle = 1'b1;
        else
            idle = 1'b0;
    end

endmodule
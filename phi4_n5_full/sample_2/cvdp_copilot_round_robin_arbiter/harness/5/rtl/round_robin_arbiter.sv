module round_robin_arbiter #(
    parameter N       = 4,
    parameter TIMEOUT = 16
)(
    input  wire             clk,
    input  wire             rstn,
    input  wire [N-1:0]     req,
    input  wire [N-1:0]     priority_level,
    output reg  [N-1:0]     grant,
    output wire             idle
);

    // Pointer used for round-robin arbitration
    reg [$clog2(N)-1:0] pointer;
    reg [$clog2(N)-1:0] pointer_next;
    reg found;
    reg [N-1:0] grant_comb;

    // Timeout counters for each channel (assumes N=4)
    reg [31:0] timeout_counter0;
    reg [31:0] timeout_counter1;
    reg [31:0] timeout_counter2;
    reg [31:0] timeout_counter3;

    // Function to return the timeout counter for a given channel index
    function automatic [31:0] get_timeout;
        input integer index;
        case(index)
            0: get_timeout = timeout_counter0;
            1: get_timeout = timeout_counter1;
            2: get_timeout = timeout_counter2;
            3: get_timeout = timeout_counter3;
            default: get_timeout = 32'd0;
        endcase
    endfunction

    // Combinational logic to determine the grant signal and update pointer_next.
    // Arbitration passes:
    // 1. Grant any active channel that is either high-priority by input or low-priority
    //    that has timed out (timeout_counter >= TIMEOUT).
    // 2. If none found, grant an active low-priority channel that has not yet timed out.
    // 3. Otherwise, leave grant as 0.
    integer i;
    always @(*) begin
        grant_comb = {N{1'b0}};
        pointer_next = pointer;
        found = 1'b0;
        
        // First pass: Check for high effective priority channels.
        for (i = 0; i < N; i = i + 1) begin
            integer index;
            index = (pointer + i) % N;
            if (req[index] &&
                ((priority_level[index] == 1) ||
                 ((priority_level[index] == 0) && (get_timeout(index) >= TIMEOUT)))) begin
                grant_comb[index] = 1'b1;
                pointer_next = (index + 1) % N;
                found = 1'b1;
                disable for;
            end
        end

        if (!found) begin
            // Second pass: Check for active low-priority channels that have not timed out.
            for (i = 0; i < N; i = i + 1) begin
                integer index;
                index = (pointer + i) % N;
                if (req[index] &&
                    (priority_level[index] == 0) &&
                    (get_timeout(index) < TIMEOUT)) begin
                    grant_comb[index] = 1'b1;
                    pointer_next = (index + 1) % N;
                    found = 1'b1;
                    disable for;
                end
            end
        end

        // Third pass: If no grant is found (e.g. no active requests), grant_comb remains 0.
    end

    // Sequential block: update pointer and timeout counters.
    // For each channel, if its request is active and it was not granted in this cycle,
    // increment its timeout counter; otherwise, reset the counter to 0.
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pointer         <= 0;
            timeout_counter0 <= 32'd0;
            timeout_counter1 <= 32'd0;
            timeout_counter2 <= 32'd0;
            timeout_counter3 <= 32'd0;
        end else begin
            pointer <= pointer_next;

            // Channel 0
            if (req[0] && !grant_comb[0])
                timeout_counter0 <= timeout_counter0 + 1;
            else
                timeout_counter0 <= 32'd0;

            // Channel 1
            if (req[1] && !grant_comb[1])
                timeout_counter1 <= timeout_counter1 + 1;
            else
                timeout_counter1 <= 32'd0;

            // Channel 2
            if (req[2] && !grant_comb[2])
                timeout_counter2 <= timeout_counter2 + 1;
            else
                timeout_counter2 <= 32'd0;

            // Channel 3
            if (req[3] && !grant_comb[3])
                timeout_counter3 <= timeout_counter3 + 1;
            else
                timeout_counter3 <= 32'd0;
        end
    end

    // Drive the registered grant output with the combinational grant decision.
    always @(*) begin
        grant = grant_comb;
    end

    // Idle signal: 1 indicates no active requests; 0 indicates one or more active requests.
    assign idle = ~|req;

endmodule
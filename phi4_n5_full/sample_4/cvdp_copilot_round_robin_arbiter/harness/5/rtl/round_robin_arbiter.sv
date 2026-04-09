module round_robin_arbiter #(
    parameter N = 4,
    parameter TIMEOUT = 16
)(
    input  wire             clk,
    input  wire             rstn,
    input  wire [N-1:0]     req,           
    input  wire [N-1:0]     priority_level, // 1 = high priority, 0 = low priority
    output reg  [N-1:0]     grant,
    output wire            idle
);

    // Pointer for round-robin scheduling
    reg [$clog2(N)-1:0] pointer;
    reg [$clog2(N)-1:0] pointer_next;

    // Timeout counters for each channel (assumes N==4)
    reg [31:0] timeout_counter0;
    reg [31:0] timeout_counter1;
    reg [31:0] timeout_counter2;
    reg [31:0] timeout_counter3;

    // Effective priority wires: a channel is considered high priority if either
    // its input priority is 1 OR its timeout counter has reached TIMEOUT.
    wire high_priority0 = priority_level[0] | (timeout_counter0 == TIMEOUT);
    wire high_priority1 = priority_level[1] | (timeout_counter1 == TIMEOUT);
    wire high_priority2 = priority_level[2] | (timeout_counter2 == TIMEOUT);
    wire high_priority3 = priority_level[3] | (timeout_counter3 == TIMEOUT);

    // Combinational always block to determine grant and update pointer_next.
    // It first searches for a high-priority request in round-robin order.
    // If none is found, it then checks for low-priority requests.
    always @(*) begin
        grant        = {N{1'b0}};
        pointer_next = pointer;
        
        if (req != 0) begin
            integer i;
            // First pass: Look for high-priority requests.
            for (i = 0; i < N; i = i + 1) begin
                reg [$clog2(N)-1:0] candidate;
                if ((pointer + i) < N)
                    candidate = pointer + i;
                else
                    candidate = pointer + i - N;
                
                if (req[candidate] == 1) begin
                    case (candidate)
                        0: if (high_priority0) begin
                               grant[0] = 1;
                               pointer_next = (0 == (N-1)) ? 0 : 0 + 1;
                               break;
                           end
                        1: if (high_priority1) begin
                               grant[1] = 1;
                               pointer_next = (1 == (N-1)) ? 0 : 1 + 1;
                               break;
                           end
                        2: if (high_priority2) begin
                               grant[2] = 1;
                               pointer_next = (2 == (N-1)) ? 0 : 2 + 1;
                               break;
                           end
                        3: if (high_priority3) begin
                               grant[3] = 1;
                               pointer_next = (3 == (N-1)) ? 0 : 3 + 1;
                               break;
                           end
                    endcase
                end
            end

            // Second pass: If no high-priority grant was found, check low-priority requests.
            if (grant == {N{1'b0}}) begin
                for (i = 0; i < N; i = i + 1) begin
                    reg [$clog2(N)-1:0] candidate;
                    if ((pointer + i) < N)
                        candidate = pointer + i;
                    else
                        candidate = pointer + i - N;
                    
                    if (req[candidate] == 1) begin
                        case (candidate)
                            0: if (!priority_level[0] && timeout_counter0 < TIMEOUT) begin
                                   grant[0] = 1;
                                   pointer_next = (0 == (N-1)) ? 0 : 0 + 1;
                                   break;
                               end
                            1: if (!priority_level[1] && timeout_counter1 < TIMEOUT) begin
                                   grant[1] = 1;
                                   pointer_next = (1 == (N-1)) ? 0 : 1 + 1;
                                   break;
                               end
                            2: if (!priority_level[2] && timeout_counter2 < TIMEOUT) begin
                                   grant[2] = 1;
                                   pointer_next = (2 == (N-1)) ? 0 : 2 + 1;
                                   break;
                               end
                            3: if (!priority_level[3] && timeout_counter3 < TIMEOUT) begin
                                   grant[3] = 1;
                                   pointer_next = (3 == (N-1)) ? 0 : 3 + 1;
                                   break;
                               end
                        endcase
                    end
                end
            end
        end
    end

    // Sequential block to update the pointer.
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            pointer <= 0;
        else
            pointer <= pointer_next;
    end

    // Sequential block to update the timeout counters.
    // For each channel, if a request is active and the channel is low priority,
    // increment its timeout counter (up to TIMEOUT). If the channel is granted or
    // its request is removed, reset the counter.
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            timeout_counter0 <= 0;
            timeout_counter1 <= 0;
            timeout_counter2 <= 0;
            timeout_counter3 <= 0;
        end else begin
            // Channel 0
            if (grant[0] == 1)
                timeout_counter0 <= 0;
            else if (req[0] == 1) begin
                if (priority_level[0] == 0)
                    timeout_counter0 <= (timeout_counter0 < TIMEOUT) ? timeout_counter0 + 1 : TIMEOUT;
                else
                    timeout_counter0 <= 0;
            end else
                timeout_counter0 <= 0;
            
            // Channel 1
            if (grant[1] == 1)
                timeout_counter1 <= 0;
            else if (req[1] == 1) begin
                if (priority_level[1] == 0)
                    timeout_counter1 <= (timeout_counter1 < TIMEOUT) ? timeout_counter1 + 1 : TIMEOUT;
                else
                    timeout_counter1 <= 0;
            end else
                timeout_counter1 <= 0;
            
            // Channel 2
            if (grant[2] == 1)
                timeout_counter2 <= 0;
            else if (req[2] == 1) begin
                if (priority_level[2] == 0)
                    timeout_counter2 <= (timeout_counter2 < TIMEOUT) ? timeout_counter2 + 1 : TIMEOUT;
                else
                    timeout_counter2 <= 0;
            end else
                timeout_counter2 <= 0;
            
            // Channel 3
            if (grant[3] == 1)
                timeout_counter3 <= 0;
            else if (req[3] == 1) begin
                if (priority_level[3] == 0)
                    timeout_counter3 <= (timeout_counter3 < TIMEOUT) ? timeout_counter3 + 1 : TIMEOUT;
                else
                    timeout_counter3 <= 0;
            end else
                timeout_counter3 <= 0;
        end
    end

    // Idle signal: 1 when no requests are active.
    assign idle = ~(|req);

endmodule
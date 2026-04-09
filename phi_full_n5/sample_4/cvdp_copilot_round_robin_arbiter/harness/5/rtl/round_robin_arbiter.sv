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
    
    integer i;
    reg [31:0] timeout_counter[0:N-1];

    // Initialize timeout counters to 0
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            timeout_counter <= 32'h0;
        end else begin
            for (i = 0; i < N; i = i + 1) begin
                timeout_counter[i] <= 32'h0;
            end
        end
    end

    always @(*) begin
        grant        = 32'h0;
        pointer_next = pointer;
        
        // Priority handling
        found = 1'b0;
        for (i = 0; i < N; i = i + 1) begin
            if (!found && req[(pointer + i) % N] == 1'b1 && priority_level[(pointer + i) % N] == 1'b1) begin
                grant[(pointer + i) % N] = 1'b1;
                pointer_next = (pointer + i + 1) % N;
                found        = 1'b1;                    
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pointer <= 0;
        end else begin
            // Temporarily elevate priority for timeout
            if (timeout_counter > TIMEOUT) begin
                for (i = 0; i < N; i = i + 1) begin
                    if (priority_level[i] == 1'b1) begin
                        pointer_next = (i + 1) % N; // Temporarily elevate next high-priority channel
                        timeout_counter[i] <= 0; // Reset timeout counter
                    end
                end
            end else begin
                pointer <= pointer_next;
            end
        end
    end

    // Idle signal
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            idle <= 1'b0;
        end else begin
            idle <= !(req == 32'h0);
        end
    end

endmodule

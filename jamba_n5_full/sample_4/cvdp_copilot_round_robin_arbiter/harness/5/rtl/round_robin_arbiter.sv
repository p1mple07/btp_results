module round_robin_arbiter #(
    parameter N = 4,
    parameter TIMEOUT = 16,
    parameter PRIORITY_LEVEL = 4'd0000
) (
    input  wire             clk,
    input  wire             rstn,
    input  wire [N-1:0]     req,   
    output reg  [N-1:0]     grant   
);

    reg [$clog2(N)-1:0] pointer;
    reg [$clog2(N)-1:0] pointer_next;
    reg found;
    reg [N-1:0] current_grant;
    reg [N-1:0] timeout_counter[N];

    integer i;

    // Priority handling
    always @(*) begin
        grant        = {N{1'b0}};
        pointer_next = pointer;
        
        if (req != 0) begin
            found = 1'b0;
            for (i = 0; i < N; i = i + 1) begin
                if (priority_level[i] & 1) begin
                    if (!found && req[(pointer + i) % N] == 1'b1) begin
                        grant[(pointer + i) % N] = 1'b1;
                        pointer_next = (pointer + i + 1) % N;
                        found = 1'b1;
                    end
                end else begin
                    if (!found && req[(pointer + i) % N] == 1'b1) begin
                        grant[(pointer + i) % N] = 1'b1;
                        pointer_next = (pointer + i + 1) % N;
                        found = 1'b0;
                    end
                end
            end
        end
    end

    // Timeout counter
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pointer <= 0;
            timeout_counter[0] = 0;
            timeout_counter[1] = 0;
            timeout_counter[2] = 0;
            timeout_counter[3] = 0;
        end else begin
            for (i = 0; i < N; i = i + 1) begin
                if (timeout_counter[i] > 0) begin
                    timeout_counter[i] = timeout_counter[i] - 1;
                    if (timeout_counter[i] == 0) begin
                        grant[i] = 1'b1;
                        pointer_next = (i + 1) % N;
                        found = 1'b1;
                    end
                end
            end
        end
    end

    // Grant output
    assign grant = {{N{1'b0}}} | {N{1'b1}} ? {N{1'b1}} : 0;

    // Idle detection
    always @(*) begin
        idle = ~any(req);
    end

endmodule

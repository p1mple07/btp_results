module round_robin_arbiter #(
    parameter N = 4,
    parameter TIMEOUT = 16
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
    reg [TIMEOUT-1:0] timeout_counter[0:N-1];
    reg found;
    
    integer i;

    always @(*) begin
        grant        = {N{1'b0}};
        pointer_next = pointer;
        
        for (i = 0; i < N; i = i + 1) begin
            if (!found && req[(pointer + i) % N] == 1'b1) begin
                if (priority_level[(pointer + i) % N] == 1'b1) begin
                    grant[(pointer + i) % N] = 1'b1;
                    timeout_counter[(pointer + i) % N] = TIMEOUT;
                    pointer_next = (pointer + i + 1) % N;
                    found        = 1'b1;
                end else begin
                    timeout_counter[(pointer + i) % N] = timeout_counter[(pointer + i) % N] + 1'b1;
                end
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pointer <= 0;
            timeout_counter <= {N{TIMEOUT{1'b0}}};
            idle <= 1;
        end else begin
            pointer <= pointer_next;
            for (i = 0; i < N; i = i + 1) begin
                if (timeout_counter[i] > TIMEOUT) begin
                    timeout_counter[i] <= 0;
                    priority_level[i] <= 1'b1;
                    if (!found) begin
                        found = 1'b1;
                        grant[(pointer + i) % N] = 1'b1;
                    end
                end
            end
            if (found == 1'b1) begin
                idle <= 0;
            end else begin
                idle <= 1;
            end
        end
    end

endmodule

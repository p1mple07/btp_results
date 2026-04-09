module round_robin_arbiter #(
    parameter N = 4
)(
    input  wire             clk,
    input  wire             rstn,
    input  wire [N-1:0]     req,   
    input  wire [N-1:0]     priority_level,
    output reg  [N-1:0]     grant   
);

    reg [$clog2(N)-1:0] pointer;
    reg [$clog2(N)-1:0] pointer_next;
    reg found;
    reg idle = 1'b0;
    
    reg [N-1:0] timeout_counter;
    integer i;
    integer t;
    always @(*) begin
        if (rstn) begin
            pointer <= 0;
            pointer_next <= 0;
            found = 0;
            timeout_counter = 0;
        end else begin
            if (req == 0) begin
                idle = 1;
                grant = 0;
            else begin
                found = 0;
                timeout_counter = 0;
                for (i = 0; i < N; i = i + 1) begin
                    if (priority_level[i] & 1) begin
                        if (!found && req[(pointer + i) % N] == 1'b1) begin
                            grant[(pointer + i) % N] = 1'b1;
                            pointer_next = (pointer + i + 1) % N;
                            found = 1;
                            t = (pointer + i) % N;
                            timeout_counter[t] = 0;
                            break;
                        end
                    end else begin
                        if (timeout_counter[(pointer + i) % N] >= TIMEOUT) begin
                            priority_level[(pointer + i) % N] = 4'b1000;
                        end
                        if (!found && req[(pointer + i) % N] == 1'b1) begin
                            grant[(pointer + i) % N] = 1'b1;
                            pointer_next = (pointer + i + 1) % N;
                            found = 1;
                            t = (pointer + i) % N;
                            timeout_counter[t] = 0;
                            break;
                        end
                    end
                end
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pointer <= 0;
        end else begin
            pointer <= pointer_next;
        end
    end

    // Timeout handling
    always begin
        if (!rstn && found) begin
            for (t = 0; t < N; t = t + 1) begin
                if (timeout_counter[t] >= TIMEOUT) begin
                    priority_level[t] = 4'b1000;
                    break;
                end
            end
        end
    end
endmodule
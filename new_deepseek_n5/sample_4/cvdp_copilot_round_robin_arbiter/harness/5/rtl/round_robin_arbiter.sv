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
    reg [N-1:0] timeout_counter;

    integer i;
    always @(*) begin
        grant        = {N{1'b0}};
        pointer_next = pointer;
        timeout_counter = {N{32'h0}};

        if (req != 0) begin
            found = 1'b0;
            for (i = 0; i < N; i = i + 1) begin
                if (priority_level[i] & 1) begin
                    if (!found && req[(pointer + i) % N] == 1'b1) begin
                        grant[(pointer + i) % N] = 1'b1;
                        pointer_next = (pointer + i + 1) % N;
                        found        = 1'b1;
                        timeout_counter[(pointer + i) % N] = 32'h0;
                    end
                    else if (timeout_counter[(pointer + i) % N] >= TIMEOUT) begin
                        grant[(pointer + i) % N] = 1'b1;
                        pointer_next = (pointer + i + 1) % N;
                        found        = 1'b1;
                        timeout_counter[(pointer + i) % N] = 32'h0;
                    end
                end
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pointer <= 0;
            timeout_counter <= {N{32'h0}};
        end else begin
            pointer <= pointer_next;
        end
    end

    output reg idle = 1'b0;
endmodule
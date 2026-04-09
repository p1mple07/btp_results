module round_robin_arbiter #(
    parameter N = 4
    parameter TIMEOUT = 16
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
    reg [N-1:0] idle;
    reg elevator_priority;
    reg [N-1:0] timeout_counter0;
    reg [N-1:0] timeout_counter1;
    reg [N-1:0] timeout_counter2;
    reg [N-1:0] timeout_counter3;
    
    integer i;
    always @(*) begin
        grant        = {N{1'b0}};
        pointer_next = pointer;
        elevator_priority = 0;

        if (req != 0) begin
            found = 1'b0;
            for (i = 0; i < N; i = i + 1) begin
                if (!found && (priority_level[i] & req[pointer + i] & req[(pointer + i) % N])) begin
                    grant[(pointer + i) % N] = 1'b1;
                    pointer_next = (pointer + i + 1) % N;
                    found        = 1'b1;
                end
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pointer <= 0;
            elevator_priority <= 0;
        end else begin
            pointer <= pointer_next;
        end
    end

    always @posedge clk begin
        if (rstn) begin
            timeout_counter0 <= 0;
            timeout_counter1 <= 0;
            timeout_counter2 <= 0;
            timeout_counter3 <= 0;
            elevator_priority <= 0;
        end else begin
            if (req[0]) begin
                timeout_counter0 <= 0;
            end else begin
                timeout_counter0 <= timeout_counter0 + 1;
            end

            if (req[1]) begin
                timeout_counter1 <= 0;
            end else begin
                timeout_counter1 <= timeout_counter1 + 1;
            end

            if (req[2]) begin
                timeout_counter2 <= 0;
            end else begin
                timeout_counter2 <= timeout_counter2 + 1;
            end

            if (req[3]) begin
                timeout_counter3 <= 0;
            end else begin
                timeout_counter3 <= timeout_counter3 + 1;
            end

            if (elevator_priority == 0) begin
                if (timeout_counter0 >= TIMEOUT) begin
                    elevator_priority <= 1;
                    grant[0] = 1'b1;
                    timeout_counter0 <= 0;
                end
                if (timeout_counter1 >= TIMEOUT) begin
                    elevator_priority <= 2;
                    grant[1] = 1'b1;
                    timeout_counter1 <= 0;
                end
                if (timeout_counter2 >= TIMEOUT) begin
                    elevator_priority <= 3;
                    grant[2] = 1'b1;
                    timeout_counter2 <= 0;
                end
                if (timeout_counter3 >= TIMEOUT) begin
                    elevator_priority <= 4;
                    grant[3] = 1'b1;
                    timeout_counter3 <= 0;
                end
            end
        end
    end

    always @negedge rstn begin
        timeout_counter0 <= 0;
        timeout_counter1 <= 0;
        timeout_counter2 <= 0;
        timeout_counter3 <= 0;
        elevator_priority <= 0;
    end

    // Idle signal
    if (req[0] == 0 && req[1] == 0 && req[2] == 0 && req[3] == 0) begin
        idle = 1'b1;
    else begin
        idle = 1'b0;
    end
    end

endmodule
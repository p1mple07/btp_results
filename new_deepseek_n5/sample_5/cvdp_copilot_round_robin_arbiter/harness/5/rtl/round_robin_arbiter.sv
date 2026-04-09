module round_robin_arbiter #(
    parameter N = 4
    parameter TIMEOUT = 16
)(
    input  wire             clk,
    input  wire             rstn,
    input  wire [N-1:0]     req,   
    input  wire [N-1:0]     priority_level,
    input  wire [31:0]     timeout_counter0,
    input  wire [31:0]     timeout_counter1,
    input  wire [31:0]     timeout_counter2,
    input  wire [31:0]     timeout_counter3,
    output reg  [N-1:0]     grant   
);

    reg [$clog2(N)-1:0] pointer;
    reg [$clog2(N)-1:0] pointer_next;
    reg found;
    reg idle = 1'b0;
    reg [31:0] timeout_counter;
    integer i;

    // Initialize timeout counters
    initial begin
        timeout_counter0 = 0;
        timeout_counter1 = 0;
        timeout_counter2 = 0;
        timeout_counter3 = 0;
    end

    always @(*) begin
        // Set initial state based on priority level
        if (priority_level == 4'b1000) begin
            grant = {N{1'b0}};
            pointer_next = pointer;
            found = 0;
        else begin
            grant = {N{1'b0}};
            pointer_next = pointer;
            found = 0;
        end
    end

    if (req != 0) begin
        found = 0;
        for (i = 0; i < N; i = i + 1) begin
            if (!found && (priority_level[(pointer + i) % N] == 4'b1000)) begin
                grant[(pointer + i) % N] = 1'b1;
                pointer_next = (pointer + i + 1) % N;
                found = 1'b1;
            end else if (!found && timeout_counter[(pointer + i) % N] >= TIMEOUT) begin
                grant[(pointer + i) % N] = 1'b1;
                pointer_next = (pointer + i + 1) % N;
                found = 1'b1;
                timeout_counter[(pointer + i) % N] = 0;
            end else if (!found) begin
                timeout_counter[(pointer + i) % N] += 1;
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

    // Update timeout counters
    if (found) begin
        timeout_counter0 = 0;
        timeout_counter1 = 0;
        timeout_counter2 = 0;
        timeout_counter3 = 0;
    end else begin
        timeout_counter0 += (req == 0 && (pointer == 0) ? 1 : 0);
        timeout_counter1 += (req == 0 && (pointer == 1) ? 1 : 0);
        timeout_counter2 += (req == 0 && (pointer == 2) ? 1 : 0);
        timeout_counter3 += (req == 0 && (pointer == 3) ? 1 : 0);
    end
endmodule
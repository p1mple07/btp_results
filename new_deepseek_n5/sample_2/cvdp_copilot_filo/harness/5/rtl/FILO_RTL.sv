module FILO_RTL(
    parameter DATA_WIDTH,
    parameter FILO_DEPTH,
    input clock,
    input reset,
    input push,
    input pop,
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out,
    output full,
    output empty
);

    // Internal buffer implementation
    localparam [FILO_DEPTH-1:0] buffer;
    reg top = 0;

    // Initialize on reset
    always_comb begin
        if (reset) begin
            top = 0;
            empty = 1;
            full = 0;
        end
    end

    // Push operation
    alwaysposedge clock begin
        if (push && top < FILO_DEPTH) begin
            buffer[top] = data_in;
            top = top + 1;
            if (top == FILO_DEPTH) full = 1;
            empty = 0;
        end
    end

    // Pop operation
    alwaysposedge clock begin
        if (pop && top > 0) begin
            data_out = buffer[top-1];
            top = top - 1;
            if (top == 0) empty = 1;
            full = 0;
        end
    end

    // Feedthrough case
    alwaysposedge clock begin
        if (push & pop) begin
            data_out = data_in;
            empty = 1;
            full = 0;
        end
    end
endmodule
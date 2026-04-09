module FILO_RTL (
    input clock,
    input reset,
    input push,
    input pop,
    input data_in,
    output data_out,
    output full,
    output empty
);

    parameter DATA_WIDTH = 8;
    parameter FILO_DEPTH = 16;

    reg top = 0;
    reg full = 0;
    reg empty = 1;

    always clock positive edge #100 begin
        if (reset) begin
            top = 0;
            empty = 1;
            full = 0;
        end else if (push) begin
            if (top < FILO_DEPTH) begin
                top++;
                full = (top == FILO_DEPTH);
                empty = ~empty;
            end
        end else if (pop) begin
            if (top > 0) begin
                top--;
                empty = (top == 0);
                full = ~full;
            end
        end else if (push & pop) begin
            data_out = data_in;
        end
    end
endmodule
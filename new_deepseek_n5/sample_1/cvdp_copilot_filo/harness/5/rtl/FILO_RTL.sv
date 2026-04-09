module FILO_RTL(
    input clock,
    input reset,
    input push,
    input pop,
    input [7:0] data_in,
    output [7:0] data_out,
    output full,
    output empty
);

    parameter DATA_WIDTH = 8;
    parameter FILO_DEPTH = 16;

    integer top;
    FIFO fifo[FIFO_DEPTH];
    FIFO fifo_data;

    always ensure top >= 0 and top < FIFO_DEPTH;

    initial begin
        top = 0;
        fifo = (FIFO) { (integer) 0 };
    end

    always clock edge begin
        if (reset) begin
            top = 0;
            empty = 1;
            full = 0;
            fifo = (FIFO) { (integer) 0 };
        end else begin
            if (push) begin
                if (top < FIFO_DEPTH) begin
                    fifo[top] = data_in;
                    top++;
                    if (top == FIFO_DEPTH) begin
                        full = 1;
                        empty = 0;
                    end else begin
                        empty = 0;
                    end
                end else begin
                    full = 1;
                    empty = 0;
                end
            end else begin
                if (pop) begin
                    if (top > 0) begin
                        data_out = fifo[top-1];
                        top--;
                        if (top == 0) begin
                            empty = 1;
                            full = 0;
                        end else begin
                            full = 0;
                        end
                    end else begin
                        empty = 1;
                        full = 0;
                    end
                end
            end
        end
    end

    endmodule
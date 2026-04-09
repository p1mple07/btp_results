module FILO_RTL(
    parameter DATA_WIDTH = 8,
    parameter FILO_DEPTH = 16,
    input clock,
    input reset,
    input push,
    input pop,
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out,
    output full,
    output empty
);

    integer top = 0;
    integer full = 0;
    integer empty = 1;

    always clock'event begin
        if (reset) begin
            top = 0;
            full = 0;
            empty = 1;
        end else begin
            if (push) begin
                if (top < FILO_DEPTH) begin
                    data_out = data_in;
                    top = top + 1;
                    if (top == FILO_DEPTH) begin
                        full = 1;
                        empty = 0;
                    end else begin
                        full = 0;
                        empty = 0;
                    end
                end else begin
                    full = 1;
                    empty = 0;
                end
            end else begin
                if (pop) begin
                    if (top > 0) begin
                        data_out = data_in;
                        top = top - 1;
                        if (top == 0) begin
                            empty = 1;
                            full = 0;
                        end else begin
                            empty = 0;
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
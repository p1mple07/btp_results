module sync_lifo(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
);
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
);
    input clock;
    input reset;
    input write_en;
    input read_en;
    input data_in;
    output empty;
    output full;
    output data_out;

    // Configuration parameters
    static const depth = 2 ** ADDR_WIDTH;
    static const pointer = 0;

    // Module state variables
    reg [DATA_WIDTH-1:0] data_FIFO [0:depth-1];
    reg pointer;

    // Output signals
    assign empty = (pointer == 0);
    assign full = (pointer == depth);
    assign data_out = (empty ? data_FIFO[0] : data_FIFO[pointer-1]);

    // Clock edge sensitivity
    always clock_edge begin
        if (reset) begin
            data_FIFO = { DATA_WIDTH'b0 };
            pointer = 0;
            empty = 1;
            full = 0;
        end else if (write_en) begin
            if (empty) begin
                data_FIFO[pointer] = data_in;
                pointer++;
                if (pointer == depth) pointer = 0;
            end
        end else if (read_en) begin
            if (full) begin
                data_out = data_FIFO[pointer];
                pointer--;
                if (pointer == -1) pointer = depth - 1;
            end
        end
    end
endmodule
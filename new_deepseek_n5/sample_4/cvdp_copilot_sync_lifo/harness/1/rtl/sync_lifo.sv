module sync_lifo(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3,
    parameter clock,
    parameter reset,
    parameter write_en,
    parameter read_en,
    parameter data_in,
    output empty,
    output full,
    output data_out
) {
    parameter depth = 1 << ADDR_WIDTH;
    reg state = 'idle';
    reg ptr = 0;
    reg [DATA_WIDTH-1:0] data_out = 0;
    reg [DATA_WIDTH-1:0] data_in;
    reg [depth-1:0] fifo_array;
    
    always clock_edge begin
        case (state)
            'idle:
                if (reset) begin
                    empty = 1;
                    full = 1;
                    fifo_array = 0;
                    ptr = 0;
                end else if (write_en) begin
                    if (count(fifo_array) < depth) begin
                        fifo_array[ptr] = data_in;
                        ptr = (ptr + 1) % depth;
                    end
                end else if (read_en) begin
                    if (count(fifo_array) > 0) begin
                        data_out = fifo_array[ptr];
                        ptr = (ptr - 1 + depth) % depth;
                        empty = 0;
                        full = 0;
                    end
                end
                state = 'write';
            'write:
                if (write_en) begin
                    if (count(fifo_array) < depth) begin
                        fifo_array[ptr] = data_in;
                        ptr = (ptr + 1) % depth;
                    end
                end else begin
                    state = 'idle';
                end
            'read:
                if (read_en) begin
                    if (count(fifo_array) > 0) begin
                        data_out = fifo_array[ptr];
                        ptr = (ptr - 1 + depth) % depth;
                        empty = 0;
                        full = 0;
                    end
                end else begin
                    state = 'idle';
                end
            'empty:
                state = 'idle';
            'full:
                state = 'idle';
        endcase
    end
}
module sync_lifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
)(
    input  logic clock,
    input  logic reset,
    input  logic write_en,
    input  logic read_en,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic empty,
    output logic full,
    output logic [DATA_WIDTH-1:0] data_out
);

    // Calculate the depth of the LIFO (number of storage locations)
    localparam DEPTH = 1 << ADDR_WIDTH;

    // Memory array for storing LIFO data
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointer to the top of the LIFO.
    // When top == 0, the LIFO is empty.
    // When top == DEPTH, the LIFO is full.
    logic [ADDR_WIDTH:0] top;

    // Combinational outputs for empty and full flags
    assign empty = (top == 0);
    assign full  = (top == DEPTH);

    // Synchronous process for LIFO operations
    always_ff @(posedge clock) begin
        if (reset) begin
            // Synchronous reset: clear pointer, memory, and output
            top <= 0;
            integer i;
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <= '0;
            end
            data_out <= '0;
        end else begin
            // Write operation: push data into the LIFO if not full
            if (write_en && !full) begin
                mem[top] <= data_in;
                top <= top + 1;
            end

            // Read operation: pop data from the LIFO if not empty
            if (read_en && !empty) begin
                data_out <= mem[top - 1];
                top <= top - 1;
            end
        end
    end

endmodule
module sync_lifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
)(
    input wire clock,
    input wire reset,
    input wire write_en,
    input wire read_en,
    input wire [DATA_WIDTH-1:0] data_in,
    output wire error,
    output wire valid,
    output wire [DATA_WIDTH-1:0] data_out
);

    // Calculate depth of the LIFO using the address width
    localparam DEPTH = (1 << ADDR_WIDTH);

    // Registers for LIFO logic
    reg [DEPTH-1:0] ptr;
    reg [DEPTH-1:0] lifo_counter;
    reg [DATA_WIDTH-1:0] memory [DEPTH-1:0];
    reg [DATA_WIDTH-1:0] temp_data_out;
    integer i;

    // Error state flag
    wire error_occurred = 0;

    // Output assignments for empty and full flags
    assign empty = (lifo_counter == 0) ? 1'b1 : 1'b0;
    assign full  = (lifo_counter == DEPTH) ? 1'b1 : 1'b0;

    // Counter logic to track the number of elements in LIFO
    always @(posedge clock) begin
        if (reset) begin
            lifo_counter <= 0;
            ptr <= {ADDR_WIDTH {1'b0}};
        end else if (!full && write_en) begin
            lifo_counter <= lifo_counter + 1;
            ptr <= ptr + 1;
        end else if (!empty && read_en) begin
            lifo_counter <= lifo_counter - 1;
            ptr <= ptr - 1;
        end
    end

    // Memory write logic: writes data into the LIFO
    always @(posedge clock) begin
        if (reset) begin
            ptr <= {ADDR_WIDTH {1'b0}};
        end else if (write_en && !full) begin
            memory[ptr] <= data_in;
            ptr <= ptr + 1;
        end
    end

    // Memory read logic: reads data from the LIFO
    always @(posedge clock) begin
        if (reset) begin
            temp_data_out <= {DATA_WIDTH{1'b0}};
        end else if (read_en && !empty) begin
            temp_data_out <= memory[ptr - 1'b1];
            ptr <= ptr - 1;
        end
    end

    // Error handling and valid signal
    always @* begin
        if (write_en && lifo_counter == DEPTH) begin
            error <= 1'b1;
        end else if (read_en && lifo_counter == 0) begin
            error <= 1'b1;
            valid <= 0;
        end else if (read_en && empty) begin
            valid <= 1'b1;
        end else if (write_en && write_en) begin
            valid <= 1'b1;
        end
    end

    assign data_out = temp_data_out;
endmodule
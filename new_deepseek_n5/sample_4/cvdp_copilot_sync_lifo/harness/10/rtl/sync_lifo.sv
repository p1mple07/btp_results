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

    localparam DEPTH = (1 << ADDR_WIDTH);

    reg [DEPTH-1:0] ptr;
    reg [DEPTH-1:0] lifo_counter;
    reg [DATA_WIDTH-1:0] memory [DEPTH-1:0];
    reg [DATA_WIDTH-1:0] temp_data_out;
    integer i;

    assign empty = (lifo_counter == 0) ? 1'b1 : 1'b0;
    assign full  = (lifo_counter == DEPTH) ? 1'b1 : 1'b0;

    always @(posedge clock) begin
        if (reset) begin
            lifo_counter <= 0;
        end else if (write_en && lifo_counter == DEPTH) begin
            assign error = 1;
        end else if (write_en && !full) begin
            memory[ptr] <= data_in;
            ptr <= ptr + 1;
        end else if (read_en && empty) begin
            assign error = 1;
            assign valid = 0;
        end else if (read_en && !empty) begin
            temp_data_out <= memory[ptr - 1];
            ptr <= ptr - 1;
        end
    end

    always @(posedge clock) begin
        if (reset) begin
            ptr <= {ADDR_WIDTH {1'b0}};
        end else if (write_en && !full) begin
            memory[ptr] <= data_in;
            ptr <= ptr + 1;
        end else if (read_en && !empty) begin
            temp_data_out <= memory[ptr - 1];
            ptr <= ptr - 1;
        end
    end

    assign data_out = temp_data_out;
endmodule
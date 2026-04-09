module sync_lifo #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 3)
(
    input clk,
    input reset,
    input write_en,
    input read_en,
    input [DATA_WIDTH-1:0] data_in,
    output reg empty,
    output reg full,
    output [DATA_WIDTH-1:0] data_out
);

    reg [ADDR_WIDTH-1:0] write_ptr;
    reg [DATA_WIDTH-1:0] memory [2**ADDR_WIDTH-1:0];
    integer count;

    always_ff @(posedge clk) begin
        if (reset) begin
            empty <= 1;
            full <= 0;
            write_ptr <= 0;
            memory <= { { {replicate({1'b0}, DATA_WIDTH) } } };
        end else begin
            if (write_en && !full) begin
                memory[write_ptr] <= data_in;
                write_ptr <= write_ptr + 1;
                full <= 1;
            end

            if (read_en && !empty) begin
                data_out <= memory[write_ptr];
                write_ptr <= 0;
                empty <= 0;
            }
        end
    end

endmodule

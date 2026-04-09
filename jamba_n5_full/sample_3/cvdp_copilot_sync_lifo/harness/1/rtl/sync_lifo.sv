module sync_lifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
) (
    input wire clock,
    input wire reset,
    input wire write_en,
    input wire read_en,
    input wire data_in,
    output reg empty,
    output reg full,
    output reg [DATA_WIDTH-1:0] data_out
);

    localparam N = ADDR_WIDTH;
    reg [N-1:0] memory [0:N-1];
    int top = 0;

    always @(posedge clock) begin
        if (reset) begin
            memory[0:N-1] = 0;
            top = 0;
            empty = 1'b1;
            full = 1'b0;
        end else begin
            if (write_en) begin
                if (!full) begin
                    memory[top] = data_in;
                    top = (top + 1) mod N;
                end
            end

            if (read_en) begin
                if (empty) begin
                    data_out <= 0;
                    empty = 1'b0;
                    full = 1'b0;
                end else begin
                    data_out <= memory[top];
                    empty = 1'b1;
                    full = 1'b0;
                end
            end
        end
    end

endmodule

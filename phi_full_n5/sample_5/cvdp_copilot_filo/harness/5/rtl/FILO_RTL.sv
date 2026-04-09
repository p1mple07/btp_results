module FILO_RTL (
    input clk,
    input reset,
    input push,
    input pop,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg full,
    output reg empty
);

    parameter DATA_WIDTH = 8;
    parameter FILO_DEPTH = 16;
    integer top = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            top <= 0;
            full <= 0;
            empty <= 1;
        end else if (push) begin
            if (!full) begin
                data_out <= data_in;
                top <= top + 1;
                full <= 0;
                empty <= 0;
            end
        end else if (pop) begin
            if (!empty) begin
                data_out <= data_in;
                top <= top - 1;
                empty <= 0;
                full <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if (pop && !empty) begin
            empty <= 1;
        end else if (push && !full) begin
            full <= 0;
        end
    end

endmodule

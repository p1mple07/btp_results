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

    reg [DATA_WIDTH-1:0] stack[FILO_DEPTH-1:0];
    integer top = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            top <= 0;
            full <= 0;
            empty <= 1;
            data_out <= 8'h00;
        end else if (push) begin
            if (!full) begin
                stack[top] <= data_in;
                top <= top + 1;
                if (top == FILO_DEPTH) begin
                    full <= 1;
                end else begin
                    full <= 0;
                end
            end
        end else if (pop) begin
            if (!empty) begin
                data_out <= stack[top];
                top <= top - 1;
                if (top == 0) begin
                    empty <= 1;
                end else begin
                    empty <= 0;
                end
            end
        end
    end

endmodule
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

    reg [DATA_WIDTH-1:0] stack[FILO_DEPTH-1:0];
    integer top = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            top <= 0;
            full <= 0;
            empty <= 1;
            data_out <= 8'h00;
        end else if (push) begin
            if (!full) begin
                stack[top] <= data_in;
                top <= top + 1;
                if (top == FILO_DEPTH) begin
                    full <= 1;
                end else begin
                    full <= 0;
                end
            end
        end else if (pop) begin
            if (!empty) begin
                data_out <= stack[top];
                top <= top - 1;
                if (top == 0) begin
                    empty <= 1;
                end else begin
                    empty <= 0;
                end
            end
        end
    end

endmodule
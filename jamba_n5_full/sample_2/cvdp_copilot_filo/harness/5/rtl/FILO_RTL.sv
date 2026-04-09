module FILO_RTL #(
    parameter DATA_WIDTH = 8,
    parameter FILO_DEPTH = 16
)(
    input wire clk,
    input wire reset,
    input wire push,
    input wire pop,
    input wire data_in,
    output reg data_out,
    output reg full,
    output reg empty
);

reg [DATA_WIDTH - 1:0] data;
reg [0:0] top;

initial begin
    top = 0;
    data = 0;
    empty = 1;
    full = 0;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        data = 0;
        top = 0;
        empty = 1;
        full = 0;
    end else begin
        case (full)
            'b0: begin
                if (push) begin
                    data[top] = data_in;
                    top = (top + 1) mod FILO_DEPTH;
                    empty = 1;
                    full = 0;
                end
            end
            'b1: begin
                if (pop) begin
                    data_out = data[top];
                    top = (top + 1) mod FILO_DEPTH;
                    full = 0;
                    empty = 1;
                end
            end
        endcase
    end
end

endmodule

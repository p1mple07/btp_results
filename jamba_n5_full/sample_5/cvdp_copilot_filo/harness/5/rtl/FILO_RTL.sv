module filo_rtl #(
    parameter DATA_WIDTH = 8,
    parameter FILO_DEPTH = 16
)(
    input wire clk,
    input wire reset,
    input wire push,
    input wire pop,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg data_out,
    output reg full,
    output reg empty
);

    reg top;
    reg empty;
    reg full;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            top <= 0;
            empty <= 1;
            full <= 0;
            data_out <= 0;
            data_in <= 0;
        end else begin
            if (push) begin
                if (!full) begin
                    top <= top + 1;
                    data_out <= data_in;
                    full <= 1;
                    if (top == FILO_DEPTH) full <= 1;
                end
            end
            if (pop) begin
                if (!empty) begin
                    data_out <= data_out_prev;
                    data_out_prev <= data_out;
                    full <= 0;
                    empty <= 1;
                end
            end
        end
    end

    assign data_out = data_out_prev;
    assign data_in = data_in_prev;

endmodule

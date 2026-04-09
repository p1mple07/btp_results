module FILO_RTL #(parameter DATA_WIDTH = 8, parameter FILO_DEPTH = 16) (
    input clk,
    input reset,
    input push,
    input pop,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg full,
    output reg empty
);

    reg [DATA_WIDTH-1:0] fifo_data[FILO_DEPTH-1:0];
    integer top = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            top <= 0;
            full <= 0;
            empty <= 1;
            data_out <= {DATA_WIDTH{1'b0}};
        end else if (push) begin
            if (top < FILO_DEPTH - 1) begin
                fifo_data[top] <= data_in;
                top <= top + 1;
                full <= 0;
                empty <= 0;
            end
        end else if (pop) begin
            if (top > 0) begin
                data_out <= fifo_data[top - 1];
                top <= top - 1;
                full <= 0;
                empty <= 0;
            end else begin
                full <= 1;
                empty <= 1;
                data_out <= {DATA_WIDTH{1'b0}}; // Feedthrough case
            end
        end
    end

endmodule

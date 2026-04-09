module FILO_RTL #(parameter DATA_WIDTH = 8, FILO_DEPTH = 16) (
    input clk,
    input reset,
    input push,
    input pop,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg full,
    output reg empty
);

    reg [DATA_WIDTH-1:0] buffer [0:FILO_DEPTH-1];
    integer top;

    // Reset logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            empty <= 1;
            full <= 0;
            top <= 0;
        end else begin
            if (push) begin
                if (top < FILO_DEPTH-1) begin
                    buffer[top] <= data_in;
                    top <= top + 1;
                    full <= 0;
                    empty <= 0;
                end
            end else if (pop) begin
                if (top > 0) begin
                    data_out <= buffer[top-1];
                    top <= top - 1;
                    if (top == 0) begin
                        empty <= 1;
                        full <= 0;
                    end
                end
            end
        end
    end

    // Feedthrough logic
    always @(posedge clk) begin
        if (!reset && push && pop) begin
            data_out <= data_in;
        end
    end

endmodule

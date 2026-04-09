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

    // Internal state variables
    reg [DATA_WIDTH-1:0] buffer [0:FILO_DEPTH-1];
    reg [FILO_DEPTH-1:0] top;

    // Reset logic
    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            top <= 0;
            full <= 0;
            empty <= 1;
        end else if (push && !full) begin
            buffer[top] <= data_in;
            top <= top + 1;
            full <= 0;
            empty <= 0;
        end
    end

    // Pop logic
    always @ (posedge clk or posedge pop) begin
        if (pop && !empty) begin
            data_out <= buffer[top];
            top <= top - 1;
            full <= 0;
            empty <= 0;
        end
    end

    // Push logic
    always @ (posedge clk or posedge push) begin
        if (push && !full) begin
            buffer[top] <= data_in;
            top <= top + 1;
            full <= 0;
            empty <= 0;
        end
    end

    // Feedthrough logic
    always @ (*) begin
        if (!empty && !full && push && pop) begin
            data_out <= data_in;
        end
    end

endmodule

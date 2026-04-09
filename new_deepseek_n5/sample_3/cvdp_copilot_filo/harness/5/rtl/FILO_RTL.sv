module FILO_RTL(
    parameter DATA_WIDTH = 8,
    parameter FILO_DEPTH = 16
);

    // State variables
    reg top;
    reg [DATA_WIDTH-1:0] data_in;
    reg [DATA_WIDTH-1:0] data_out;
    reg full, empty;

    // Internal buffer
    reg [FILO_DEPTH-1:0] buffer;

    // Input control signals
    input clock, reset, push, pop;

    // Output control signals
    output data_out, full, empty;

    // Initialize on reset
    always @ (reset) begin
        top = 0;
        empty = 1;
        full = 0;
    end

    // Push operation
    always @ (clockposededge) begin
        if (push && !full) begin
            buffer[top] = data_in;
            top++;
            if (top == FILO_DEPTH) begin
                full = 1;
                empty = 0;
            end
        end
    end

    // Pop operation
    always @ (clockposededge) begin
        if (pop && !empty) begin
            top--;
            data_out = buffer[top];
            if (top == -1) begin
                empty = 1;
                full = 0;
            end
        end
    end

    // Feedthrough case
    always @ (clockposededge) begin
        if (push && pop) begin
            if (!empty) begin
                data_out = data_in;
            end
        end
    end
endmodule
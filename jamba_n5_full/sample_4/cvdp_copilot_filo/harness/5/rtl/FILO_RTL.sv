module FILO_RTL (#(
    parameter DATA_WIDTH = 8,
    parameter FILO_DEPTH = 16
));

    localparam NUM_LEVELS = FILO_DEPTH + 1;

    reg [DATA_WIDTH-1:0] buffer[0:NUM_LEVELS-1];
    reg top;
    reg full;
    reg empty;
    wire clk, reset;
    wire push, pop;
    wire data_in_val;

    always @(posedge clk or negedge reset) begin
        if (reset) begin
            top <= 0;
            buffer[0] <= 0;
            full <= 0;
            empty <= 1;
        end else begin
            if (push) begin
                if (full) begin
                    full <= 0;
                end else begin
                    buffer[top+1] <= data_in_val;
                    top <= top + 1;
                    full <= (top == num_elements-1);
                end
            end else if (pop) begin
                if (!empty) begin
                    data_out <= buffer[top];
                    top <= top - 1;
                    empty <= (top == 0);
                    full <= (top == 0);
                end
            end
        end
    end

    assign data_out = full ? data_out : data_in_val;
    assign full = full;
    assign empty = empty;

endmodule

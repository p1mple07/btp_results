module FILO_RTL (
    input  clk,
    input  reset,
    input  push,
    input  pop,
    input  data_in[DATA_WIDTH-1:0],
    output data_out,
    output full,
    output empty
);

    localparam FILO_DEPTH = 16; // default
    localparam DATA_WIDTH   = 8;   // default

    reg [DATA_WIDTH-1:0] data;
    reg top;
    reg full_flag;
    reg empty_flag;

    always @(posedge clk) begin
        if (reset) begin
            top <= 0;
            empty_flag <= 1;
            full_flag <= 0;
        end else begin
            if (push && !full_flag) begin
                top <= top + 1;
                if (top >= FILO_DEPTH) top <= 0;
                data[top] <= data_in;
            end

            if (pop && !empty_flag) begin
                top <= top - 1;
                if (top < 0) top <= FILO_DEPTH - 1;
                data_out <= data[top];
            end

            full_flag <= (top == 0);
            empty_flag <= (top == FILO_DEPTH - 1);

            if (push && pop) begin
                // feedthrough case
                data_out <= data_in;
                full_flag <= 0;
                empty_flag <= 1;
            end
        end
    end

endmodule

module moving_average(
    input clk,
    input reset,
    input [10:0] data_in,
    output [11:0] data_out
);

    reg [7:0] buffer[0:7];
    reg [11:0] sum;
    reg sample_available;

    initial begin
        sum = 0;
        for (int i = 0; i < 8; i++) begin
            buffer[i] = 0;
        end
        sample_available = 8'd0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sum = 0;
            for (i = 0; i < 8; i++) buffer[i] = 0;
            sample_available = 8'd0;
        end else begin
            if (data_in[11] == 1'b0) begin
                if (sample_available == 1) begin
                    buffer[7] = buffer[6];
                    sum = sum - buffer[6];
                    sum += buffer[7];
                    buffer[6] = buffer[5];
                end else begin
                    buffer[7] <= data_in;
                    sum += data_in;
                    for (i = 6; i > 0; i--) buffer[i] = buffer[i - 1];
                    sample_available = 8'd1;
                end
            end
        end
    end

    assign data_out = sum / 8;

endmodule

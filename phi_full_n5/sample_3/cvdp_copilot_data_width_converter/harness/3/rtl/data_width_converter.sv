module data_width_converter(
    input clk,
    input reset,
    input [31:0] data_in,
    input data_valid,
    output reg [127:0] o_data_out,
    output reg o_data_out_valid
);

    // Internal state and counter
    reg [3:0] count;
    reg [127:0] buffer[4:0];

    // Reset condition
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            o_data_out <= 16'h0000000000000000;
            o_data_out_valid <= 0;
            for (int i = 0; i < 5; i++) begin
                buffer[i] <= 0;
            end
        end else begin
            if (count < 4) begin
                count <= count + 1;
                buffer[count] <= data_in;
                if (data_valid) begin
                    o_data_out_valid <= 1;
                    if (count == 4) begin
                        o_data_out <= {buffer[0], buffer[1], buffer[2], buffer[3]};
                        o_data_out_valid <= 0;
                        count <= 0;
                    end
                end
            end
        end
    end

endmodule

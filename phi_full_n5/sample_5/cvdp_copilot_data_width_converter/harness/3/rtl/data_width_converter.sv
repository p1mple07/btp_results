module data_width_converter(
    input clk,
    input reset,
    input [31:0] data_in,
    input data_valid,
    output reg [127:0] o_data_out,
    output reg o_data_out_valid
);

    reg [31:0] buffer[4:0];
    integer i;

    initial begin
        buffer[0] = 32'h00000000;
        buffer[1] = 32'h00000000;
        buffer[2] = 32'h00000000;
        buffer[3] = 32'h00000000;
        buffer[4] = 32'h00000000;
        o_data_out_valid = 0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer[0] <= 32'h00000000;
            buffer[1] <= 32'h00000000;
            buffer[2] <= 32'h00000000;
            buffer[3] <= 32'h00000000;
            buffer[4] <= 32'h00000000;
            o_data_out_valid <= 0;
        end else begin
            if (data_valid) begin
                buffer[4] <= buffer[3] << 32 | data_in;
                if (((buffer[4] & 0xFFFFFFFFFFFFFFFF) == buffer[3]) && ((buffer[3] & 0xFFFFFFFFFFFFFFFF) == buffer[2]) && ((buffer[2] & 0xFFFFFFFFFFFFFFFF) == buffer[1]) && ((buffer[1] & 0xFFFFFFFFFFFFFFFF) == buffer[0])) begin
                    o_data_out <= buffer[4];
                    o_data_out_valid <= 1;
                end
            end
        end
    end

endmodule

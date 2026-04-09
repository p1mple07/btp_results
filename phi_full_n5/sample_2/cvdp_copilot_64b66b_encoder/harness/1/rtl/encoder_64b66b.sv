module encoder_64b66b(
    input clk_in,
    input rst_in,
    input [63:0] encoder_data_in,
    input [7:0] encoder_control_in,
    output reg [65:0] encoder_data_out
);

    // Internal registers
    reg [63:0] data_temp;

    // State machine to handle control word
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            data_temp <= 64'h0000000000000000;
        end else begin
            case (encoder_control_in)
                8'b00000000: begin
                    data_temp <= encoder_data_in;
                end
                8'b00000001: begin
                    data_temp <= 64'h0000000000000000;
                end
                default: begin
                    data_temp <= 64'h0000000000000000;
                end
            endcase
        end
    end

    // Output logic
    always @(posedge clk_in) begin
        if (!rst_in) begin
            encoder_data_out <= 66'h0000000000000000;
        end else begin
            if (encoder_control_in == 8'b00000000) begin
                encoder_data_out <= {2'b01, data_temp};
            end else begin
                encoder_data_out <= {2'b10, 64'h0000000000000000};
            end
        end
    end

endmodule

module encoder_64b66b(
    input clk_in,
    input rst_in,
    input [63:0] encoder_data_in,
    input [7:0] encoder_control_in,
    output reg [65:0] encoder_data_out
);

    // Local Registers
    reg [63:0] data_out;

    // State Machine
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            data_out <= 64'b0;
            encoder_data_out <= 66'b00;
        end else begin
            case (encoder_control_in)
                8'b00000000: begin
                    data_out <= encoder_data_in;
                    encoder_data_out <= {2'b01, data_out};
                end
                default: begin
                    data_out <= 64'b0;
                    encoder_data_out <= {2'b10, data_out};
                end
            endcase
        end
    end

endmodule

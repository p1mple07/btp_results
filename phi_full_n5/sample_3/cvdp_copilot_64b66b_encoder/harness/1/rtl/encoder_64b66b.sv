module encoder_64b66b(
    input clk_in,
    input rst_in,
    input [63:0] encoder_data_in,
    input [7:0] encoder_control_in,
    output reg [65:0] encoder_data_out
);

    // State register
    reg [2:0] sync_state;

    // Internal signals
    reg [63:0] data_out;

    // Clock and reset process
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_state <= 3'b0;
            data_out <= 0;
        end else begin
            case (sync_state)
                3'b00: begin
                    if (encoder_control_in == 8'b00000000) begin
                        sync_state <= 3'b01;
                        data_out <= encoder_data_in;
                    end
                end
                3'b01: begin
                    data_out <= encoder_data_in;
                end
                3'b10: begin
                    // Control word encoding not supported
                    data_out <= 64'h0000000000000000;
                end
                default: begin
                    sync_state <= 3'b00;
                end
            endcase
        end
    end

    // Output assignment
    assign encoder_data_out = {sync_state, data_out};

endmodule

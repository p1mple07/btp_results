module encoder_64b66b (
    input clk_in,
    input rst_in,
    input [63:0] encoder_data_in,
    input [7:0] encoder_control_in,
    output reg [65:0] encoder_data_out
);

    // Internal signals
    reg [63:0] data_out;
    reg [2:0] sync_word;

    // State machine for encoding
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            data_out <= 64'b0;
            sync_word <= 3'b00;
        end else begin
            if (encoder_control_in == 8'b00000000) begin
                data_out <= encoder_data_in;
                sync_word <= 3'b01;
            end else begin
                data_out <= 64'b0;
                sync_word <= 3'b10;
            end
        end
    end

    // Combine sync word and data
    always @(posedge clk_in) begin
        encoder_data_out <= {sync_word, data_out};
    end

endmodule

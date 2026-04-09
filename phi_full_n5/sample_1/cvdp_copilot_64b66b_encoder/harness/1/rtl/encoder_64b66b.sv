module encoder_64b66b(
    input clk_in,
    input rst_in,
    input [63:0] encoder_data_in,
    input [7:0] encoder_control_in,
    output reg [65:0] encoder_data_out
);

    reg [1:0] sync_word;
    reg [63:0] encoded_data;

    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b00;
            encoded_data <= 64'h0000000000000000;
        end else begin
            if (encoder_control_in == 8'b00000000) begin
                sync_word <= 2'b01;
                encoded_data <= encoder_data_in;
            end else begin
                sync_word <= 2'b10;
                encoded_data <= 64'h0000000000000000;
            end
        end
    end

    assign encoder_data_out = {sync_word, encoded_data};

endmodule

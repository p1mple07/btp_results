module encoder_64b66b (
    input  logic  clk_in, 
    input  rst_in, 
    input  logic [63:0] encoder_data_in, 
    input  logic [8'b00000000] encoder_control_in, 
    output logic [65:0] encoder_data_out 
);

    logic [1:0] sync_word; 
    logic [64'b0] encoded_data;

    always_ff @(posedge clk_in or negedge rst_in) begin
        if (~rst_in) begin
            sync_word <= 2'b00;
        else begin
            if (encoder_control_in == 8'b00000000) begin
                sync_word <= 2'b01;
            else begin
                sync_word <= 2'b10;
                encoded_data <= 0;
            end
        end
    end

    always_ff @(posedge clk_in or negedge rst_in) begin
        if (~rst_in) begin
            encoded_data <= 64'b0;
        else begin
            if (encoder_control_in == 8'b00000000) begin
                encoded_data <= encoder_data_in;
            else
                encoded_data <= 0;
            end
        end
    end

    assign encoder_data_out = {2'b00, encoded_data};

endmodule
module encoder_64b66b (
    input  logic         clk_in,
    input  logic         rst_in,
    input  logic [63:0]  encoder_data_in,
    input  logic [7:0]   encoder_control_in,
    output logic [65:0]  encoder_data_out
);

    logic [1:0]  sync_word;
    logic [63:0] encoded_data;
    logic [7:0]  type_field;
    logic [55:0] encoded_ctrl_words;

    // Synchronize sync_word
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b00;
        end else begin
            if (encoder_control_in == 8'b00000000) begin
                sync_word <= 2'b01;
            end else begin
                sync_word <= 2'b10;
            end
        end
    end

    // Synchronize encoded_data
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            encoded_data <= 64'b0;
        end else begin
            encoded_data <= encoder_data_in;
        end
    end

    // Output generation
    assign encoder_data_out = {
        sync_word,
        type_field,
        encoded_ctrl_words
    };

endmodule

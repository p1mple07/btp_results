module encoder_64b66b (
    input  logic         clk_in,              
    input  logic         rst_in,              
    input  logic [63:0]  encoder_data_in,     
    input  logic [7:0]   encoder_control_in,  
    output logic [65:0]  encoder_data_out     
);

    logic [1:0] sync_word;     
    logic [63:0] encoded_data; 

    // Use active-high reset. On reset, clear sync_word and encoded_data.
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b00;
        end else begin
            if (encoder_control_in == 8'b00000000)
                sync_word <= 2'b01;
            else
                sync_word <= 2'b10;
        end
    end

    // Use active-high reset. On reset, clear encoded_data.
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            encoded_data <= 64'b0;
        end else begin
            if (encoder_control_in == 8'b00000000)
                encoded_data <= encoder_data_in;
            else
                encoded_data <= 64'b0; // Clear data in control mode
        end
    end

    // Use the sync_word for the header bits.
    assign encoder_data_out = {sync_word, encoded_data};

endmodule
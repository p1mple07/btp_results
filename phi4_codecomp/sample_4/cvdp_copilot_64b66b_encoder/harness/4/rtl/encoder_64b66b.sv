module encoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic [63:0]  encoder_data_in,     // 64-bit data input
    input  logic [7:0]   encoder_control_in,  // 8-bit control input
    output logic [65:0]  encoder_data_out     // 66-bit encoded output
);

    // Internal signals
    logic [1:0] sync_word;     // 2-bit sync header
    logic [63:0] encoded_data; // 64-bit encoded data

    // Main encoding process
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            // Reset state
            sync_word <= 2'b00;            // Default sync word
            encoded_data <= 64'b0;         // Clear encoded data
        end 
        else begin
            if (encoder_control_in == 8'b00000000) begin
                // Data encoding mode
                sync_word <= 2'b01;         // Sync header for data
                encoded_data <= encoder_data_in; // Pass data directly
            end 
            else begin
                // Control encoding mode
                sync_word <= 2'b10;         // Sync header for control
                encoded_data <= 64'b0;      // Clear data for control words
            end
        end
    end

    // Concatenate sync word and encoded data for output
    assign encoder_data_out = {sync_word, encoded_data};

endmodule
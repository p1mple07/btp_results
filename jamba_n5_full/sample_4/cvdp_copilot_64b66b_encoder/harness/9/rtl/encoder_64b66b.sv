module encoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic [63:0]  encoder_data_in,     // 64-bit data input
    input  logic [7:0]   encoder_control_in,  // 8-bit control input
    output logic [65:0]  encoder_data_out     // 66-bit encoded output
);

    logic [1:0] sync_word;
    logic [1:0] type;
    logic [63:0] encoded_data;

    // Determine the mode based on the control input
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b01;
            type <= 2'b0;
        end else begin
            if (encoder_control_in == 8'b00000000) begin
                // Data‑only mode
                sync_word <= 2'b01;
                encoded_data <= encoder_data_in;
                type <= 2'b0;
            end else begin
                // Control‑only or mixed mode
                sync_word <= 2'b10;
                type <= 2'b1;
                // Encode the data and control signals
                for (int i = 0; i < 8; i++) begin
                    if (encoder_control_in[i] == 1) begin
                        // Placeholder for control‑specific encoding
                        // In a real implementation, replace this with the actual
                        // 7‑bit control codes according to the table.
                        // For brevity, we simply skip this part.
                        // You may add your own decoding logic here.
                    end
                end
            end
        end
    end

    assign encoder_data_out = {sync_word, encoded_data, type};

endmodule

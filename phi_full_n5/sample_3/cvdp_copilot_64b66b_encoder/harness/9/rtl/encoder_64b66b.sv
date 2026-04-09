module encoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic [63:0]  encoder_data_in,     // 64-bit data input
    input  logic [7:0]   encoder_control_in,  // 8-bit control input
    output logic [65:0]  encoder_data_out     // 66-bit encoded output
);

    logic [1:0] sync_word;     
    logic [63:0] encoded_data; 

    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b00;            
        end 
        else begin
            // Determine sync_word based on control input
            sync_word <= encoder_control_in ? 2'b10 : 2'b01;

            // Encode data based on control input
            if (encoder_control_in == 8'b00000000) begin
                encoded_data <= encoder_data_in; 
            end else begin
                // Mixed mode encoding
                for (int i = 0; i < 64; i = i + 1) begin
                    if (encoder_control_in[i]) begin
                        // Control character encoding
                        case (encoder_control_in[i])
                            7'b0000000: encoded_data[i] <= 7'b000000;
                            7'b0000100: encoded_data[i] <= 7'b000000;
                            7'b0001000: encoded_data[i] <= 7'b000000;
                            7'b0010000: encoded_data[i] <= 7'b000000;
                            7'b0100000: encoded_data[i] <= 7'b000000;
                            7'b1000000: encoded_data[i] <= 7'b000000;
                            7'b1100000: encoded_data[i] <= 7'b111111;
                            default: encoded_data[i] <= encoder_data_in[i];
                        endcase
                    end else begin
                        // Data byte encoding
                        encoded_data[i] <= encoder_data_in[i];
                    end
                end
            end
        end
    end

    assign encoder_data_out = {sync_word, encoded_data};

endmodule

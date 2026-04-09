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
            sync_word <= 2'b10; // Set to 2'b10 for control-only and mixed modes
            if (encoder_control_in == 8'b00000000) begin
                encoded_data <= encoder_data_in; // Pass data unchanged for data-only mode
            end
            else begin
                // Mixed mode: Pass data bytes unchanged for control bits set to 0
                // Encode control bits set to 1 according to the control character lookup table
                for (int j = 0; j < 8; j=j+1) begin
                    if (encoder_control_in[j]) begin
                        // Map control bit to its corresponding control code
                        case (encoder_control_in[j])
                            7'b0000000: encoded_data[63-j+1:0] = 7'b000000;
                            7'b1111111: encoded_data[63-j+1:0] = 7'b1e;
                            default: encoded_data[63-j+1:0] = 7'bx; // Handle undefined control bits
                        endcase
                    end
                end
            end
        end
    end

    assign encoder_data_out = {sync_word, encoded_data};

endmodule

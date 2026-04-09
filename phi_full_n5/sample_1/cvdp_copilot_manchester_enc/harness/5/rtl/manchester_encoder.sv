// Manchester encoder module
module manchester_encoder #(
    parameter N = 8  // Default width of output data
) (
    input  logic clk_in,          // Clock input
    input  logic rst_in,          // Active high reset input
    input  logic enc_valid_in,        // Input valid signal
    input  logic [N-1:0] enc_data_in, // N-bit input data
    output logic enc_valid_out,       // Output valid signal
    output logic [2*N-1:0] enc_data_out // 2*N-bit output encoded data
);

    // Internal register to hold the encoded data
    logic [2*N-1:0] encoded_data;

    // Sequential logic to generate Manchester encoded data
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            enc_data_out <= '0; // Reset the output to zero
            enc_valid_out <= 1'b0; // Reset the valid signal
        end else if (enc_valid_in) begin
            // Initialize encoded_data to '0' when enc_valid_in is '0'
            encoded_data <= '0;
            for (int i = 0; i < N; i++) begin
                if (enc_data_in[i] == 1'b1) begin
                    encoded_data[2*i] = 1'b1;
                    encoded_data[2*i + 1] = 1'b0;
                else begin
                    encoded_data[2*i] = 1'b0;
                    encoded_data[2*i + 1] = 1'b1;
                end
            end
            enc_valid_out <= 1'b1; // Set the valid signal
        end else begin
            // Keep the encoded_data unchanged when enc_valid_in is '0'
            // This prevents latch inference
            encoded_data <= encoded_data;
            enc_valid_out <= 1'b0; // Clear the valid signal if no valid input
        end
    end

    // Assign the encoded_data to enc_data_out
    assign enc_data_out = encoded_data;
endmodule

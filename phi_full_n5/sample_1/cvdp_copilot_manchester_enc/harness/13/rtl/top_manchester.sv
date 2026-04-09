module manchester_encoder #(
    parameter N = 8  // Default width of input data
) (
    input  logic clk_in,          // Clock input
    input  logic rst_in,          // Active high reset input
    input  logic enc_valid_in,    // Input valid signal
    input  logic [N-1:0] enc_data_in, // N-bit input data
    output logic enc_valid_out,   // Output valid signal
    output logic [2*N-1:0] enc_data_out // 2N-bit output encoded data
);

    logic [2*N-1:0] encoded_data;
    logic encoded_data_valid;

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            encoded_data <= '0;
            encoded_data_valid <= 1'b0;
        end else if (enc_valid_in) begin
            for (int i = 0; i < N; i++) begin
                encoded_data[2*i] <= enc_data_in[i];
                encoded_data[2*i+1] <= ~enc_data_in[i];
            end
            encoded_data_valid <= 1'b1;
        end else begin
            encoded_data <= 'd0;
            encoded_data_valid <= 1'b0;
        end
    end

endmodule

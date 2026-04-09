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
                encoded_data[2*i] <= enc_data_in[i] ? 1'b1 : 1'b0;
                encoded_data[2*i+1] <= ~enc_data_in[i] ? 1'b1 : 1'b0;
            end
            encoded_data_valid <= 1'b1;
        end else begin
            encoded_data <= 'd0;
            encoded_data_valid <= 1'b0;
        end
    end

endmodule

module manchester_decoder #(
    parameter N = 8  // Default width of output data
) (
    input  logic clk_in,          // Clock input
    input  logic rst_in,          // Active high reset input
    input  logic dec_valid_in,    // Input valid signal
    input  logic [2*N-1:0] dec_data_in, // 2N-bit Manchester encoded input data
    output logic dec_valid_out,   // Output valid signal
    output logic [N-1:0] dec_data_out  // N-bit output decoded data
);

    logic [N-1:0] decoded_data;
    logic decoded_data_valid;

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            decoded_data <= '0;
            decoded_data_valid <= 1'b0;
        end else if (dec_valid_in) begin
            for (int i = 0; i < N; i++) begin
                if (dec_data_in[2*i] == 1'b1 && dec_data_in[2*i+1] == 1'b0) begin
                    decoded_data[i] <= 1'b1;
                end else if (dec_data_in[2*i] == 1'b0 && dec_data_in[2*i+1] == 1'b1) begin
                    decoded_data[i] <= 1'b0;
                end else begin
                    decoded_data[i] <= 1'b0;
                end
            end
            decoded_data_valid <= 1'b1;
        end else begin
            decoded_data <= '0;
            decoded_data_valid <= 1'b0;
        end
    end

endmodule

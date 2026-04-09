// Synchronous Manchester Encoder
module manchester_encoder #(
    parameter N = 8  // Default width of output data
) (
    input  logic clk_in,
    input  logic rst_in,
    input  logic enc_valid_in,
    input  logic [N-1:0] enc_data_in,
    output logic enc_valid_out,
    output logic [2*N-1:0] enc_data_out
);

    logic [2*N-1:0] temp;
    reg [N-1:0] encoded_data;

    // Clocked assignment for synchronous output
    always_ff @(posedge clk_in or negedge rst_in) begin
        if (!rst_in) begin
            encoded_data <= '0;
            temp <= '0;
        end else begin
            if (enc_valid_in) begin
                for (int i = 0; i < N; i++) begin
                    temp[2*i] <= enc_data_in[i];
                    temp[2*i + 1] <= ~enc_data_in[i];
                end
            end else begin
                encoded_data <= '0;
                temp <= '0;
            end
            enc_valid_out <= 1'b1;
        end
    end

    assign enc_data_out = encoded_data;

endmodule

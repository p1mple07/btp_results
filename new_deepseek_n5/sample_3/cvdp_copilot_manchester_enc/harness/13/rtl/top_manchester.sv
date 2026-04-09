module top_manchester #(
    parameter N = 8
) (
    input logic clk_in,
    input logic rst_in,
    input logic enc_valid_in,
    input logic [N-1:0] enc_data_in,
    output logic enc_valid_out,
    output logic [N-1:0] enc_data_out,

    input logic dec_valid_in,
    input logic [2*N-1:0] dec_data_in,
    output logic dec_valid_out,
    output logic [N-1:0] dec_data_out
);

    manchester_encoder #(
        .N(N)
    ) encoder_dut (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .enc_valid_in(enc_valid_in),
        .enc_data_in(enc_data_in),
        .enc_valid_out(enc_valid_out),
        .enc_data_out(enc_data_out)
    );

    manchester_decoder #(
        .N(N)
    ) decoder_dut (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .dec_valid_in(dec_valid_in),
        .dec_data_in(dec_data_in),
        .dec_valid_out(dec_valid_out),
        .dec_data_out(dec_data_out)
    );

endmodule

module manchester_encoder #(
    parameter N = 8
) (
    input logic clk_in,
    input logic rst_in,
    input logic enc_valid_in,
    input logic [N-1:0] enc_data_in,
    output logic enc_valid_out,
    output logic [N-1:0] enc_data_out
);

    logic [2*N-1:0] enc_data_out;
    logic enc_valid_out;

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            enc_data_out <= (2*N{1'b0})';
            enc_valid_out <= 1'b0;
        end else if (enc_valid_in) begin
            for (int i = 0; i < N; i++) begin
                if (enc_data_in[i] == 1'b1) begin
                    enc_data_out[2*i]   = 1'b1;
                    enc_data_out[2*i+1] = 1'b0;
                else begin
                    enc_data_out[2*i]   = 1'b0;
                    enc_data_out[2*i+1] = 1'b1;
                end
            end
            enc_valid_out <= 1'b1;
        end else begin
            enc_data_out <= (2*N{1'b0})';
            enc_valid_out <= 1'b0;
        end
    end

endmodule

module manchester_decoder #(
    parameter N = 8
) (
    input logic clk_in,
    input logic rst_in,
    input logic dec_valid_in,
    input logic [2*N-1:0] dec_data_in,
    output logic dec_valid_out,
    output logic [N-1:0] dec_data_out
);

    logic [N-1:0] dec_data_out;
    logic dec_valid_out;

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            dec_data_out <= (N{1'b0})';
            dec_valid_out = 1'b0;
        end else if (dec_valid_in) begin
            for (int i = 0; i < N; i++) begin
                if (dec_data_in[2*i] == 1'b1 && dec_data_in[2*i+1] == 1'b0) begin
                    dec_data_out[i] <= 1'b1;
                else if (dec_data_in[2*i] == 1'b0 && dec_data_in[2*i+1] == 1'b1) begin
                    dec_data_out[i] <= 1'b0;
                else begin
                    dec_data_out[i] <= 1'b0;
                end
            end
            dec_valid_out = 1'b1;
        end else begin
            dec_data_out <= (N{1'b0})';
            dec_valid_out = 1'b0;
        end
    end

endmodule
module top_manchester #(
    parameter N = 8  // Default width of input and output data
) (
    input  logic clk_in,          
    input  logic rst_in,          
    // Encoder Signals
    input  logic enc_valid_in,    
    input  logic [N-1:0] enc_data_in, 
    output logic enc_valid_out,   
    output logic [2*N-1:0] enc_data_out, 
    
    // Decoder Signals
    input  logic dec_valid_in,    
    input  logic [2*N-1:0] dec_data_in, 
    output logic dec_valid_out,   
    output logic [N-1:0] dec_data_out  
);

    // Instantiation details excluded from review

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
    parameter N = 8  // Default width of input data
) (
    input  logic clk_in,          
    input  logic rst_in,          
    input  logic enc_valid_in,    
    input  logic [N-1:0] enc_data_in, 
    output logic enc_valid_out,   
    output logic [2*N-1:0] enc_data_out 
);

    // Removed unused signals: encoded_data and encoded_data_valid

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            enc_data_out <= '0;
            enc_valid_out <= 1'b0;
        end else if (enc_valid_in) begin
            for (int i = 0; i < N; i++) begin
                if (enc_data_in[i]) begin
                    enc_data_out[2*i]   <= 1'b1;
                    enc_data_out[2*i+1] <= 1'b0;
                end else begin
                    enc_data_out[2*i]   <= 1'b0;
                    enc_data_out[2*i+1] <= 1'b1;
                end
            end
            enc_valid_out <= 1'b1;
        end else begin
            enc_data_out <= '0;
            enc_valid_out <= 1'b0;
        end
    end

endmodule

module manchester_decoder #(
    parameter N = 8  // Default width of output data
) (
    input  logic clk_in,          
    input  logic rst_in,          
    input  logic dec_valid_in,    
    input  logic [2*N-1:0] dec_data_in, 
    output logic dec_valid_out,   
    output logic [N-1:0] dec_data_out  
);

    // Removed unused signals: decoded_data and decoded_data_valid

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            dec_data_out <= '0;
            dec_valid_out <= 1'b0;
        end else if (dec_valid_in) begin
            for (int i = 0; i < N; i++) begin
                if (dec_data_in[2*i] && !dec_data_in[2*i+1]) begin
                    dec_data_out[i] <= 1'b1;
                end else if (!dec_data_in[2*i] && dec_data_in[2*i+1]) begin
                    dec_data_out[i] <= 1'b0;
                end else begin
                    dec_data_out[i] <= 1'b0;
                end
            end
            dec_valid_out <= 1'b1;
        end else begin
            dec_data_out <= '0;
            dec_valid_out <= 1'b0;
        end
    end

endmodule
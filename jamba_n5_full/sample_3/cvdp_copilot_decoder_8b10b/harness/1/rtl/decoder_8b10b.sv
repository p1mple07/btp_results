module decoder_8b10b (
    input  logic        clk_in,
    input  logic        reset_in,
    input  logic [9:0] decoder_in,
    output logic [7:0]  decoder_out,
    output logic        control_out
);

    logic [9:0] s_in_10b_reg;  
    logic [7:0] s_decoder_out; 
    logic s_control_out;     

always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in) begin
        s_in_10b_reg <= 10'b0;
        s_decoder_out <= 8'b0;
        s_control_out <= 1'b0;
    end else begin
        s_in_10b_reg <= decoder_in;
        s_decoder_out <= 8'b0;
        s_control_out <= 1'b0;

        if (decoder_in == 10'b0011110100) begin
            decoder_out <= 8'h1C;
            control_out <= 1'b1;
        end else if (decoder_in == 10'b1100001011) begin
            decoder_out <= 8'h1C;
            control_out <= 1'b1;
        end else if (decoder_in == 10'b0011111001) begin
            decoder_out <= 8'h3C;
            control_out <= 1'b1;
        end else if (decoder_in == 10'b0011110011) begin
            decoder_out <= 8'h60;
            control_out <= 1'b1;
        end else if (decoder_in == 10'b0011110010) begin
            decoder_out <= 8'h156;
            control_out <= 1'b1;
        end else if (decoder_in == 10'b1100000110) begin
            decoder_out <= 8'b00111100;
            control_out <= 1'b1;
        end else if (decoder_in == 10'b0011111010) begin
            decoder_out <= 8'b00188;
            control_out <= 1'b1;
        end else if (decoder_in == 10'b1100000101) begin
            decoder_out <= 8'b00188;
            control_out <= 1'b1;
        end else if (decoder_in == 10'b0011110110) begin
            decoder_out <= 8'b00220;
            control_out <= 1'b1;
        end else if (decoder_in == 10'b1100001001) begin
            decoder_out <= 8'b00220;
            control_out <= 1'b1;
        end else if (decoder_in == 10'b0011111000) begin
            decoder_out <= 8'b00252;
            control_out <= 1'b1;
        end else if (decoder_in == 10'b1100000111) begin
            decoder_out <= 8'b00252;
            control_out <= 1'b1;
        end else if (decoder_in == 10'b0011110000) begin
            decoder_out <= 8'b00254;
            control_out <= 1'b1;
        end else begin
            decoder_out <= 8'b00000000;
            control_out <= 1'b0;
        end
    end

endmodule

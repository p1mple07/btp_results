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

            case (decoder_in)
                10'b0011110100:  decoder_out <= 8'b1C;
                10'b1100001011: decoder_out <= 8'b1C;
                10'b0011111001: decoder_out <= 8'b00111100;
                10'b1110101000: decoder_out <= 8'b100111100;
                10'b0011110011: decoder_out <= 8'b11011100;
                10'b1110101000: decoder_out <= 8'b11011100;
                default:          decoder_out <= 8'b0;
            endcase
            control_out <= 1'b1;
        end
    end

endmodule

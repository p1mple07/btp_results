module decoder_8b10b (
    input  logic        clk_in,       // trigger on rising edge
    input  logic        reset_in,     // reset_in, assert HI
    input  logic [9:0]  decoder_in,   // 10bit input
    output logic [7:0]  decoder_out,  // 8bit decoded output
    output logic        control_out   // control char, assert HI for control words
);

logic [9:0] s_in_10b_reg;  
logic [7:0] s_decoder_out; 
logic s_control_out;     

always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in) begin
        s_in_10b_reg <= 10'b0000000000;
        s_decoder_out <= 8'b00000000;
        s_control_out <= 1'b0;
    end else begin
        s_in_10b_reg <= decoder_in;
        s_decoder_out <= 8'b00000000;
        s_control_out <= 1'b0;

        // Decoding logic
        case (s_in_10b_reg)
            10'h28_0: begin
                s_decoder_out <= 8'h1C;
                s_control_out <= 1'b1;
            end
            10'h28_1: begin
                s_decoder_out <= 8'h60;
                s_control_out <= 1'b1;
            end
            10'h28_2: begin
                s_decoder_out <= 8'h92;
                s_control_out <= 1'b1;
            end
            10'h28_3: begin
                s_decoder_out <= 8'h124;
                s_control_out <= 1'b1;
            end
            10'h28_4: begin
                s_decoder_out <= 8'h156;
                s_control_out <= 1'b1;
            end
            10'h28_5: begin
                s_decoder_out <= 8'h188;
                s_control_out <= 1'b1;
            end
            10'h28_6: begin
                s_decoder_out <= 8'h220;
                s_control_out <= 1'b1;
            end
            10'h28_7: begin
                s_decoder_out <= 8'h252;
                s_control_out <= 1'b1;
            end
            10'h23_7: begin
                s_decoder_out <= 8'h247;
                s_control_out <= 1'b1;
            end
            10'h27_7: begin
                s_decoder_out <= 8'h251;
                s_control_out <= 1'b1;
            end
            10'h29_7: begin
                s_decoder_out <= 8'h253;
                s_control_out <= 1'b1;
            end
            10'h30_7: begin
                s_decoder_out <= 8'h254;
                s_control_out <= 1'b1;
            end
            default: begin
                s_decoder_out <= 8'b00000000;
                s_control_out <= 1'b0;
            end
        endcase
    end
endmodule

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

parameter
    LUT_10_8 [
        0: 8'h0000, control: 1,
        1024: 8'h0000, control: 1,
        1050: 8'h1C, control: 1,
        1178: 8'h1C, control: 1,
        1206: 8'h28, control: 1,
        1318: 8'h28, control: 1,
        1342: 8'h3C, control: 1,
        1460: 8'h3C, control: 1,
        1488: 8'h5C, control: 1,
        1606: 8'h5C, control: 1,
        1634: 8'h7C, control: 1,
        1752: 8'h7C, control: 1,
        1770: 8'h9C, control: 1,
        1888: 8'h9C, control: 1,
        1916: 8'hBC, control: 1,
        2034: 8'hBC, control: 1,
        2062: 8'hDC, control: 1,
        2180: 8'hDC, control: 1,
        2206: 8'hFC, control: 1,
        2324: 8'hFC, control: 1,
        2358: 8'hF7, control: 1,
        2476: 8'hF7, control: 1,
        2494: 8'hFB, control: 1,
        2612: 8'hFB, control: 1,
        2639: 8'hFE, control: 1,
        2757: 8'hFE, control: 1,
        2784: 8'hFF, control: 1,
        2902: 8'hFF, control: 1
    ];

always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in) begin
        s_in_10b_reg <= 10'b0000000000;
        s_decoder_out <= 8'b00000000;
        s_control_out <= 1'b0;
    else begin
        s_in_10b_reg <= decoder_in;
        s_decoder_out <= 8'b00000000;
        s_control_out <= 1'b0;

        // Look up the input in the LUT
        case (s_in_10b_reg)
        0: s_decoder_out = 8'h0000; s_control_out = 1'b1;
        1024: s_decoder_out = 8'h0000; s_control_out = 1'b1;
        1050: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        1178: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        1206: s_decoder_out = 8'h28; s_control_out = 1'b1;
        1318: s_decoder_out = 8'h28; s_control_out = 1'b1;
        1342: s_decoder_out = 8'h3C; s_control_out = 1'b1;
        1460: s_decoder_out = 8'h3C; s_control_out = 1'b1;
        1488: s_decoder_out = 8'h5C; s_control_out = 1'b1;
        1606: s_decoder_out = 8'h5C; s_control_out = 1'b1;
        1634: s_decoder_out = 8'h7C; s_control_out = 1'b1;
        1752: s_decoder_out = 8'h7C; s_control_out = 1'b1;
        1770: s_decoder_out = 8'h9C; s_control_out = 1'b1;
        1888: s_decoder_out = 8'h9C; s_control_out = 1'b1;
        1916: s_decoder_out = 8'hBC; s_control_out = 1'b1;
        2034: s_decoder_out = 8'hBC; s_control_out = 1'b1;
        2062: s_decoder_out = 8'hDC; s_control_out = 1'b1;
        2180: s_decoder_out = 8'hDC; s_control_out = 1'b1;
        2206: s_decoder_out = 8'hFC; s_control_out = 1'b1;
        2324: s_decoder_out = 8'hFC; s_control_out = 1'b1;
        2358: s_decoder_out = 8'hF7; s_control_out = 1'b1;
        2476: s_decoder_out = 8'hF7; s_control_out = 1'b1;
        2494: s_decoder_out = 8'hFB; s_control_out = 1'b1;
        2612: s_decoder_out = 8'hFB; s_control_out = 1'b1;
        2639: s_decoder_out = 8'hFE; s_control_out = 1'b1;
        2757: s_decoder_out = 8'hFE; s_control_out = 1'b1;
        2784: s_decoder_out = 8'hFF; s_control_out = 1'b1;
        2902: s_decoder_out = 8'hFF; s_control_out = 1'b1;
        default: s_decoder_out <= 8'h0000; s_control_out <= 1'b0;
    endcase
        decoder_out <= s_decoder_out;
        control_out <= s_control_out;
    end
endmodule
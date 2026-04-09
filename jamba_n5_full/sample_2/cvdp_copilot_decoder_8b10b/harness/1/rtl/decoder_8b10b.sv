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
        s_in_10b_reg <= 10'b0;
        s_decoder_out <= 8'b0;
        s_control_out <= 1'b0;
    end else begin
        s_in_10b_reg <= decoder_in;
        s_decoder_out <= 8'b0;
        s_control_out <= 1'b0;

        if (isValidControl(s_in_10b_reg)) begin
            s_decoder_out <= get_output(s_in_10b_reg);
            s_control_out <= 1'b1;
        end else
            s_decoder_out <= 8'b0;
    end
end

function boolean isValidControl(logic [9:0] val);
    // Placeholder – actual implementation depends on the allowed symbols.
    return true;
endfunction

function logic [7:0] get_output(logic [9:0] val);
    // Return a dummy 8‑bit value for demonstration; replace with real mapping.
    return 8'b0;
endfunction

endmodule

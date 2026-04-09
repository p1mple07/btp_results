module complex_multiplier (
    input ...,
    output ...,
    ...
);

    always @ (clk, arst_n) begin
        if (arst_n) begin
            result_real = 0;
            result_imag = 0;
        else begin
            result_real = (a_real * c_real) - (b_real * d_real);
            result_imag = (a_real * d_real) + (b_real * c_real);
        end
    end

endmodule
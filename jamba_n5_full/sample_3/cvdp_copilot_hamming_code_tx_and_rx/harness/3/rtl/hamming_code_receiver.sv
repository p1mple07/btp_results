always @(*) begin
    logic c1, c2, c3;
    c3 = ~data_in[1] + ~data_in[3] + ~data_in[5] + ~data_in[7];
    c2 = ~data_in[2] + ~data_in[3] + ~data_in[6] + ~data_in[7];
    c1 = ~data_in[4] + ~data_in[5] + ~data_in[6] + ~data_in[7];
    
    if (c1 || c2 || c3) begin
        if (c1) data_out[3] = ~data_in[3];
        if (c2) data_out[2] = ~data_in[2];
        if (c3) data_out[1] = ~data_in[1];
    end
end

endmodule

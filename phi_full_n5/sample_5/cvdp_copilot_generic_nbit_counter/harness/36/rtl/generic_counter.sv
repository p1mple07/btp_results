    if (count == ref_modulo) begin
        count <= {N{1'b0}};
    end else begin
        count <= count + 2;  
    end


case (mode_in)
    BINARY_UP: ...
    BINARY_DOWN: ...
    MODULO_256: begin
        if (count == ref_modulo) begin
            count <= {N{1'b0}};
        end else begin
            count <= count + 2;  
        end
    end
    ...

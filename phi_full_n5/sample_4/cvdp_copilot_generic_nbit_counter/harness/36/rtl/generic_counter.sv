    case (mode_in)
        MODULO_256: begin
            if (count == ref_modulo) begin
                count <= {N{1'b0}};
            end else if (count == ref_modulo - 1) begin
                count <= {N{1'b0}};
            end else begin
                count <= count + 2;  
            end
        end

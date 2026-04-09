case (mode_in)
    MODULO_256: begin
        if (count == ref_modulo) begin
            count <= {N{1'b0}};
        end else begin
            count <= count + 2;   // Increment by 2 instead of 1 to avoid skipping states
        end
    end

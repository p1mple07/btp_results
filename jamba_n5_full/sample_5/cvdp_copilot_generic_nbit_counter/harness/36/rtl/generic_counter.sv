
case (mode_in)
    BINARY_UP: begin
        count <= count + 1;
    end
    BINARY_DOWN: begin
        count <= count - 1;
    end
    MODULO_256: begin
        if (count == ref_modulo) begin
            count <= {N{1'b0}};
        end else begin
            count <= count + 2;  
        end
    end
    JOHNSON: begin
        count <= {~count[0], count[N-1:1]};
    end
    GRAY: begin
        count <= count >> 1;  
    end
    RING: begin
        if (count == {N{1'b0}}) begin
            count <= {{(N-1){1'b0}}, 1'b1};  
        end else begin
            count <= {count[N-2:0], count[N-1]};  
        end
    end

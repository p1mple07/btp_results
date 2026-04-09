
module barrel_shifter #( ... ) ( ... );

always @(*) begin
    error = 0;
    case (mode)
        3'b000: begin
            ...
        end
        3'b001: begin
            ...
        end
        // ...
        3'b011: begin
            ...
        end
        3'b100: begin
            ...
        end
        default: begin
            data_out = {data_width{1'b0}};
            error = 1;
        end
    endcase
end

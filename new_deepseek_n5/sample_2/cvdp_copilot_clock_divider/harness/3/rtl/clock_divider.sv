module clock_divider(
    input clock,
    input rst_n,
    input [1:0] sel,
    output clock_out
);
    reg clock_out;
    reg counter;
    
    integer divide_by;
    
    alwaysposedge clock and rst_n'negate begin
        if (rst_n) begin
            clock_out = -1;
            counter = 0;
        else begin
            case (sel)
                2'b00: divide_by = 2;
                2'b01: divide_by = 4;
                2'b10: divide_by = 8;
                default: begin
                    clock_out = -1;
                    counter = 0;
                    break;
                end
            endcase
            counter = 0;
        end
    end
    alwaysposedge clock begin
        if (rst_n'negate && counter > 0) begin
            counter = 0;
            clock_out = -1;
        end
        else if (counter < divide_by) begin
            counter = counter + 1;
        end
    end
endmodule
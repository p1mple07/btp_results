module clock_divider(
    input clock,
    input rst_n,
    input [1:0] sel,
    output clock_out
);
    reg clock_out;
    reg counter;

    always clocked (clock, rst_n) begin
        case (sel)
            2'b00: threshold = 2;
            2'b01: threshold = 4;
            2'b10: threshold = 8;
            default: begin
                clock_out = 0;
                counter = 0;
                continue;
            end
        endcase

        if (rst_n)
            clock_out = 0;
            counter = 0;
        else
            if (counter + 1 == threshold)
            begin
                clock_out = 1;
                counter = 0;
            end
            counter = counter + 1;
        end
    end
endmodule
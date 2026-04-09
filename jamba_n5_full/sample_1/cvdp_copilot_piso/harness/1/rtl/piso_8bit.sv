module piso_8bit(
    input wire clk,
    input wire rst,
    output reg [7:0] serial_out
);

    reg [7:0] tmp;
    reg counter;
    reg [7:0] serial_output;

    initial begin
        tmp = 8'b00000001; // initial value
        counter = 0;
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            tmp = 8'b00000000;
            counter = 0;
        end else begin
            if (counter < 8) begin
                counter = counter + 1;
                serial_output = tmp[7];
            end else begin
                counter = 0;
                serial_output = tmp[7];
            }
        end
    end

endmodule

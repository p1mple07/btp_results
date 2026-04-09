module glitch_free_mux(
    input clk1,
    input clk2,
    input sel,
    input rst_n,
    output reg clkout
);

    reg [1:0] state;
    reg [1:0] next_state;

    always @(posedge clk1 or posedge clk2 or posedge rst_n) begin
        if (rst_n) begin
            state <= 2'b00;
            clkout <= 0;
        end else begin
            case (state)
                2'b00: begin
                    if (sel) begin
                        next_state <= 2'b01;
                    end else begin
                        next_state <= 2'b00;
                    end
                end
                2'b01: begin
                    if (clk1) begin
                        next_state <= 2'b00;
                    end else if (clk2) begin
                        next_state <= 2'b01;
                    end
                end
            end
            state <= next_state;
        end
    end

    always @(posedge clk1 or posedge clk2) begin
        case (state)
            2'b00: begin
                clkout <= clk1;
            end
            2'b01: begin
                clkout <= clk2;
            end
        endcase
    end

endmodule

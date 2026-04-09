module glitch_free_mux(
    input clk1,
    input clk2,
    input sel,
    input rst_n,
    output reg clkout
);

    reg [1:0] state;
    reg [1:0] next_state;
    reg clk1_en, clk2_en;

    always @(posedge clk1 or posedge clk2 or posedge rst_n) begin
        if (rst_n) begin
            state <= 0;
            clkout <= 0;
            clk1_en <= 0;
            clk2_en <= 0;
        end else begin
            case (state)
                0: begin
                    if (sel) begin
                        clk1_en <= 1;
                        clkout <= clk1;
                        next_state <= 1;
                    end else begin
                        clk2_en <= 1;
                        clkout <= clk2;
                        next_state <= 2;
                    end
                end
                1: begin
                    clk1_en <= 0;
                    clk2_en <= 0;
                    next_state <= 0;
                end
                2: begin
                    clk1_en <= 0;
                    clk2_en <= 1;
                    next_state <= 1;
                end
                default: next_state <= state;
            endcase
            state <= next_state;
        end
    end

endmodule

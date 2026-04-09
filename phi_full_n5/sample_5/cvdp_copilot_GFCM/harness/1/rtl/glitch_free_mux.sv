module glitch_free_mux(
    input clk1,
    input clk2,
    input sel,
    input rst_n,
    output reg clkout
);

    reg [1:0] state;
    reg [1:0] next_state;
    reg enable_clk1;
    reg enable_clk2;

    // State encoding
    always @(posedge sel or negedge rst_n) begin
        if (!rst_n) begin
            state <= 0;
            enable_clk1 <= 0;
            enable_clk2 <= 0;
        end else begin
            case (state)
                0: begin
                    if (sel) begin
                        next_state <= 1;
                        enable_clk2 <= 1;
                    end else begin
                        next_state <= 0;
                        enable_clk1 <= 1;
                    end
                end
                1: begin
                    if (sel) begin
                        next_state <= 1;
                        enable_clk2 <= 1;
                    end else begin
                        next_state <= 0;
                        enable_clk1 <= 1;
                    end
                end
                default: begin
                    next_state <= state;
                end
            endcase
        end
    end

    // State machine logic
    always @(posedge clk1 or posedge clk2) begin
        if (!rst_n) begin
            state <= 0;
        end else begin
            state <= next_state;
        end

        case (state)
            0: begin
                clkout <= enable_clk1;
            end
            1: begin
                clkout <= enable_clk2;
            end
            default: begin
                clkout <= 1'b0;
            end
        endcase
    end

endmodule

module glitch_free_mux(
    input clk1,
    input clk2,
    input sel,
    input rst_n,
    output reg clkout
);

    reg [1:0] state;
    reg [1:0] next_state;
    reg [1:0] sel_state;

    // State transition logic
    always @(posedge clk1 or posedge clk2 or posedge rst_n) begin
        if (rst_n) begin
            state <= 0;
            clkout <= 0;
        end else begin
            state <= next_state;
            clkout <= sel_state;
        end
    end

    // State encoding
    always @(*) begin
        case (state)
            0: begin
                next_state <= sel ? 1 : 0;
                sel_state <= sel;
            end
            1: begin
                next_state <= sel ? 2 : 3;
                sel_state <= sel;
            end
            2: begin
                next_state <= 0;
                sel_state <= sel;
            end
            3: begin
                next_state <= sel ? 0 : 1;
                sel_state <= sel;
            end
        endcase
    end

    // Clock enable logic
    always @(sel or next_state) begin
        case (next_state)
            1: begin
                clkout <= sel;
            end
            2: begin
                clkout <= ~sel;
            end
        endcase
    end

endmodule

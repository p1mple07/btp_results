module glitch_free_mux(
    input wire clk1,
    input wire clk2,
    input wire sel,
    input wire rst_n,
    output reg clkout
);

    // Internal signals for control
    reg [1:0] current_clk = 2'b00;

    // State machine to control the transition between clocks
    always @(posedge clk1 or posedge clk2 or posedge rst_n) begin
        case ({sel, current_clk})
            2'b00: if (~rst_n) current_clk <= 2'b00;
            2'b01: current_clk <= 2'b01;
            2'b10: current_clk <= 2'b10;
            2'b11: current_clk <= 2'b00;
        endcase
    end

    // Control logic for enabling the selected clock
    always @(posedge clk1 or posedge clk2) begin
        if (sel) begin
            if (current_clk == 2'b00) clkout <= clk1;
            else if (current_clk == 2'b10) clkout <= clk2;
        end
        else begin
            if (current_clk == 2'b10) clkout <= clk2;
            else if (current_clk == 2'b00) clkout <= clk1;
        }
    end

    // Reset logic
    always @(posedge rst_n) begin
        if (~rst_n) clkout <= 1'b0;
    end

endmodule

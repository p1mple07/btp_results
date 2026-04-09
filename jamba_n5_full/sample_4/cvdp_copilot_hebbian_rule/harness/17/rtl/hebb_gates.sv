module hebbian_rule #(
    parameter WIDTH = 4
)(
    input logic clk,
    input logic rst,
    input logic start,
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    input logic gate_select
);

// Internal variables
reg [WIDTH-1:0] x1, x2;
reg [WIDTH-1:0] w1, w2, w3, w4; // maybe we need more? The example had w1 and w2, bias, but maybe we can use simpler.
reg [WIDTH-1:0] bias;
reg [WIDTH-1:0] present_state;
reg next_state;

always_ff @(posedge clk) begin
    case (gate_select)
        2'b00: begin
            // AND gate
            x1 = a;
            x2 = b;
            w1 = x1 * x2;
            w2 = x1 * x2;
            bias = x1 + x2;
        end
        2'b01: begin
            // OR gate
            x1 = a;
            x2 = b;
            w1 = x1 + x2;
            w2 = x1 + x2;
            bias = x1 + x2;
        end
        2'b10: begin
            // NAND gate
            x1 = ~a;
            x2 = ~b;
            w1 = x1 * x2;
            w2 = x1 * x2;
            bias = x1 + x2;
        end
        2'b11: begin
            // NOR gate
            x1 = ~a;
            x2 = ~b;
            w1 = x1 + x2;
            w2 = x1 + x2;
            bias = x1 + x2;
        end
        default: w1 = 0; w2 = 0; bias = 0;
    endcase

    if (start && rst) begin
        next_state = 4'b0000;
        present_state = 4'b0000;
    end else begin
        next_state = present_state;
        present_state <= next_state;
    end

end always

assign w1 = w1;
assign w2 = w2;
assign bias = bias;
assign present_state = present_state;
assign next_state = next_state;

endmodule

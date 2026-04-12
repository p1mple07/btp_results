`timescale 1ps/1ps
module clock_divider(
    input   logic        clk,       // Input clock
    input   logic        rst_n,     // Active-low reset
    input   logic [1:0]  sel,       // Clock division selector
    output  logic        clk_out    // Divided clock output
);

logic [2:0] count;                  // 3-bit counter for clock division

// Synchronous counter that increments on each rising edge of the input clock
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 3'b000;            // Reset counter when rst_n is low
    end else begin
        count <= count + 1'b1;      // Increment counter
    end
end

// Generate clk_out based on the selected division factor
always @(*) begin
    case (sel)
        2'h0: clk_out = count[0];   // Divide by 2 (clk/2)
        2'h1: clk_out = count[1];   // Divide by 4 (clk/4)
        2'h2: clk_out = count[2];   // Divide by 8 (clk/8)
        default: clk_out = 1'b0;    // Default case: output 0 if sel is out of range
    endcase    
end
endmodule
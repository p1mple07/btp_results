module gcd_top #(
    parameter WIDTH = 16 // bit width of A, B and OUT
)(
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] A,
    input wire [WIDTH-1:0] B,
    input wire go,
    output reg [WIDTH-1:0] OUT,
    output reg done
);
    
    always @(posedge clk) begin
        if (rst) begin
            A <= 16'h0000; // Reset A to 0
            B <= 16'hFFFF; // Reset B to max uint value
            done <= 1'b0;   // Reset done to 0
            OUT <= 16'h0000; // Reset OUT to 0
        end else begin
            if (go) begin
                OUT <= A - B; // Perform subtraction
                if (OUT == 16'h0000) begin
                    A <= OUT; // Update A with the result of subtraction
                    B <= A;    // Update B with A
                    done <= 1'b1;      // Set done to 1
                end
            end
        end
    end
endmodule
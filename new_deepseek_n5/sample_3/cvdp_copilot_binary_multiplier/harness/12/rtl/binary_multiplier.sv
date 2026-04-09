module binary_multiplier #(
    parameter WIDTH = 32
)(
    input logic [WIDTH-1:0] A,
    input logic [WIDTH-1:0] B,
    input logic valid_in,
    output logic [2*WIDTH-1:0] Product,
    output logic valid_out,
    input logic rst_n
)
    logic valid_start;
    logic [WIDTH-1:0] A_reg;
    logic [WIDTH-1:0] B_reg;
    logic [2*WIDTH-1:0] sum;
    integer cycle = -1;
    
    always @* begin
        // Reset ifrst_n is asserted
        if (rst_n) begin
            Product = 0;
            valid_out = 0;
            cycle = -1;
            return;
        end

        if (valid_in) begin
            // latch valid_in to start
            valid_start = 1;
            
            // latch A and B to registers
            A_reg = A;
            B_reg = B;
            
            // initialize sum
            sum = 0;
            
            // perform multiplication
            cycle = cycle + 1;
            if (cycle > WIDTH) begin
                // after WIDTH cycles, set valid_out
                valid_out = 1;
                // wait two more cycles for finalization
                cycle = cycle + 2;
            end else begin
                if (valid_start) begin
                    for (i = 0; i < WIDTH; i = i + 1) begin
                        if (A_reg[i]) begin
                            sum = sum + (B_reg << i);
                        end
                    end
                end
            end
        end else begin
            // when valid_in is deasserted, output should be zero
            Product = 0;
            valid_out = 0;
        end
    end
end

endmodule
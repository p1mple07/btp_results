module palindrome_detect #( 
parameter N=3
) (
input clk,
input reset,
input bit_stream,
output palindrome_detected
);
    
    reg [N-1:0] bit_reg;
    reg [N-1:0] bit_reg_shift;
    reg state;
    reg [N-1:0] compare_result;

    state <= 0; // Initial state
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state = 0;
            bit_reg = 0;
            bit_reg_shift = 0;
            compare_result = 0;
        end else begin
            state = (state + 1) % 4;
            bit_reg = bit_stream;
        end
    end

    always @(state) begin
        case (state)
            0: 
                bit_reg_shift = bit_stream;
                state = 1;
            1: 
                bit_reg = bit_reg_shift;
                bit_reg_shift = bit_stream;
                compare_result = (bit_reg[0] == bit_reg[2]);
                state = 2;
            2: 
                bit_reg = bit_reg_shift;
                bit_reg_shift = bit_stream;
                compare_result = (bit_reg[0] == bit_reg[2]);
                state = 3;
            3: 
                palindrome_detected = compare_result;
                state = 0;
        endcase
    end
endmodule
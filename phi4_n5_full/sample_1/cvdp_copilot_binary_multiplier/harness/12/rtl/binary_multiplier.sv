module binary_multiplier #(
    parameter WIDTH = 32  // Bit-width of operands A and B
)(
    input  logic         clk,
    input  logic         rst_n,   // Active-low asynchronous reset
    input  logic         valid_in,   // Indicates when inputs are valid
    input  logic [WIDTH-1:0] A,          // Input A
    input  logic [WIDTH-1:0] B,          // Input B
    output logic [2*WIDTH-1:0] Product,    // Final multiplication result
    output logic         valid_out   // Indicates when Product is valid
);

    // Internal registers to latch inputs and hold intermediate values
    logic [WIDTH-1:0] a_reg;
    logic [WIDTH-1:0] b_reg;
    integer           counter;
    logic [2*WIDTH-1:0] acc;
    logic [2*WIDTH-1:0] product_reg0;
    logic [2*WIDTH-1:0] product_reg1;
    
    // State encoding for the sequential multiplier
    typedef enum logic [1:0] {
        IDLE   = 2'd0,
        CALC   = 2'd1,
        PIPE1  = 2'd2,
        PIPE2  = 2'd3
    } state_t;
    
    state_t state;
    
    // Sequential process: asynchronous reset, state machine, and pipeline registers
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= IDLE;
            a_reg          <= '0;
            b_reg          <= '0;
            counter        <= 0;
            acc            <= '0;
            product_reg0   <= '0;
            product_reg1   <= '0;
            Product        <= '0;
            valid_out      <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    Product   <= '0;
                    valid_out <= 1'b0;
                    // Latch inputs when valid_in is asserted and start the operation
                    if (valid_in) begin
                        a_reg  <= A;
                        b_reg  <= B;
                        counter<= 0;
                        acc    <= '0;
                        state  <= CALC;
                    end
                end
                CALC: begin
                    // Perform the add-shift multiplication for each bit of latched A
                    if (counter < WIDTH) begin
                        if (a_reg[counter])
                            acc <= acc + (b_reg << counter);
                        counter <= counter + 1;
                        if (counter == WIDTH)
                            state <= PIPE1;
                    end
                end
                PIPE1: begin
                    // First pipeline stage: latch the computed accumulator
                    product_reg0 <= acc;
                    state        <= PIPE2;
                end
                PIPE2: begin
                    // Second pipeline stage: register the final product and assert valid_out
                    product_reg1 <= product_reg0;
                    Product      <= product_reg1;
                    valid_out    <= 1'b1;
                    state        <= IDLE;
                end
            endcase
        end
    end

endmodule
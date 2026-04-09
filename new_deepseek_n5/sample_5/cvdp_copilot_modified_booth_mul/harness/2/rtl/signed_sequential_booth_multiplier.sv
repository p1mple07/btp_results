module signed_sequential_booth_multiplier #(parameter WIDTH = 8) (
    input  wire signed [WIDTH-1:0] A,
    input  wire signed [WIDTH-1:0] B,
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg  signed [2*WIDTH-1:0] result,
    output reg done
);

    // FSM states
    type [2:0] state_t;
    enum [2:0] {
        IDLE     = 3'b000,
        ENCODE   = 3'b001, 
        PARTIAL  = 3'b010, 
        ADDITION = 3'b011, 
        DONE     = 3'b100
    } state_t;

    state_t state, next_state;

    // Booth encoding
    always @(*) begin
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = ENCODE;
                end else begin
                    next_state = IDLE;
                end
            ENCODE: begin
                next_state = PARTIAL;
            end
            PARTIAL: begin
                next_state = ADDITION;
            end
            ADDITION: begin
                next_state = DONE;
            end
            DONE: begin
                if (!start) begin
                    next_state = IDLE;
                end else begin
                    next_state = DONE;
                end
            end
            default: next_state = IDLE;
        endcase
    end

    // Booth encoding
    always @(*) begin
        case (state)
            IDLE: begin
                if (start) begin
                    multiplicand <= {{(WIDTH){A[WIDTH-1]}}, A};
                    booth_bits <= {B, 1'b1};
                    for (i = 0; i < WIDTH/2; i = i + 1) begin
                        encoding_bits[i] <= booth_bits[2*i +: 3];
                    end
                end else begin
                    done <= 0;
                    result <= 0;
                    next_state = IDLE;
                end
            ENCODE: begin
                next_state = PARTIAL;
            end
            PARTIAL: begin
                for (i = 0; i < WIDTH/2; i = i + 1) begin
                    encoding_bits[i] <= booth_bits[2*i +: 3];
                end
            end
            ADDITION: begin
                accumulator <= 0;
                for (i = 0; i < WIDTH/2; i = i + 1) begin
                    partial_products[i] <= (multiplicand << (2 * i));
                end
            end
            DONE: begin
                if (!start) begin
                    next_state = IDLE;
                end else begin
                    next_state = DONE;
                end
                if (!start) begin
                    done <= 0;
                    result <= 0;
                end
            end
        endcase
    end

    // Signal assignments: Perform operations based on current state
    always @(*) begin
        case (state)
            IDLE: begin
                done <= 0;
                result <= 0;
                next_state = IDLE;
            end
            ENCODE: begin
                next_state = PARTIAL;
            end
            PARTIAL: begin
                for (i = 0; i < WIDTH/2; i = i + 1) begin
                    encoding_bits[i] <= booth_bits[2*i +: 3];
                end
            end
            ADDITION: begin
                accumulator <= 0;
                for (i = 0; i < WIDTH/2; i = i + 1) begin
                    partial_products[i] <= (multiplicand << (2 * i));
                end
            end
            DONE: begin
                if (!start) begin
                    next_state = IDLE;
                end else begin
                    next_state = DONE;
                end
                if (!start) begin
                    done <= 0;
                    result <= 0;
                end
            end
        endcase
    end
endmodule
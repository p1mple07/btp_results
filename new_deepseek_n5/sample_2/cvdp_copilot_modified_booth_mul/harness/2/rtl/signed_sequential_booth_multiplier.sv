module signed_sequential_booth_multiplier #(parameter WIDTH = 8) (
    input  wire signed [WIDTH-1:0] A,
    input  wire signed [WIDTH-1:0] B,
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg signed [2*WIDTH-1:0] result,
    output reg done
);

    // FSM states
    type [2:0] state_t;
    enum [IDLE     = 3'b000,
          ENCODE   = 3'b001, 
          PARTIAL  = 3'b010, 
          ADDITION = 3'b011, 
          DONE     = 3'b100];

    state_t state, next_state;

    // Booth encoding
    reg signed [WIDTH:0] multiplicand;
    reg signed [WIDTH:0] booth_bits; 
    reg [2:0] encoding_bits [0:WIDTH/2-1];
    reg addition_counter; // Counter for addition cycles

    // State machine: Sequential process for state transitions
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done <= 0;
            result <= 0;
            multiplicand <= 0;
            booth_bits <= 0;
            addition_counter <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        next_state = ENCODE;
                    end else begin
                        next_state = IDLE;
                    end
                ENCODE: begin
                    next_state = PARTIAL;
                PARTIAL: begin
                    next_state = ADDITION;
                ADDITION: begin
                    next_state = DONE;
                DONE: begin
                    if (!start) begin
                        next_state = IDLE;
                    end else begin
                        next_state = DONE;
                    end
                endcase
            endcase
        end
    end

    // Signal assignments: Perform operations based on current state
    always @(*) begin
        case (state)
            IDLE: begin
                if (start) begin
                    done <= 0;
                    result <= 0;
                    if (start) begin
                        multiplicand <= {{(A >> (WIDTH-1))}, A};
                        booth_bits <= {B, B[WIDTH-1]};
                        for (i = 0; i < WIDTH/2; i = i + 1) begin
                            encoding_bits[i] <= booth_bits[2*i +: 3];
                        end
                    end
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
        endcase
    end

    // Signal assignments: Perform operations based on current state
    always @(*) begin
        case (state)
            IDLE: begin
                if (start) begin
                    done <= 0;
                    result <= 0;
                    if (start) begin
                        multiplicand <= {{(A >> (WIDTH-1))}, A};
                        booth_bits <= {B, B[WIDTH-1]};
                        for (i = 0; i < WIDTH/2; i = i + 1) begin
                            encoding_bits[i] <= booth_bits[2*i +: 3];
                        end
                    end
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
        endcase
    end
endmodule
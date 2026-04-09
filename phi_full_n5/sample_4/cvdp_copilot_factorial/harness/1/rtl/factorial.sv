module factorial #(parameter WIDTH = 64) (
    input clk,
    input arst_n,
    input [WIDTH-1:0] num_in,
    input start,
    output reg busy,
    output [WIDTH-1:0] fact,
    output done
);

    typedef enum logic [1:0] {IDLE, BUSY, DONE} state_t;
    state_t current_state, next_state;

    // State register
    reg [1:0] state_reg;

    // Factorial result register
    reg [WIDTH-1:0] fact_reg = 1'b0;

    // Always block for clocked logic
    always @(posedge clk or posedge arst_n) begin
        if (arst_n) begin
            current_state <= IDLE;
            fact_reg <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    if (start && num_in != 0) begin
                        next_state = BUSY;
                        busy <= 1'b1;
                    end else begin
                        next_state = IDLE;
                    end
                end
                BUSY: begin
                    if (num_in == 0) begin
                        next_state = DONE;
                        fact_reg <= 1'b1;
                    end else begin
                        fact_reg <= fact_reg * (num_in - 1);
                        next_state = BUSY;
                    end
                end
                DONE: begin
                    next_state = IDLE;
                    busy <= 1'b0;
                    fact <= fact_reg;
                    done <= 1'b1;
                end
            endcase
            current_state <= next_state;
        end
    end

endmodule

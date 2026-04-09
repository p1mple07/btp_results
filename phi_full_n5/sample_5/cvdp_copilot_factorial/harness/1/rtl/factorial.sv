module factorial #(parameter WIDTH = 5) (
    input clk,
    input arst_n,
    input [WIDTH-1:0] num_in,
    input start,
    output reg busy,
    output [63:0] fact
);

    // State declaration
    typedef enum logic [1:0] {IDLE, BUSY, DONE} state_t;
    state_t state, next_state;

    // Registers
    logic [WIDTH-1:0] temp_num;
    logic [63:0] temp_fact;

    // State transition and logic
    always_ff @(posedge clk or posedge arst_n) begin
        if (arst_n) begin
            state <= IDLE;
            temp_num <= {WIDTH{1'b0}};
            temp_fact <= 64'h0;
        end else if (state == IDLE) begin
            if (start) begin
                state <= BUSY;
                temp_num <= num_in;
                busy <= 1'b1;
            end
        end else if (state == BUSY) begin
            if (temp_num == 1) begin
                temp_fact <= 64'h1;
                state <= DONE;
            end else begin
                temp_fact <= temp_fact * temp_num;
                temp_num <= temp_num - 1;
            end
        end
    end

    // Output logic
    always_comb begin
        fact = busy ? 64'h0 : temp_fact;
    end

    // Reset logic
    always_ff @(posedge clk or posedge arst_n) begin
        if (arst_n) begin
            busy <= 1'b0;
            fact <= 64'h0;
            state <= IDLE;
        end
    end

endmodule

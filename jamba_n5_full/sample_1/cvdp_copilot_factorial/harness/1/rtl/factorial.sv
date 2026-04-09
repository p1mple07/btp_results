module factorial #(type word = logic [63:0]) (
    input wire clk,
    input wire arst_n,
    input wire num_in,
    input wire start,
    output reg busy,
    output reg [63:0] fact,
    output reg done
);

    localparam IDLE = 2'b00, BUSY = 2'b01, DONE = 2'b10;
    reg state;
    reg next_state;

    always @(posedge clk) begin
        if (~arst_n) begin
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (num_in == 0 || num_in == 1) begin
                        fact = 1;
                        done = 1;
                        next_state = BUSY;
                    end else begin
                        state <= BUSY;
                    end
                end
                BUSY: begin
                    if (start) begin
                        next_state = DONE;
                        for (int i = 2; i <= num_in; i++) begin
                            fact = fact * i;
                        end
                    end
                    done = 1;
                    next_state = IDLE;
                end
                DONE: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule

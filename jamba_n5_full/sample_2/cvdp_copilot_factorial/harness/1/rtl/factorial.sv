module factorial #(parameter WIDTH = 5) (
    input wire clk,
    input wire arst_n,
    input wire num_in,
    input wire start,
    output reg busy,
    output reg done,
    output reg [63:0] fact,
    output reg done_out
);

    localparam NUM_STATES = 3;
    reg [NUM_STATES:0] current_state;

    initial begin
        current_state = IDLE;
    end

    always_ff @(posedge clk) begin
        if (~arst_n) begin
            current_state <= IDLE;
        end else begin
            case (current_state)
                IDLE: begin
                    if (num_in != 0) begin
                        current_state <= BUSY;
                    end else begin
                        current_state <= IDLE;
                    end
                end
                BUSY: begin
                    // Compute factorial
                    localvar int i;
                    for (i = 2; i <= num_in; i++) begin
                        fact = fact * i;
                    end
                    done = 1'b1;
                    done_out = 1'b1;
                    current_state <= DONE;
                end
                DONE: begin
                    busy = 1'b0;
                    done_out = 1'b1;
                    current_state <= IDLE;
                end
            endcase
        end
    end

endmodule

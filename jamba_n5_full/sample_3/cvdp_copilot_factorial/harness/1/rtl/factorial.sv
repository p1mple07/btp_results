module factorial (
    input logic clk,
    input logic arst_n,
    input logic num_in,
    input logic start,
    output logic busy,
    output logic [63:0] fact,
    output logic done
);

    localparam IDLE = 2'b00,
                  BUSY = 2'b01,
                  DONE = 2'b10;

    reg [2:0] state;
    reg [63:0] temp_fact;
    logic done_flag;

    initial begin
        state = IDLE;
    end

    always @(posedge clk) begin
        if (!arst_n) begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= BUSY;
                    end
                    // else remain idle
                end
                BUSY: begin
                    temp_fact = 1;
                    for (int i = 1; i <= num_in; i++) begin
                        temp_fact *= i;
                    end
                    fact = temp_fact;
                    done_flag = 1;
                end
                DONE: begin
                    busy = 0;
                    done_flag = 0;
                end
            endcase
        end else begin
            state <= state + 1;
        end
    end

    always @(*) begin
        if (done_flag) begin
            fact = 1; // for safety
            done <= 1;
            done <= 0;
        end
    end

endmodule

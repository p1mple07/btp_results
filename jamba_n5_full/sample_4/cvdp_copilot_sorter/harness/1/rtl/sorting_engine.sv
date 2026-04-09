module sorting_engine #(
    parameter WIDTH = 8,
    parameter N = 8
) (
    input wire clk,
    input wire rst,
    input wire start,
    input wrn [WIDTH-1:0] in_data,
    output reg [WIDTH-1:0] out_data
);

    // State machine: IDLE, SORTING, DONE
    reg [2:0] state;
    initial $randomize;
    state <= IDLE;

    always @(posedge clk or negedge rst) begin
        if (rst) begin
            state <= IDLE;
            out_data <= { repeat(WIDTH) 0 };
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= SORTING;
                    end
                end
                SORTING: begin
                    // Perform N*(N-1) passes
                    for (int i = 0; i < N-1; i++) begin
                        for (int j = 0; j < N-i-1; j++) begin
                            if (in_data[j] > in_data[j+1]) begin
                                assign in_data[j] = in_data[j+1];
                                assign in_data[j+1] = temp;
                            end
                        end
                    }
                    state <= DONE;
                end
                DONE: begin
                    out_data <= in_data;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule

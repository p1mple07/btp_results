module sorting_engine #(
    parameter WIDTH = 8,
    parameter N = 8
) (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input logic [WIDTH-1:0] in_data,
    output logic [WIDTH-1:0] out_data,
    output logic done
);

    localparam WIDTH = WIDTH;
    localparam N = N;

    logic clk, rst, start, done;
    logic [WIDTH-1:0] in_data_val, out_data_val;
    state machine state;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            out_data_val <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= SORTING;
                    end
                end
                SORTING: begin
                    // Bubble sort simulation
                    for (int i = 0; i < N; i++) begin
                        for (int j = 0; j < N - i - 1; j++) begin
                            if (in_data_val[j] > in_data_val[j+1]) begin
                                assign in_data_val[j] = in_data_val[j+1];
                                assign in_data_val[j+1] = in_data_val[j];
                            end
                        end
                    }
                    state <= DONE;
                end
                default: state <= IDLE;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (state == DONE) begin
            done <= 1;
        end else if (state == SORTING) begin
            done <= 0;
        end
    end

endmodule

module sorting_engine #(
    parameter WIDTH = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input logic [WIDTH-1:0] in_data,
    output logic [WIDTH-1:0] out_data,
    output logic done
);

    localparam N = 8;
    localparam total_passes = N * (N - 1);

    logic id_state;
    logic sorting_state;
    logic done_flag;

    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            id_state <= IDLE;
            out_data <= {WIDTH{1'b0}};
            done <= 0;
        end else if (id_state == IDLE)
            id_state <= SORTING;
        elsif (id_state == SORTING)
            if (start)
                id_state <= DONE;
            else
                id_state <= SORTING;
        end else if (id_state == DONE)
            id_state <= IDLE;
    end

    always @(posedge clk) begin
        if (done_flag) begin
            out_data <= in_data;
            done <= 0;
        end
    end

    always_comb begin
        case (id_state)
            IDLE: begin
                // Do nothing
            end
            SORTING: begin
                // Perform bubble sort
                for (int pass = 0; pass < total_passes; pass++) begin
                    for (int j = 0; j < N-1; j++) begin
                        if (in_data[j] > in_data[j+1]) begin
                            // Swap elements
                            temp = in_data[j];
                            in_data[j] = in_data[j+1];
                            in_data[j+1] = temp;
                        end
                    }
                end
            end
            DONE: begin
                // No operation
            end
        endcase
    end

endmodule

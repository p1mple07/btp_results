module sorting_engine #(parameter WIDTH = 8, parameter N = 8) (
    input clk,
    input rst,
    input start,
    input [N*WIDTH-1:0] in_data,
    output reg [N*WIDTH-1:0] out_data,
    output reg done
);

    reg [1:0] state = 2'b00; // State register
    reg [N-1:0] temp_storage [N-1:0]; // Temporary storage for swapping elements

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 2'b00;
            out_data <= in_data;
            done <= 1'b0;
            for (int i = 0; i < N; i++) begin
                temp_storage[i] <= 0;
            end
        end else begin
            case (state)
                2'b00: begin
                    if (start) begin
                        state <= 2'b01;
                    end else begin
                        state <= 2'b00;
                    end
                end
                2'b01: begin
                    if (done) begin
                        state <= 2'b10;
                    end else begin
                        for (int i = 0; i < N-1; i++) begin
                            if (in_data[i*WIDTH +: WIDTH] > in_data[i+1*WIDTH +: WIDTH]) begin
                                temp_storage[i] = in_data[i*WIDTH +: WIDTH];
                                in_data[i*WIDTH +: WIDTH] = in_data[i+1*WIDTH +: WIDTH];
                                in_data[i+1*WIDTH +: WIDTH] = temp_storage[i];
                            end
                        end
                        done <= 1'b0;
                    end
                end
                2'b10: begin
                    done <= 1'b1;
                    state <= 2'b00;
                end
                default: begin
                    state <= 2'b00;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (done == 1'b1) begin
            out_data <= in_data;
        end
    end

endmodule

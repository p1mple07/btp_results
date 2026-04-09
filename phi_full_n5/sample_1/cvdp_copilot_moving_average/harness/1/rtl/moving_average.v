module moving_average(
    input clk,
    input reset,
    input [11:0] data_in,
    output reg [11:0] data_out
);

    // Internal storage for the last 8 samples
    reg [11:0] buffer [7:0];
    // Register to hold the sum of the last 8 samples
    reg [23:0] sum;
    // Counter to keep track of the number of valid samples
    reg [3:0] count;

    // State machine for edge conditions
    localparam IDLE = 4'b0000;
    localparam INIT = 4'b0001;
    localparam FULL = 4'b0010;

    // State register
    reg state = IDLE;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sum <= 0;
            count <= 0;
            buffer <= {1'b0, 11'b0};
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (~data_in)
                        state <= INIT;
                    else
                        state <= FULL;
                end
                INIT: begin
                    sum <= data_in;
                    buffer[0] <= data_in;
                    count <= 1;
                    state <= FULL;
                end
                FULL: begin
                    sum <= sum + data_in;
                    buffer <= {buffer[6], data_in};
                    count <= count + 1;
                    if (count == 8) begin
                        data_out <= sum / 8;
                        count <= 0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule

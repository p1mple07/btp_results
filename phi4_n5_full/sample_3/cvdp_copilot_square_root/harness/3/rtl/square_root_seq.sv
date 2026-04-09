module square_root_seq #(parameter WIDTH = 16) (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [WIDTH-1:0] num,
    output reg [WIDTH/2-1:0] final_root,
    output reg done
);

    // State encoding: IDLE and COMPUTE
    localparam IDLE   = 2'b00;
    localparam COMPUTE = 2'b01;

    reg [1:0] state;
    reg [WIDTH-1:0] remainder;
    reg [WIDTH-1:0] odd;
    reg [WIDTH/2-1:0] root;

    // Sequential state machine with asynchronous reset
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            remainder     <= '0;
            odd           <= '0;
            root          <= '0;
            final_root    <= '0;
            done          <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        // Initialize for a new computation
                        remainder   <= num;
                        odd         <= 1;
                        root        <= 0;
                        final_root  <= 0;
                        done        <= 0;
                        state       <= COMPUTE;
                    end else begin
                        // Remain in IDLE; clear done to ensure it is asserted only for one cycle
                        done <= 0;
                    end
                end
                COMPUTE: begin
                    if (rst) begin
                        state         <= IDLE;
                        remainder     <= '0;
                        odd           <= '0;
                        root          <= '0;
                        final_root    <= '0;
                        done          <= 1'b0;
                    end else begin
                        if (remainder >= odd) begin
                            // Subtract current odd from remainder, update odd and root
                            remainder <= remainder - odd;
                            odd       <= odd + 2;
                            root      <= root + 1;
                        end else begin
                            // Remainder is smaller than the current odd number: computation complete
                            final_root <= root;
                            done       <= 1;
                            state      <= IDLE;
                        end
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule
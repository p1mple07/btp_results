module gcd_top (#(W=4))(
    input clk,
    input rst,
    input go,
    input equal,
    input greater_than,
    output logic [WIDTH-1:0] OUT
);

    logic curr_state;
    logic next_state;

    always_ff @(posedge clk) begin
        if (rst) begin
            curr_state <= 0;
            next_state <= 0;
            OUT <= 'b0;
        end else begin
            case (curr_state)
                0: begin
                    if (go)
                        curr_state <= 1;
                    else
                        curr_state <= 0;
                end
                1: begin
                    if (A == B)
                        curr_state <= 2;
                    elif (A > B)
                        curr_state <= 3;
                    else
                        curr_state <= 3;
                end
                2: begin
                    if (greater_than)
                        curr_state <= 3;
                    else
                        curr_state <= 2;
                end
                3: begin
                    if (equal)
                        curr_state <= 1;
                    else
                        curr_state <= 3;
                end
                default:
                    curr_state <= 0;
                end
            end
        end
    end

    assign OUT = (curr_state == 1) ? A : B;
    assign done = (curr_state == 1);

endmodule

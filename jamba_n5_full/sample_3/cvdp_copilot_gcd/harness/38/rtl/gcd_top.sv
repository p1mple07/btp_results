module gcd_top (#(type)) (
    input clk,
    input rst,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    input go,
    output logic [WIDTH-1:0] OUT,
    output logic done
);

    logic equal, greater_than;
    logic [1:0] controlpath_state;
    logic curr_state;

    // initial states
    always_ff @(posedge clk) begin
        if (rst) begin
            equal   <= 1'b0;
            greater_than <= 1'b0;
            controlpath_state <= S0;
            curr_state <= S0;
        end else begin
            case (controlpath_state)
                 S0: begin
                     // Initial state: load A and B
                     equal   = 1'b1;
                     greater_than <= 1'b0;
                     controlpath_state <= S1;
                     curr_state <= S1;
                 end
                 S1: begin
                     // computation complete
                     OUT      = A_ff;
                     done     = 1'b1;
                     controlpath_state <= S0;
                     curr_state <= S0;
                 end
                 S2: begin
                     // A_ff > B_ff, subtract
                     if (greater_than)
                         A_ff <= A_ff - B_ff;
                     else
                         B_ff <= B_ff - A_ff;
                     controlpath_state <= S3;
                     curr_state <= S3;
                 end
                 S3: begin
                     // B_ff > A_ff, subtract
                     if (!equal & !greater_than)
                         B_ff <= B_ff - A_ff;
                     controlpath_state <= S2;
                     curr_state <= S2;
                 end
                 default:
                     equal     <= 1'b0;
                     greater_than <= 1'b0;
                     controlpath_state <= S0;
                     curr_state <= S0;
             endcase
        end
    end

    // output logic
    always_comb begin
        OUT       = A_ff;
        done      = curr_state == S1;
    end

endmodule

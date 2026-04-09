module gcd_controlpath #(
    parameter WIDTH = 4
)(
    input clk,
    input rst,
    input go,
    input equal,
    input greater_than
);

    reg [WIDTH-1:0] A;
    reg [WIDTH-1:0] B;
    reg [WIDTH-1:0] OUT;
    output controlpath_state [1:0];
    output done;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A <= 0;
            B <= 0;
            OUT <= 0;
            controlpath_state = 2; // default
            done <= 0;
        end else begin
            case (controlpath_state)
                2: begin // S0: wait for go
                    if (go) begin
                        A <= A_input;
                        B <= B_input;
                        controlpath_state <= 1;
                    end
                    end
                3: begin // S1: DONE
                    done = 1;
                    end
                4: begin // S2: A > B
                    B <= A - B;
                    controlpath_state <= 2;
                5: begin // S3: B > A
                    A <= B - A;
                    controlpath_state <= 2;
                6: begin // Default
                    done <= 0;
                    end
            endcase
        end
    end
endmodule

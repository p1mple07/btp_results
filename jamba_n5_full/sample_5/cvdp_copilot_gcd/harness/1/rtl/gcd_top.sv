module gcd_top (
    input  clk,
    input  rst,
    input  go,
    input  [WIDTH-1:0] A,
    input  [WIDTH-1:0] B,
    input  [WIDTH-1:0] equal,
    input  [WIDTH-1:0] greater_than,
    output reg [WIDTH-1:0] out,
    output reg done
);

    // Instantiate modules
    gcd_controlpath uut_ctrl (.WIDTH(WIDTH), .clk(clk), .rst(rst), .go(go), .A(A), .B(B), .equal(equal), .greater_than(greater_than), .out(out), .done(done));
    gcd_datapath uut_datapath (.WIDTH(WIDTH), .clk(clk), .rst(rst), .A(A), .B(B), .OUT(out), .EQ(equal), .GREATER(greater_than), .CONTROLPATH_STATE(.controlpath_state), .DONE(.done));

endmodule

module gcd_controlpath (#(width) WIDTH);
    parameter WIDTH = 4;
    input clk,
    input rst,
    input go,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    input [WIDTH-1:0] equal,
    input [WIDTH-1:0] greater_than,
    output reg [WIDTH-1:0] out,
    output reg done;

    reg [WIDTH-1:0] A_ff, B_ff;
    reg controlpath_state;

    always_ff @(posedge clk) begin
        if (!rst) begin
            controlpath_state <= 0;
            out <= 0;
            done <= 0;
        end else if (go) begin
            case (controlpath_state)
                0: begin // IDLE: wait for go
                    if (A != 0 && B != 0) begin
                        controlpath_state <= 1; // DONE
                    end else begin
                        controlpath_state <= 0; // stay IDLE?
                    end
                end
                1: begin // DONE
                    if (equal) begin
                        out <= A;
                        done <= 1;
                    end else if (greater_than) begin
                        out <= B;
                        done <= 1;
                    end
                    controlpath_state <= 0;
                end
                2: begin // A > B
                    // subtract B from A
                    B_ff <= B - A;
                    if (B_ff == 0) begin
                        controlpath_state <= 3; // B > A
                    end else begin
                        controlpath_state <= 2;
                    end
                end
                3: begin // B > A
                    // subtract A from B
                    A_ff <= A - B;
                    if (A_ff == 0) begin
                        controlpath_state <= 0;
                    end else begin
                        controlpath_state <= 2;
                    end
                end
            endcase
        end else begin
            controlpath_state <= 0;
            out <= 0;
            done <= 0;
        end
    end

    assign done = (A == B);
endmodule

module gcd_datapath (#(width) WIDTH);
    parameter WIDTH = 4;
    input clk,
    input rst,
    input A,
    input B,
    input controlpath_state,
    output reg OUT,
    output reg EQUAL,
    output reg GREATER_THAN;

    reg [WIDTH-1:0] A_ff, B_ff;
    reg controlpath_state_in;

    always_ff @(posedge clk) begin
        if (rst) begin
            A_ff <= 0;
            B_ff <= 0;
            controlpath_state_in <= 0;
            OUT <= 0;
            EQUAL <= 0;
            GREATER_THAN <= 0;
        end else begin
            if (controlpath_state_in == 0) begin
                // S0: wait for go
                if (go) begin
                    A_ff <= A;
                    B_ff <= B;
                    controlpath_state_in <= 1; // DONE
                end
            end else if (controlpath_state_in == 1) begin // DONE
                if (equal) begin
                    OUT <= A_ff;
                    EQUAL <= 1;
                    GREATER_THAN <= 0;
                end else if (greater_than) begin
                    OUT <= B_ff;
                    EQUAL <= 0;
                    GREATER_THAN <= 1;
                end
                controlpath_state_in <= 0;
            end else if (controlpath_state_in == 2) begin // A > B
                B_ff <= B - A;
                if (B_ff == 0) begin
                    controlpath_state_in <= 3;
                end else begin
                    controlpath_state_in <= 2;
                end
            end else if (controlpath_state_in == 3) begin // B > A
                A_ff <= A - B;
                if (A_ff == 0) begin
                    controlpath_state_in <= 0;
                end else begin
                    controlpath_state_in <= 2;
                end
            end
        end
    end

    assign OUT = A_ff;
    assign EQUAL = A_ff == B_ff;
    assign GREATER_THAN = A_ff > B_ff;
endmodule

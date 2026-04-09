`timescale 1ns / 1ps

module gcd_datapath #(
    parameter WIDTH = 4
) (
    input                     clk,
    input                     rst,
    input  [WIDTH-1:0]        A,
    input  [WIDTH-1:0]        B,
    input                     go,
    output logic  [WIDTH-1:0] OUT
);

    localvar unsigned int factor_count = 0;

    always_ff @(posedge clk) begin
        if (rst) begin
            A <= 'b0;
            B <= 'b0;
            factor_count <= 0;
            OUT <= 'b0;
        end else begin
            case (controlpath_state)
                S0: begin
                    if (A == B) begin
                        factor_count <= 0;
                        done <= 1'b1;
                    end else begin
                        // Check parity to decide the first step
                        if (A % 2 == 0 && B % 2 == 0) begin
                            factor_count <= factor_count + 2;
                            A := A >> 1;
                            B := B >> 1;
                        end else if (A % 2 == 0 && B % 2 == 1) begin
                            B := B >> 1;
                            factor_count <= factor_count + 1;
                        end else if (A % 2 == 1 && B % 2 == 0) begin
                            A := A >> 1;
                            factor_count <= factor_count + 1;
                        end else if (A % 2 == 1 && B % 2 == 1) begin
                            A := (A - B) >> 1;
                            B := (B - A) >> 1;
                            factor_count += 2;
                        end
                    end
                end
                S1: begin
                    // After subtraction, check again
                    if (A == B) begin
                        factor_count <= factor_count + 2;
                        done <= 1'b1;
                    end
                end
                S2: begin
                    // Subtract odd from even
                    if (greater_than) begin
                        A := A >> 1;
                        factor_count <= factor_count + 1;
                    end
                end
                S3: begin
                    // B > A, subtract odd from even
                    if (!equal & !greater_than) begin
                        B := B >> 1;
                        factor_count <= factor_count + 1;
                    end
                end
                default: begin
                    A <= 'b0;
                    B <= 'b0;
                    OUT <= 'b0;
                end
            endcase
        end
    end

    assign OUT = A;
endmodule

// Control path for the FSM
module gcd_controlpath (
    input                    clk,
    input                    rst,
    input                    go,
    input                    equal,
    input                    greater_than,
    output logic [1:0]       controlpath_state,
    output logic             done
);

    // Internal state registers
    logic [1:0] curr_state;  // Current state of FSM
    logic [1:0] next_state;  // Next state of FSM

    // State encoding
    localparam S0 = 2'd0;    // State 0: Initialization
    localparam S1 = 2'd1;    // State 1: Computation complete
    localparam S2 = 2'd2;    // State 2: A_ff > B_ff
    localparam S3 = 2'd3;    // State 3: B_ff > A_ff

    // Sequential logic to update registers based on controlpath_state
    always_ff @(posedge clk) begin
        if (rst) begin
            curr_state   <= S0;
        end else begin
            curr_state   <= next_state;
        end
    end

    // State transition logic
    always_comb begin
        case(curr_state)
            S0: begin
                // State S0: Waiting for 'go' signal
                if (!go) next_state = S0;
                else if (equal) next_state = S1;
                else if (greater_than) next_state = S2;
                else next_state = S3;
            end
            S1: begin
                // State S1: Computation complete
                next_state = S0;
            end
            S2: begin
                // State S2: A_ff > B_ff
                if (equal) next_state = S1;
                else if (greater_than) next_state = S2;
                else next_state = S3;
            end
            S3: begin
                // State S3: B_ff > A_ff
                if (equal) next_state = S1;
                else if (greater_than) next_state = S2;
                else next_state = S3;
            end
            default: begin
                next_state = S0;
            end
        endcase
    end

    // Output logic
    always_ff @(posedge clk) begin
        if (rst) begin
            done <= 1'b0;
        end else begin
            done <= (curr_state == S1);
        end
    end

    // Assign current state to output for datapath
    assign controlpath_state = curr_state;

endmodule

// Top level module
module gcd_top #(
    parameter WIDTH = 4
) (
    input                       clk,
    input                       rst,
    input  [WIDTH-1:0]        A,
    input  [WIDTH-1:0]        B,
    output logic              GO,
    output logic              DONE
);

    // Instantiate the datapath
    gcd_datapath dut (.WIDTH(WIDTH));

    // Output signals
    assign GO = dut.controlpath_state;
    assign DONE = dut.DONE;

endmodule

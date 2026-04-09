module crossbar_switch #(
    parameter DATA_WIDTH = 8,  // Parameterized data width
    localparam NUM_PORTS = 4,
    localparam DATA_WIDTH_IN = (DATA_WIDTH + $clog2(NUM_PORTS))
)(
    input  logic                        clk,        // Clock signal
    input  logic                        reset,      // Reset signal
    // Input data and destination IDs
    input  logic [DATA_WIDTH_IN-1 :0]  in0, in1, in2, in3,  // Input data
    input  logic                       valid_in0, valid_in1, valid_in2, valid_in3,  // Input data valid
    // Output data
    output logic  [DATA_WIDTH-1:0]      out0, out1, out2, out3,  // Output data
    output logic                        valid_out0, valid_out1, valid_out2, valid_out3  // Output data valid
);

    // Internal Signals: extract the destination ID (2 MSBs) from each input
    logic [$clog2(NUM_PORTS)-1 : 0] dest0, dest1, dest2, dest3;

    // ----------------------------------------
    // - Procedural blocks
    // ----------------------------------------
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            out0      <= '0;
            out1      <= '0;
            out2      <= '0;
            out3      <= '0;
            valid_out0<= 1'b0;
            valid_out1<= 1'b0;
            valid_out2<= 1'b0;
            valid_out3<= 1'b0;
        end else begin
            // Default: clear outputs
            out0      <= '0;
            out1      <= '0;
            out2      <= '0;
            out3      <= '0;
            valid_out0<= 1'b0;
            valid_out1<= 1'b0;
            valid_out2<= 1'b0;
            valid_out3<= 1'b0;

            // Priority: in0 > in1 > in2 > in3
            if (valid_in0) begin
                case (dest0)
                    2'd0: begin
                        out0      <= in0[DATA_WIDTH-1:0];
                        valid_out0<= 1'b1;
                    end
                    2'd1: begin
                        out1      <= in0[DATA_WIDTH-1:0];
                        valid_out1<= 1'b1;
                    end
                    2'd2: begin
                        out2      <= in0[DATA_WIDTH-1:0];
                        valid_out2<= 1'b1;
                    end
                    2'd3: begin
                        out3      <= in0[DATA_WIDTH-1:0];
                        valid_out3<= 1'b1;
                    end
                    default: ; // If destination is invalid, do nothing
                endcase
            end else if (valid_in1) begin
                case (dest1)
                    2'd0: begin
                        out0      <= in1[DATA_WIDTH-1:0];
                        valid_out0<= 1'b1;
                    end
                    2'd1: begin
                        out1      <= in1[DATA_WIDTH-1:0];
                        valid_out1<= 1'b1;
                    end
                    2'd2: begin
                        out2      <= in1[DATA_WIDTH-1:0];
                        valid_out2<= 1'b1;
                    end
                    2'd3: begin
                        out3      <= in1[DATA_WIDTH-1:0];
                        valid_out3<= 1'b1;
                    end
                    default: ;
                endcase
            end else if (valid_in2) begin
                case (dest2)
                    2'd0: begin
                        out0      <= in2[DATA_WIDTH-1:0];
                        valid_out0<= 1'b1;
                    end
                    2'd1: begin
                        out1      <= in2[DATA_WIDTH-1:0];
                        valid_out1<= 1'b1;
                    end
                    2'd2: begin
                        out2      <= in2[DATA_WIDTH-1:0];
                        valid_out2<= 1'b1;
                    end
                    2'd3: begin
                        out3      <= in2[DATA_WIDTH-1:0];
                        valid_out3<= 1'b1;
                    end
                    default: ;
                endcase
            end else if (valid_in3) begin
                case (dest3)
                    2'd0: begin
                        out0      <= in3[DATA_WIDTH-1:0];
                        valid_out0<= 1'b1;
                    end
                    2'd1: begin
                        out1      <= in3[DATA_WIDTH-1:0];
                        valid_out1<= 1'b1;
                    end
                    2'd2: begin
                        out2      <= in3[DATA_WIDTH-1:0];
                        valid_out2<= 1'b1;
                    end
                    2'd3: begin
                        out3      <= in3[DATA_WIDTH-1:0];
                        valid_out3<= 1'b1;
                    end
                    default: ;
                endcase
            end
        end
    end

    // ----------------------------------------
    // - Combinational Assignments
    // ----------------------------------------
    // Extract the destination ID from the upper 2 bits of each input
    assign dest0 = in0 [DATA_WIDTH_IN-1 : DATA_WIDTH_IN-2] ; // Destination port ID for in0 data
    assign dest1 = in1 [DATA_WIDTH_IN-1 : DATA_WIDTH_IN-2] ; // Destination port ID for in1 data
    assign dest2 = in2 [DATA_WIDTH_IN-1 : DATA_WIDTH_IN-2] ; // Destination port ID for in2 data
    assign dest3 = in3 [DATA_WIDTH_IN-1 : DATA_WIDTH_IN-2] ; // Destination port ID for in3 data

endmodule
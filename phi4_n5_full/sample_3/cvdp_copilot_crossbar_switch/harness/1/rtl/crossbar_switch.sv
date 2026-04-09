module crossbar_switch #(
    parameter DATA_WIDTH = 8,  // Parameterized data width
    localparam NUM_PORTS = 4,
    localparam DATA_WIDTH_IN = (DATA_WIDTH + $clog2(NUM_PORTS))
)(
    input  logic                        clk,        // Clock signal
    input  logic                        reset,      // Reset signal (asynchronous, active low)
    // Input data and destination IDs
    input  logic [DATA_WIDTH_IN-1 :0]  in0, in1, in2, in3,  // Input data (MSBs hold destination ID)
    input  logic                       valid_in0, valid_in1, valid_in2, valid_in3,  // Input data valid signals
    // Output data
    output logic  [DATA_WIDTH-1:0]      out0, out1, out2, out3,  // Output data
    output logic                        valid_out0, valid_out1, valid_out2, valid_out3  // Output valid signals
);
    // Internal Signals: Extract the 2 MSB bits as the destination ID
    logic [$clog2(NUM_PORTS)-1 : 0] dest0, dest1, dest2, dest3;

    // ----------------------------------------
    // - Procedural blocks
    // ----------------------------------------
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            out0    <= 0;
            out1    <= 0;
            out2    <= 0;
            out3    <= 0;
            valid_out0 <= 1'b0;
            valid_out1 <= 1'b0;
            valid_out2 <= 1'b0;
            valid_out3 <= 1'b0;
        end else begin
            // Default: clear outputs
            out0    <= 0;
            out1    <= 0;
            out2    <= 0;
            out3    <= 0;
            valid_out0 <= 1'b0;
            valid_out1 <= 1'b0;
            valid_out2 <= 1'b0;
            valid_out3 <= 1'b0;

            // Only the highest priority valid input is routed.
            if (valid_in0 == 1) begin
                // For input port 0, route based on destination ID
                case (dest0)
                    2'b00: begin
                        out0    <= in0[DATA_WIDTH-1:0];
                        valid_out0 <= 1'b1;
                    end
                    2'b01: begin
                        out1    <= in0[DATA_WIDTH-1:0];
                        valid_out1 <= 1'b1;
                    end
                    2'b10: begin
                        out2    <= in0[DATA_WIDTH-1:0];
                        valid_out2 <= 1'b1;
                    end
                    2'b11: begin
                        out3    <= in0[DATA_WIDTH-1:0];
                        valid_out3 <= 1'b1;
                    end
                endcase
            end else if (valid_in1 == 1) begin
                // For input port 1, route based on destination ID
                case (dest1)
                    2'b00: begin
                        out0    <= in1[DATA_WIDTH-1:0];
                        valid_out0 <= 1'b1;
                    end
                    2'b01: begin
                        out1    <= in1[DATA_WIDTH-1:0];
                        valid_out1 <= 1'b1;
                    end
                    2'b10: begin
                        out2    <= in1[DATA_WIDTH-1:0];
                        valid_out2 <= 1'b1;
                    end
                    2'b11: begin
                        out3    <= in1[DATA_WIDTH-1:0];
                        valid_out3 <= 1'b1;
                    end
                endcase
            end else if (valid_in2 == 1) begin
                // For input port 2, route based on destination ID
                case (dest2)
                    2'b00: begin
                        out0    <= in2[DATA_WIDTH-1:0];
                        valid_out0 <= 1'b1;
                    end
                    2'b01: begin
                        out1    <= in2[DATA_WIDTH-1:0];
                        valid_out1 <= 1'b1;
                    end
                    2'b10: begin
                        out2    <= in2[DATA_WIDTH-1:0];
                        valid_out2 <= 1'b1;
                    end
                    2'b11: begin
                        out3    <= in2[DATA_WIDTH-1:0];
                        valid_out3 <= 1'b1;
                    end
                endcase
            end else if (valid_in3 == 1) begin
                // For input port 3, route based on destination ID
                case (dest3)
                    2'b00: begin
                        out0    <= in3[DATA_WIDTH-1:0];
                        valid_out0 <= 1'b1;
                    end
                    2'b01: begin
                        out1    <= in3[DATA_WIDTH-1:0];
                        valid_out1 <= 1'b1;
                    end
                    2'b10: begin
                        out2    <= in3[DATA_WIDTH-1:0];
                        valid_out2 <= 1'b1;
                    end
                    2'b11: begin
                        out3    <= in3[DATA_WIDTH-1:0];
                        valid_out3 <= 1'b1;
                    end
                endcase
            end
        end
    end

    // ----------------------------------------
    // - Combinational Assignments
    // ----------------------------------------
    // Extract the destination ID from the 2 MSB bits of the input data.
    assign dest0 = in0[DATA_WIDTH_IN-1 : DATA_WIDTH_IN-2];
    assign dest1 = in1[DATA_WIDTH_IN-1 : DATA_WIDTH_IN-2];
    assign dest2 = in2[DATA_WIDTH_IN-1 : DATA_WIDTH_IN-2];
    assign dest3 = in3[DATA_WIDTH_IN-1 : DATA_WIDTH_IN-2];

endmodule
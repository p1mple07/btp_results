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
    // Internal Signals
    logic [$clog2(NUM_PORTS)-1 : 0] dest0,dest1,dest2,dest3;           // Destination ID for each input

    // ----------------------------------------
    // - Procedural blocks
    // ----------------------------------------
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            out0 <= 0;
            out1 <= 0;
            out2 <= 0;
            out3 <= 0;
            valid_out0 <= 1'b0;
            valid_out1 <= 1'b0;
            valid_out2 <= 1'b0;
            valid_out3 <= 1'b0;
        end else begin
            out0 <= 0 ;
            out1 <= 0 ;
            out2 <= 0 ;
            out3 <= 0 ;
            valid_out0 <= 1'b0;
            valid_out1 <= 1'b0;
            valid_out2 <= 1'b0;
            valid_out3 <= 1'b0;

            if (valid_in0 == 1) begin

                    // Insert code for Input 0 Port here

            end else if (valid_in1 == 1) begin

                    // Insert code for Input 1 Port here

            end else if (valid_in2 == 1) begin

                    // Insert code for Input 2 Port here
 
            end else if (valid_in3 == 1) begin

                    // Insert code for Input 3 Port here

            end else begin
                out0 <= 0 ;
                out1 <= 0 ;
                out2 <= 0 ;
                out3 <= 0 ;
            end
        end
    end

    // ----------------------------------------
    // - Combinational Assignments
    // ----------------------------------------
    assign dest0 = in0 [DATA_WIDTH_IN-1 : DATA_WIDTH_IN-2] ; // Destination port ID for in0 data
    assign dest1 = in1 [DATA_WIDTH_IN-1 : DATA_WIDTH_IN-2] ; // Destination port ID for in1 data
    assign dest2 = in2 [DATA_WIDTH_IN-1 : DATA_WIDTH_IN-2] ; // Destination port ID for in2 data
    assign dest3 = in3 [DATA_WIDTH_IN-1 : DATA_WIDTH_IN-2] ; // Destination port ID for in3 data

endmodule
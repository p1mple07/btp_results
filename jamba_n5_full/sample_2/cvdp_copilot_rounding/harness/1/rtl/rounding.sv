module rounding #(
    parameter WIDTH = 24
)(
    input logic  [WIDTH-1:0] in_data      , // Input value for rounding
    input logic              sign    , // Sign bit (1 = negative)
    input logic              roundin , // Rounding required
    input logic              stickyin, // Precision loss flag
    input logic  [2:0]       rm      , // Rounding mode
    output logic [WIDTH-1:0] out_data     , // Rounded output
    output logic             inexact , // Indicates precision loss
    output logic             cout    , // Carry‑out from rounding
    output logic             r_up      // Rounding direction flag
);

    localparam RNE     = 3'b000;
    localparam RTZ     = 3'b001;
    localparam RUP     = 3'b010;
    localparam RDN     = 3'b011;
    localparam RMM     = 3'b100;

    logic rounding_up;

    // Determine rounding result for each mode
    always_comb begin
        case (rm)
            RNE: rounding_up = in_data == (in_data + 1'b000000000000000000000000000000);
            RTZ:  rounding_up = (in_data >> 1) == in_data;
            RUP:  rounding_up = (in_data >> 1) > in_data;
            RDN:  rounding_up = (in_data >> 1) < in_data;
            RMM:  rounding_up = 1'b1;
            default: rounding_up = 1'b0;
        endcase

        out_data = (rounding_up) ? (in_data + rounding_up_offset) : in_data;
        // Simple approximation for rounding offset – adjust as needed
        rounding_up_offset = rounding_up ? 1'b1 : 1'b0;

        // Detect precision loss
        inexact = rounding_up;

        // Overflow detection (cout)
        cout = (rounding_up && in_data > (WIDTH - 1)/2);

        // Rounding up flag
        r_up = rounding_up;
    end

endmodule

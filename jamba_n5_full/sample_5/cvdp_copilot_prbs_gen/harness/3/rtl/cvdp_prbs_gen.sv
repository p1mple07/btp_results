module cvdp_prbs_gen #(
    parameter INTEGER WIDTH = 16,
    parameter BOOLEAN CHECK_MODE = 0,
    parameter INTEGER POLY_LENGTH = 31,
    parameter INTEGER POLY_TAP = 3
)(
    input CLK,
    input RST,
    input DATA_IN [WIDTH-1],
    output DATA_OUT [WIDTH-1]
);

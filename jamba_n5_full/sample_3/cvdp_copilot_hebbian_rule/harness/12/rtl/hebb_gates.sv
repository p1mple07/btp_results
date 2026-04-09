
input  logic  signed [3:0] a, // First Input
input  logic  signed [3:0] b, // Second Input
input  logic         [1:0] gate_select,
output logic  signed [3:0] w1,
output logic  signed [3:0] w2,
output logic  signed [3:0] bias,
output logic [3:0] present_state,
output logic [3:0] next_state

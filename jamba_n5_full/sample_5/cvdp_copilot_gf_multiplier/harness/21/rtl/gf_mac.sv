module gf_mac #(
    parameter WIDTH = 32  // ...
)(
    input [WIDTH-1:0] a,  // ...
    input [WIDTH-1:0] b,  // ...
    output reg [7:0] result // 8-bit XORed result of all GF multiplications
);

    integer i;
    reg [7:0] temp_result;
    wire [7:0] partial_results [(WIDTH/8)-1:0];

    // Check width validity
    assign error_flag = (WIDTH % 8 != 0);

    if (error_flag) begin
        assign valid_result = 0;
        assign result = 8'b0;
        assign error_flag = 1;
        return;
    end

    // ... rest of code

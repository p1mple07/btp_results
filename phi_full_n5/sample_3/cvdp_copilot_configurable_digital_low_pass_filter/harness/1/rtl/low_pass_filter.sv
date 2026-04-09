module low_pass_filter (
    input clk,
    input reset,
    input [6*8-1:0] data_in,
    input valid_in,
    input [4*8-1:0] coeffs,
    output reg [32+ceil(log2(8))-1:0] data_out,
    output reg valid_out
);

    // Internal signal breakdown

    // 2D Internal Representation
    reg [4*8-1:0] data_internal[0:8];
    reg [4*8-1:0] coeffs_internal[0:8];

    // Register inputs on clock edge
    always @(posedge clk) begin
        if (reset) begin
            data_internal <= {8{0}};
            coeffs_internal <= {8{0}};
        end else if (valid_in) begin
            data_internal <= data_in;
            coeffs_internal <= coeffs;
        end
    end

    // Convert to 2D arrays
    always @(posedge clk) begin
        data_internal = {8{data_internal[0]}};
        coeffs_internal = {8{coeffs_internal[0]}};
    end

    // Element-wise multiplication
    always @(posedge clk) begin
        for (int i = 0; i < 8; i++) begin
            data_internal[i] = data_internal[i] & coeffs_internal[7-i];
        end
    end

    // Summation
    reg [32+ceil(log2(8))-1:0] sum;
    always @(posedge clk) begin
        sum = data_internal[0] + data_internal[1] + data_internal[2] + data_internal[3] +
              data_internal[4] + data_internal[5] + data_internal[6] + data_internal[7];
    end

    // Output
    assign data_out = sum;
    assign valid_out = valid_in;

endmodule
 module low_pass_filter (
    input clk,
    input reset,
    input [6*8-1:0] data_in,
    input valid_in,
    input [4*8-1:0] coeffs,
    output reg [32+ceil(log2(8))-1:0] data_out,
    output reg valid_out
);

    // Internal signal breakdown

    // 2D Internal Representation
    reg [4*8-1:0] data_internal[0:8];
    reg [4*8-1:0] coeffs_internal[0:8];

    // Register inputs on clock edge
    always @(posedge clk) begin
        if (reset) begin
            data_internal <= {8{0}};
            coeffs_internal <= {8{0}};
        end else if (valid_in) begin
            data_internal <= data_in;
            coeffs_internal <= coeffs;
        end
    end

    // Convert to 2D arrays
    always @(posedge clk) begin
        data_internal = {8{data_internal[0]}};
        coeffs_internal = {8{coeffs_internal[0]}};
    end

    // Element-wise multiplication
    always @(posedge clk) begin
        for (int i = 0; i < 8; i++) begin
            data_internal[i] = data_internal[i] & coeffs_internal[7-i];
        end
    end

    // Summation
    reg [32+ceil(log2(8))-1:0] sum;
    always @(posedge clk) begin
        sum = data_internal[0] + data_internal[1] + data_internal[2] + data_internal[3] +
              data_internal[4] + data_internal[5] + data_internal[6] + data_internal[7];
    end

    // Output
    assign data_out = sum;
    assign valid_out = valid_in;

endmodule
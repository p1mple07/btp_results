module binary_bcd_converter_twoway(
    input wire switch,
    parameter BCD_DIGITS = 3, // Number of BCD digits
    parameter INPUT_WIDTH = 9, // Width of binary input
    input wire [INPUT_WIDTH-1:0] binary_in,
    input wire [BCD_DIGITS*4-1:0] bcd_in,
    output wire [INPUT_WIDTH-1:0] binary_out,
    output wire [BCD_DIGITS*4-1:0] bcd_out
);

    localparam BINARY_TO_BCD_SWITCH = 1'b0;
    localparam BCD_TO_BINARY_SWITCH = 1'b1;

    genvar i;
    generate
        if(switch == BINARY_TO_BCD_SWITCH) begin
            assign binary_out = binary_bcd_converter(bcd_in);
            assign bcd_out = "0";
        end else begin
            assign binary_out = "0";
            assign bcd_out = binary_bcd_converter(binary_in);
        end
    endgenerate

    function [BCD_DIGITS*4-1:0] binary_bcd_converter(input wire [INPUT_WIDTH-1:0] data);
        reg [BCD_DIGITS*4-1:0] result;

        always @(*) begin
            result = "0";
            for(i=0; i<BCD_DIGITS; i++) begin
                result[i*4+:4] = data[i*INPUT_WIDTH+(INPUT_WIDTH-4):i*INPUT_WIDTH];
            end

            for(i=BCD_DIGITS; i<BCD_DIGITS*2; i++) begin
                result[i*4+:4] = data[i*INPUT_WIDTH+(INPUT_WIDTH-4):i*INPUT_WIDTH];
            end

            for(i=BCD_DIGITS*2; i<BCD_DIGITS*3; i++) begin
                result[i*4+:4] = data[i*INPUT_WIDTH+(INPUT_WIDTH-4):i*INPUT_WIDTH];
            end

            for(i=BCD_DIGITS*3; i<BCD_DIGITS*4; i++) begin
                result[i*4+:4] = data[i*INPUT_WIDTH+(INPUT_WIDTH-4):i*INPUT_WIDTH];
            end
        end

        return result;
    endfunction

endmodule
module reed_solomon_encoder #(
    parameter DATA_WIDTH = 8,
    parameter N = 255,
    parameter K = 223
) (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire valid_in,
    output reg [DATA_WIDTH-1:0] codeword_out,
    output reg valid_out,
    output reg [DATA_WIDTH-1:0] parity_0,
    output reg [DATA_WIDTH-1:0] parity_1
);

    localparam PARITY_SYMBOLS = N - K;

    reg [DATA_WIDTH-1:0] data_reg, feedback;
    reg [PARITY_SYMBOLS-1:0] parity_reg;

    function [DATA_WIDTH-1:0] generator_polynomial;
        integer index;
        if (index < 8) begin
            if (index == 0) return 0x1D;
            else return 0x33;
        end else begin
            return 0x1D;
        end
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            parity_0 <= 0;
            parity_1 <= 0;
            codeword_out <= 0;
            valid_out <= 0;
            data_reg <= 0;
            feedback <= 0;
        elsif enable && valid_in begin
            parity_reg <= 0;
            data_reg <= 0;
            feedback <= data_in;

            for (integer i = 0; i < K; i++) begin
                feedback <= (feedback << 1) | data_in;
                data_in <= 0;
                data_reg <= feedback;

                if (feedback [DATA_WIDTH-1]) begin
                    feedback <= feedback ^ generator_polynomial(i);
                end
            end

            parity_0 <= feedback [0];
            parity_1 <= feedback [1];
            codeword_out <= (data_reg << (N - DATA_WIDTH)) | feedback;
            valid_out <= 1;
        end
    end
endmodule
module nbit_swizzling #(
    parameter DATA_WIDTH = 64
)(
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output reg [DATA_WIDTH+PARITY_BITS-1:0] data_out,
    output reg ecc_out
);

localparam PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1);
reg [DATA_WIDTH+PARITY_BITS-1:0] data_out;
reg [DATA_WIDTH-1:0] parity_bits;

integer i;

always @(*) begin
    case(sel)
        2'b00: begin
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                data_out[i] = data_in[i];
            end
            data_out[DATA_WIDTH] = parity_bits[0];
        end
        2'b01: begin
            for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
                data_out[i] = data_in[DATA_WIDTH/2-1-i];
                data_out[DATA_WIDTH/2 + i] = data_in[DATA_WIDTH-1-i];
            end
            data_out[DATA_WIDTH] = parity_bits[1];
        end
        2'b10: begin
            for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
                data_out[i] = data_in[DATA_WIDTH/4-1-i];
                data_out[DATA_WIDTH/4 + i] = data_in[DATA_WIDTH/2-1-i];
                data_out[DATA_WIDTH/2 + i] = data_in[3*DATA_WIDTH/4-1-i];
                data_out[3*DATA_WIDTH/4 + i] = data_in[DATA_WIDTH-1-i];
            end
            data_out[DATA_WIDTH] = parity_bits[2];
        end
        2'b11: begin
            for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                data_out[i] = data_in[DATA_WIDTH/8-1-i];
                data_out[DATA_WIDTH/8 + i] = data_in[DATA_WIDTH/4-1-i];
                data_out[DATA_WIDTH/4 + i] = data_in[3*DATA_WIDTH/8-1-i];
                data_out[3*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH/2-1-i];
                data_out[DATA_WIDTH/2 + i] = data_in[5*DATA_WIDTH/8-1-i];
                data_out[5*DATA_WIDTH/8 + i] = data_in[3*DATA_WIDTH/4-1-i];
                data_out[3*DATA_WIDTH/4 + i] = data_in[7*DATA_WIDTH/8-1-i];
                data_out[7*DATA_WIDTH/8 + i] = data_in[DATA_WIDTH-1-i];
            end
            data_out[DATA_WIDTH] = parity_bits[3];
        end
        default: begin
            data_out = data_in;
            data_out[DATA_WIDTH] = parity_bits[0];
        end
    endcase
end

// Compute the parity bits for the extended output
for (i = 0; i < DATA_WIDTH + PARITY_BITS; i++) begin
    if (i % 2 == 0) begin
        parity_bits[i/2] = 1'b0;
    end else begin
        parity_bits[i/2] = 1'b1;
    end
end

// Assign the final output
data_out = data_out;
ecc_out = data_out[DATA_WIDTH:0];

endmodule

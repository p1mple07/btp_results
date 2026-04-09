module hamming_code_receiver(
    input [7:0] data_in,
    output reg [3:0] data_out
);

    // Error detection and correction bits
    reg [2:0] c1, c2, c3;

    // Error detection logic
    always_comb begin
        // Calculate c3
        c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
        // Calculate c2
        c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
        // Calculate c1
        c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    end

    // Error correction and output assignment
    always_comb begin
        // If no error detected
        if ({c1, c2, c3} == 3'b000) begin
            data_out = data_in[7:4];
        // If error detected, correct the error
        else begin
            case ({c1, c2, c3})
                3'b001: data_out[1] = ~data_in[1];
                3'b010: data_out[2] = ~data_in[2];
                3'b011: data_out[3] = ~data_in[3];
                3'b100: data_out[4] = ~data_in[4];
                3'b101: data_out[5] = ~data_in[5];
                3'b110: data_out[6] = ~data_in[6];
                3'b111: data_out[7] = ~data_in[7];
                default: data_out = data_in[7:4];
            endcase
        end
    end

endmodule

module rc5_enc_16bit (
    input wire clock,
    input wire reset,
    input wire enc_start,
    input wire [15:0] p,
    output reg [15:0] c
);

    reg [7:0] s[4];

    initial begin
        s[0] = 8'b00001111;  // 0x1F
        s[1] = 8'b01001110;  // 0x5E
        s[2] = 8'b11001100;  // 0xA4
        s[3] = 8'b11010001;  // 0xF1
    end

    always_ff @(posedge clock) begin
        if (~reset) begin
            s[0] = s[0] << 1 ^ (s[0] >> 7);
            s[1] = s[1] << 1 ^ (s[1] >> 7);
            s[2] = s[2] << 1 ^ (s[2] >> 7);
            s[3] = s[3] << 1 ^ (s[3] >> 7);
        end else begin
            s[0] = 8'b10001111;  // 0xF1
            s[1] = 8'b00110011;  // 0x33
            s[2] = 8'b11001011;  // 0xE3
            s[3] = 8'b01011010;  // 0x5A
        end
    end

    assign c = (p + s[0]) ^ (p + s[1]) ^ (p + s[2]) ^ (p + s[3]);

endmodule

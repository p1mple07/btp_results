`module rc5_enc_16bit(
    input wire clock,
    input wire reset,
    input wire enc_start,
    input wire [15:0] p,
    output reg [15:0] c,
    output reg enc_done
);

    reg clock;
    reg reset;
    reg enc_start;
    reg [15:0] a, b;
    reg [1:0] state;
    reg [1:0] next_state;

    localparam s0 = 8'b00000010;
    localparam s1 = 8'b00001000;
    localparam s2 = 8'b11111111;
    localparam s3 = 8'b11111111;

    // State machine transitions
    always_ff @(posedge clock) begin
        case(state)
            0: begin
                if (enc_start) begin
                    a = p[7:0];
                    b = p[15:8];
                    next_state = 1;
                end else
                    next_state = 2;
            end
            1: begin
                a = (a ^ b) << b + s0;
                b = (b ^ a) << a + s1;
                next_state = 2;
            end
            2: begin
                a = (a ^ b) << b + s2;
                b = (b ^ a) << a + s3;
                next_state = 3;
            end
            3: begin
                c = a + b;
                enc_done = 1;
            end
        endcase
    end

    always_ff @(posedge reset) begin
        state <= 0;
    end

    assign c = a + b;

endmodule

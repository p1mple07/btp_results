module lfsr_8bit (
    input wire clk,
    input wire rst,
    input wire [7:0] seed,  // User-defined initial seed
    output reg [7:0] lfsr_out
);

    always @ (posedge clk or posedge rst) begin
        if (rst)
            lfsr_out <= 8'h00;
        else begin
            lfsr_out <= {lfsr_out[6:0], lfsr_out[7] ^ lfsr_out[5] ^ lfsr_out[4] ^ lfsr_out[3]};
        end
    end

endmodule

module lfsr_8bit_tb;
    reg clk;
    reg rst;
    reg [7:0] seed;
    wire [7:0] lfsr_out;
    reg [7:0] expected_lfsr;
    reg [7:0] shift_reg;
    integer i;

    initial begin
        clk = 0; rst = 1; seed = 8'h10; expected_lfsr = seed;

        for (i = 0; i < 20; i = i + 1) begin
            #10;

            shift_reg = {expected_lfsr[6:0], expected_lfsr[7] ^ expected_lfsr[5] ^ expected_lfsr[4] ^ expected_lfsr[3]};
            if (lfsr_out!== shift_reg) begin
                $error("ERROR at cycle %d: Expected %b, Got %b", i, shift_reg, lfsr_out);
            end
            expected_lfsr = shift_reg;
        end

        $finish;
    end

    // Instantiate the DUT
    lfsr_8bit dut (
       .clk(clk),
       .rst(rst),
       .seed(seed),
       .lfsr_out(lfsr_out)
    );

    // Waveform generation
    initial begin
        $dumpfile("lfsr_8bit.vcd");
        $dumpvars(0, lfsr_8bit_tb);
    end

endmodule
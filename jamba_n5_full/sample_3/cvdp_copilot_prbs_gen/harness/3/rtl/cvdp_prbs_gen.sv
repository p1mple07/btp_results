module cvdp_prbs_gen #(
    int w = 16,
    int pl = 31,
    int tp = 3
) (
    input wire clk,
    input wire rst,
    input wire data_in,
    output reg [w-1:0] data_out
);

    // State registers
    reg [pl-1:0] state;
    reg [taps-1:0] taps;
    reg [w-1:0] prbs;
    reg [w-1:0] expected_prbs;

    // Initialize state to all ones
    initial begin
        state = 1'b1;
        state = ~state;
        prbs = 1'b1;
        expected_prbs = 1'b1;
    end

    // Generate next PRBS bit
    task generate_next;
        begin
            prbs = (state >> 1) | (prbs ^ taps[tp]);
        end
    endtask

    // Update data_out
    always @(posedge clk) begin
        if (~rst) begin
            state = 1'b1;
            prbs = 1'b1;
            expected_prbs = 1'b1;
        end else begin
            generate_next;
        end
    end

    // Checker mode: compare data_in with expected PRBS
    always @(*) begin
        if (data_in != 1'b0) begin
            data_out = 1'b0;
            return;
        end
        expected_prbs = prbs;
        data_out = expected_prbs;
    end

endmodule

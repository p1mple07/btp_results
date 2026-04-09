module SetBitStreamCalculator(
    input wire i_clk,
    input wire i_rst_n,
    input wire [7:0] i_bit_in,
    input wire i_ready,
    output reg [7:0] o_set_bit_count
);

    // Define the maximum count based on parameter
    parameter MAX_COUNT = 2**8; // Default value, can be parameterized

    // Internal signal to hold the current count
    reg [7:0] count;

    // Asynchronous reset
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            count <= 0;
            o_set_bit_count <= 0;
        end else if (i_ready) begin
            count <= 0;
        end
    end

    // Sequential logic for counting
    always @(posedge i_clk) begin
        if (i_ready) begin
            // Increment count for each '1' bit in i_bit_in
            count <= count + (i_bit_in == 1'b1);
            // Implement saturation logic
            if (count >= MAX_COUNT) begin
                count <= MAX_COUNT;
            end
            o_set_bit_count <= count;
        end
    end

endmodule

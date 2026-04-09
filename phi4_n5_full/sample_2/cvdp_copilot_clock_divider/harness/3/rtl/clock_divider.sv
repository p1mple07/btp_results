module that divides an input clock by 2, 4, or 8 based on the sel input.
//   sel = 2'b00: Divide by 2
//   sel = 2'b01: Divide by 4
//   sel = 2'b10: Divide by 8
// If sel is out-of-range, clk_out remains 0 until a valid sel is applied.

module clock_divider(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [1:0]   sel,
    output logic         clk_out
);

    // A 3-bit counter is sufficient (max value 7 for divide-by-8).
    logic [2:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_out <= 0;
            counter <= 0;
        end else begin
            case (sel)
                2'b00: begin
                    // Divide by 2: toggle when counter reaches 1.
                    if (counter == 1) begin
                        counter <= 0;
                        clk_out <= ~clk_out;
                    end else begin
                        counter <= counter + 1;
                        clk_out <= clk_out;
                    end
                end
                2'b01: begin
                    // Divide by 4: toggle when counter reaches 3.
                    if (counter == 3) begin
                        counter <= 0;
                        clk_out <= ~clk_out;
                    end else begin
                        counter <= counter + 1;
                        clk_out <= clk_out;
                    end
                end
                2'b10: begin
                    // Divide by 8: toggle when counter reaches 7.
                    if (counter == 7) begin
                        counter <= 0;
                        clk_out <= ~clk_out;
                    end else begin
                        counter <= counter + 1;
                        clk_out <= clk_out;
                    end
                end
                default: begin
                    // If sel is out-of-range, hold clk_out at 0.
                    clk_out <= 0;
                    counter <= 0;
                end
            endcase
        end
    end

endmodule
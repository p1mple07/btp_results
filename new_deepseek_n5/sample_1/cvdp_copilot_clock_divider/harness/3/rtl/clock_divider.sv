module clock_divider(
    input clock,
    input rst_n,
    input [1:0] sel,
    output clock_out
);
    // Counter for division
    reg counter = 0;
    // Division factor based on sel
    reg [1:0] div_factor;
    case (sel)
        2'b00: div_factor = 2;
        2'b01: div_factor = 4;
        2'b10: div_factor = 8;
        default: div_factor = 0;
    endcase
    // Output state
    reg clock_out = 0;
    reg valid = 0;
    // Counter control
    always clock_edge #1 begin
        if (!rst_n) begin
            // Start counting after rst_n is low
            counter = 0;
        end
        // Toggle output when counter reaches division factor
        if (counter == div_factor) begin
            clock_out = !clock_out;
            counter = 0;
        end
        // Increment counter on rising edge
        counter = counter + 1;
    end
    // Output validity
    always rst_n #1 begin
        valid = 1;
    end
    // Output the valid signal
    always valid #1 begin
        if (valid) begin
            clock_out = !clock_out;
        end
    end
endmodule
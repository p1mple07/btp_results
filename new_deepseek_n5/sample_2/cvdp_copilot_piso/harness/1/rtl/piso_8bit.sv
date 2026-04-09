module piso_8bit (
    input clock,
    input rst,
    output serial_out
);
    reg [7:0] tmp;
    reg counter;
    reg [7:0] shift_reg;

    // Initialize the temporary register and counter
    integer count;
    always_comb begin
        if (rst == 0)
            tmp = 1;
    end

    // Counter for tracking the number of clock cycles
    always_ff @posedge clock begin
        counter = counter + 1;
    end

    // When the counter reaches 8, increment the temporary register and reset the counter
    always_ff @posedge clock begin
        if (counter == 8) begin
            tmp = tmp + 1;
            counter = 0;
        end
    end

    // The serial output is the MSB of the temporary register
    serial_out = (tmp >> 7);
endmodule
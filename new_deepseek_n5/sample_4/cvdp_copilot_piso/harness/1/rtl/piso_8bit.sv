module piso_8bit (
    input clock,
    input rst,
    output serial_out
);

    // Internal state variables
    reg [7:0] shift_reg;
    reg tmp;
    reg [7:0] counter;

    // Initialize the shift register with the initial value
    initial begin
        shift_reg = 0b00000001;
        tmp = 0b00000001;
        counter = 0;
    end

    // Process block
    always_comb begin
        // When reset is active LOW, reset the shift register and tmp
        if (rst == 1)
            shift_reg = tmp;
            counter = 0;
        else
            // Increment counter on each clock cycle
            counter = counter + 1;
            // When counter reaches 8, increment tmp and reset counter
            if (counter == 8)
                begin
                    tmp = tmp + 1;
                    counter = 0;
                end
            // Shift the shift register right by 1 bit
            shift_reg = (shift_reg >> 1);
            // The serial_out is the MSB of the shift register
            serial_out = shift_reg[7];
    end
endmodule
// 1. Direction Control Register (per GPIO pin)
always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
        reg_dout <= {GPIO_WIDTH{1'b0}};
    else begin
        // Read the current direction value from the register
        logic dir;
        assign dir = gpio[GPIO_WIDTH-1:0];

        // Apply direction to the mux logic
        if (dir == 1'b0)
            read_mux = data_in_sync2;
        else
            read_mux = data_in_pol_adjusted_dly;
    end
end

// 2. Power Management Register (global power‑down)
always_ff @(posedge pclk or negedge negedge preset_n) begin
    if (~preset_n)
        reg_power_down <= 1'b0;          // normal operation
    else
        reg_power_down <= 1'b1;          // power‑down all GPIOs
end

// 3. Interrupt Reset Register (clears all active interrupts)
always_ff @(posedge pclk or negedge negedge preset_n) begin
    if (~preset_n)
        reg_power_down <= 1'b0;          // normal operation
    else
        reg_power_down <= 1'b1;          // reset all interrupts
end

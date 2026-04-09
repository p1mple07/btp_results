module ttcounter_lite(
    input clock,
    input reset,
    input axi_addr,
    input axi_wdata,
    input axi_write_en,
    input axi_read_en,
    output axi_rdata,
    output interrupt
);

    // Registers
    register [31:0] count;
    register [31:0] match_value;
    register [31:0] reload_value;
    register [31:0] control;
    register [31:0] status;

    // Initial state
    initial begin
        // Initialize all registers to 0
        count = 0;
        match_value = 0;
        reload_value = 0;
        control = 0b0000_0000;
        status = 0b0000_0000;
        // Set default to non-interval mode, disable timer
        control = 0b0000_0000;
        // Set interval mode to off
        control |= (4'b0000);
        // Set match value to 0
        match_value = 0;
        // Set reload value to 0
        reload_value = 0;
        // Set enable to 0
        control |= (5'b00000);
        // Set interval mode to off
        control |= (6'b000000);
        // Set interrupt enable to 0
        control |= (7'b0000000);
        // Start the counter
        initial_state();
    end

    // Counter logic
    always clockbegin
        if (reset) 
            count = 0;
        else if (control & 0x40000000) // Enable bit is set
            if (!interval_mode) 
                count = count + 1;
            else 
                if (count == match_value) 
                    count = reload_value;
        end
    end

    // Match detection
    always 
        if (count == match_value) 
            match_flag = 1;
        else 
            match_flag = 0;
    end

    // Interrupt generation
    always clockbegin
        if (match_flag & interrupt_enable) 
            interrupt = 1;
        else 
            interrupt = 0;
        end
    end

    // AXI-Lite interfaces
    always 
        if (axi_write_en) 
            reload_value = axi_wdata;
        if (axi_read_en) 
            axi_rdata = count;
        end
    end

    // Status register
    always 
        if (match_flag) 
            status = 0x00000001;
        else 
            status = 0x00000000;
        end
    end

    // Initial block
    initial begin
        // Set initial state
        $display("Initial state setup complete");
    end

endmodule
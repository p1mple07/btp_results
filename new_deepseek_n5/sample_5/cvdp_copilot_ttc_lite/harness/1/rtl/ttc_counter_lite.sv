module ttc_counter_lite (
    input clock,
    input reset,
    input axi_addr,
    input axi_wdata,
    input axi_write_en,
    input axi_read_en,
    output axi_rdata,
    output interrupt,
    output [31:0] status
);

    // Counter registers
    register [31:0] count;
    register [31:0] match_value;
    register [31:0] reload_value;
    register [31:0] control;

    // Status register
    register [31:0] status;

    // Match flag
    register [31:0] match_flag = 0;

    // Always block for counter logic
    always @(posedge clock or posedge reset) begin
        if (reset) 
            count = 0;
            match_flag = 0;
            match_value = 0;
            reload_value = 0;
            control = 0b000;
            status = 0b000;
        else 
            if (axi_read_en) 
                count = count;
            else 
                count = (count + 1) & 0xFFFFFFFF;
            end
        end

        // Match detection
        if (count == match_value and !interval_mode and enable) 
            match_flag = 1;
        end

        // Reload counter in interval mode
        if (interval_mode and match_flag and enable) 
            count = reload_value;
            match_flag = 0;
        end

        // Interrupt generation
        if (match_flag and interrupt_enable) 
            interrupt = 1;
        end

        // Update status register
        if (interrupt_enable) 
            status = (status + (interrupt ? 1 : 0)) & 0xFFFFFFFF;
        end
    end

    // AXI-Lite read operation
    if (axi_read_en) 
        axi_rdata = count;
    end

    // AXI-Lite write operations
    if (axi_write_en) 
        match_value = axi_wdata;
        reload_value = axi_wdata;
        control = axi_addr;
    end

    // Reset all registers on reset
    if (reset) 
        count = 0;
        match_value = 0;
        reload_value = 0;
        control = 0b000;
        status = 0b000;
    end
module ttc_counter_lite(
    input clock,
    input reset,
    input axi_addr,
    input axi_wdata,
    input axi_write_en,
    input axi_read_en,
    output axi_rdata,
    output interrupt
);

    // Initialize parameters
    parameter MATCH_VALUE = 65535;
    parameter RELOAD_VALUE = 65535;

    // Register map
    reg [31:0] count;          // Lower 16 bits used
    reg [31:0] match_value;    // Match value register
    reg [31:0] reload_value;   // Reload value register
    reg [31:0] control;        // Control register
    reg [31:0] status;         // Status register

    // Clock control
    clock controlclk;

    // Counter logic
    integer count_val = 0;

    // Match detection flag
    reg match_flag = 0;

    // Always blocks
    always clocked (
        controlclk = enable ? 1 : 0
    ) begin
        if (reset) 
            count_val = 0;
        else if (enable) 
            count_val = (count_val + 1) % 65536;
        end

        // Match detection
        if (count_val == match_value) 
            match_flag = 1;
        end

        // Interval mode reload
        if (interval_mode && match_flag) 
            reload_value = reload_value;
        end

        // Interrupt generation
        if (interrupt_enable && match_flag) 
            interrupt = 1;
        end

        // AXI operations
        if (axi_write_en) 
            match_value = axi_wdata;
        end
        if (axi_read_en) 
            count = count_val;
            reload_value = reload_value;
            status = (interrupt ? 1 : 0);
        end
    end

    // AXI data output
    axi_rdata = count;

    // Reset initialization
    initial begin
        $write(count, 0);
        $write(match_value, MATCH_VALUE);
        $write(reload_value, RELOAD_VALUE);
        $write(control, 0);
        $write(status, 0);
        $finish;
    end

    // Control signals
    enable = 0;
    interval_mode = 0;
    interrupt_enable = 0;
    control[2:0] = enable;
    control[3] = interval_mode;
    control[4:0] = interrupt_enable;
endmodule
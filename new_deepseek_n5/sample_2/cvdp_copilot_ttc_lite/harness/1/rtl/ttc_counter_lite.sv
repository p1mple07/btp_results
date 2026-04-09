module ttc_counter_lite (
    input clock,
    input reset,
    input axi_addr,
    input axi_wdata,
    input axi_write_en,
    input axi_read_en,
    output reg count,
    output reg axi_rdata,
    output reg interrupt,
    output reg status
);

    // Control register: [enable, interval_mode, interrupt_enable]
    reg control[32];

    // Match value register
    reg match_value[32];
    // Reload value register
    reg reload_value[32];
    // Status register
    reg status_reg[32];

    // Always reset
    always_comb begin
        if (reset) begin
            count = 0;
            match_value = 0;
            reload_value = 0;
            status_reg = 0;
            // disable all signals
            axi_rdata = 0;
            interrupt = 0;
        end
    end

    // Counter increment logic
    always clock begin
        if (reset) return;

        if (control[0] && !control[1] && !control[2]) begin
            count = count + 1;
            // Check if match value is set
            if (count == match_value) begin
                // Set match flag
                match_value = count;
                // Stop counting in non-interval mode
                control[1] = 1;
            end
        end
    end

    // Reload value logic
    always clock begin
        if (control[1] && count == reload_value) begin
            count = reload_value;
        end
    end

    // Match detection
    always clock begin
        if (count == match_value) begin
            // Set match flag
            match_value = count;
        end
    end

    // Interrupt generation
    always clock begin
        if (control[2] && match_value == match_value && status_reg[0]) begin
            interrupt = 1;
        end
    end

    // Status register
    always clock begin
        if (interrupt) begin
            status_reg[0] = 1;
        end
        if (reset) begin
            status_reg = 0;
        end
    end
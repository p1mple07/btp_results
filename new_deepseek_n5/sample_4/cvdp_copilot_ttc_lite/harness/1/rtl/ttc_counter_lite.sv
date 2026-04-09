module ttc_counter_lite (
    input clock,
    input reset,
    input axi_addr,
    input axi_wdata,
    input axi_write_en,
    input axi_read_en
    output axi_rdata
);

    // Registers
    reg [31:0] count; // 32-bit counter (lower 16 bits used)
    reg [31:0] match_value; // Match value register
    reg [31:0] reload_value; // Reload value register
    reg [31:0] control; // Control bits (enable, interval_mode, interrupt_enable)
    reg [31:0] status; // Status register (interrupt flag)

    // Constants
    const MATCH_WIDTH = 16;
    const RELOAD_WIDTH = 16;

    // Address mapping
    reg [31:0] count_addr = 0x0;
    reg [31:0] match_addr = 0x1;
    reg [31:0] reload_addr = 0x2;
    reg [31:0] control_addr = 0x3;
    reg [31:0] status_addr = 0x4;

    // Logic
    always clocked begin
        if (reset) begin
            count = 0;
            match_value = 0;
            reload_value = 0;
            control = 0b000;
            status = 0;
        end else begin
            if (axi_write_en) begin
                // Write to registers
                count[count_addr] = axi_wdata;
                match_value[match_addr] = axi_wdata;
                reload_value[reload_addr] = axi_wdata;
                control[control_addr] = axi_wdata;
            end

            // Counter increment
            if (axi_read_en) begin
                count[count_addr] = (count[count_addr] + 1) & 0xFFFF;
            end

            // Match detection
            if (count[count_addr] == match_value[match_addr]) begin
                if (axi_write_en) begin
                    reload_value[reload_addr] = axi_wdata;
                end
                status = 1;
            end

            // Interrupt handling
            if (axi_read_en && (status == 1)) begin
                if (control[3:2] == 1) begin
                    if (axi_write_en) begin
                        status[status_addr] = 0;
                    end
                end
            end
        end
    end

    // AXI-Lite ports
    axi_rdata = count[count_addr];
endmodule
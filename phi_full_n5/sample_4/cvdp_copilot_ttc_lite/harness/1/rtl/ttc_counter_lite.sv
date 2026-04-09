module ttc_counter_lite #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4
) (
    input clk,
    input reset,
    input [ADDR_WIDTH-1:0] axi_addr,
    input [DATA_WIDTH-1:0] axi_wdata,
    input axi_write_en,
    input axi_read_en,
    output [DATA_WIDTH-1:0] axi_rdata,
    output interrupt
);

    // Registers
    reg [DATA_WIDTH-1:0] count;
    reg [DATA_WIDTH-1:0] match_value;
    reg [DATA_WIDTH-1:0] reload_value;
    reg enable, interval_mode, interrupt_enable;
    reg match_flag;
    reg [DATA_WIDTH-1:0] status;

    // State machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            match_value <= 0;
            reload_value <= 0;
            enable <= 0;
            interval_mode <= 0;
            interrupt_enable <= 0;
            match_flag <= 0;
            status <= 0;
        end else begin
            enable <= control_register[3:0];
            interval_mode <= control_register[7];
            interrupt_enable <= control_register[8];
            match_flag <= (count == match_value) & interval_mode;
            status <= interrupt_enable ? 1'b1 : 1'b0;
        end
    end

    // Counter logic
    always @(posedge clk) begin
        if (enable) begin
            if (interval_mode) begin
                if (match_flag) begin
                    count <= reload_value;
                    interrupt <= 1;
                    match_flag <= 0;
                end else begin
                    count <= count + 1;
                end
            end else begin
                count <= count + 1;
            end
        end else begin
            count <= 0;
        end
    end

    // AXI-Lite Interface
    assign axi_rdata = (axi_read_en) ? count : 1'bz;
    assign axi_write_en = (axi_addr == control_register_address) ? enable : 1'b0;

    // Control Register
    reg [ADDR_WIDTH-1:0] control_register;
    assign control_register = (axi_addr == 0) ? control_register : 1'bz;

    // Status Register
    reg [ADDR_WIDTH-1:0] status_register;
    assign status_register = (axi_addr == status_register_address) ? status : 1'bz;

    // Interrupt Handling
    always @(posedge clk) begin
        if (status_register[0]) begin
            interrupt <= 1;
            status <= 0;
        end else begin
            interrupt <= 1'b0;
        end
    end

endmodule

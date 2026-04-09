module apb_controller(
    input clk,
    input reset_n,
    input select_a_i,
    input select_b_i,
    input select_c_i,
    input [31:0] addr_a_i,
    input [31:0] data_a_i,
    input [31:0] addr_b_i,
    input [31:0] data_b_i,
    input [31:0] addr_c_i,
    input [31:0] data_c_i,
    input apb_pready_i,

    output reg apb_psel_o,
    output reg apb_penable_o,
    output reg apb_pwrite_o,
    output [31:0] apb_paddr_o,
    output [31:0] apb_pwdata_o
);

    // Internal signals
    reg [31:0] selected_addr;
    reg [31:0] selected_data;
    reg [4:0] timeout_counter;

    // State variables
    reg [1:0] state = 2'b00; // 0: IDLE, 1: SETUP, 2: ACCESS
    reg [1:0] select_priority = 2'b01; // Highest priority for select_a_i

    // State transition logic
    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            state <= 2'b00;
            selected_addr <= 32'd0;
            selected_data <= 32'd0;
            timeout_counter <= 4'd0;
            apb_psel_o <= 1'b0;
            apb_penable_o <= 1'b0;
            apb_pwrite_o <= 1'b0;
            apb_paddr_o <= 32'd0;
            apb_pwdata_o <= 32'd0;
        end else begin
            case (state)
                2'b00: begin
                    if (select_a_i) begin
                        select_priority = 2'b01;
                        selected_addr <= addr_a_i;
                        selected_data <= data_a_i;
                    end
                    if (select_b_i) begin
                        select_priority = 2'b10;
                        selected_addr <= addr_b_i;
                        selected_data <= data_b_i;
                    end
                    if (select_c_i) begin
                        select_priority = 2'b11;
                        selected_addr <= addr_c_i;
                        selected_data <= data_c_i;
                    end
                    if (select_priority) begin
                        state <= 2'b01;
                    end
                end
                2'b01: begin
                    apb_psel_o <= 1'b1;
                    apb_penable_o <= 1'b0;
                    apb_pwrite_o <= 1'b1;
                    apb_paddr_o <= selected_addr;
                    apb_pwdata_o <= selected_data;
                    state <= 2'b02;
                end
                2'b02: begin
                    if (apb_pready_i && timeout_counter < 15) begin
                        timeout_counter <= timeout_counter + 1'b1;
                    end else begin
                        timeout_counter <= 4'd0;
                        state <= 2'b00;
                    end
                end
            endcase
        end
    end

    // Output logic for ACCESS phase
    always @(posedge clk) begin
        if (state == 2'b02 && apb_pready_i) begin
            apb_penable_o <= 1'b1;
        end
    end

    // Output logic for IDLE phase
    always @(posedge clk) begin
        if (state == 2'b00) begin
            apb_psel_o <= 1'b0;
            apb_penable_o <= 1'b0;
            apb_pwrite_o <= 1'b0;
        end
    end

endmodule
This SystemVerilog module, `apb_controller`, implements the logic for an APB-based controller that handles event-based write transactions with a timeout mechanism, following the specifications provided. It includes state machines for the IDLE, SETUP, and ACCESS phases, and manages priority for multiple event triggers. The module also incorporates a timeout counter that ensures peripherals do not stall indefinitely if they fail to respond within a specified time. module apb_controller(
    input clk,
    input reset_n,
    input select_a_i,
    input select_b_i,
    input select_c_i,
    input [31:0] addr_a_i,
    input [31:0] data_a_i,
    input [31:0] addr_b_i,
    input [31:0] data_b_i,
    input [31:0] addr_c_i,
    input [31:0] data_c_i,
    input apb_pready_i,

    output reg apb_psel_o,
    output reg apb_penable_o,
    output reg apb_pwrite_o,
    output [31:0] apb_paddr_o,
    output [31:0] apb_pwdata_o
);

    // Internal signals
    reg [31:0] selected_addr;
    reg [31:0] selected_data;
    reg [4:0] timeout_counter;

    // State variables
    reg [1:0] state = 2'b00; // 0: IDLE, 1: SETUP, 2: ACCESS
    reg [2:0] select_priority = 3'b001; // Default priority, will be updated based on select signals

    // State transition logic
    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            state <= 2'b00;
            selected_addr <= 32'd0;
            selected_data <= 32'd0;
            timeout_counter <= 4'd0;
            apb_psel_o <= 1'b0;
            apb_penable_o <= 1'b0;
            apb_pwrite_o <= 1'b0;
            apb_paddr_o <= 32'd0;
            apb_pwdata_o <= 32'd0;
        end else begin
            case (state)
                2'b00: begin
                    if (select_a_i) begin
                        select_priority = 3'b001;
                        selected_addr <= addr_a_i;
                        selected_data <= data_a_i;
                    end
                    if (select_b_i) begin
                        select_priority = 3'b010;
                        selected_addr <= addr_b_i;
                        selected_data <= data_b_i;
                    end
                    if (select_c_i) begin
                        select_priority = 3'b100;
                        selected_addr <= addr_c_i;
                        selected_data <= data_c_i;
                    end
                    if (select_priority) begin
                        state <= 2'b01;
                    end
                end
                2'b01: begin
                    apb_psel_o <= 1'b1;
                    apb_penable_o <= 1'b0;
                    apb_pwrite_o <= 1'b1;
                    apb_paddr_o <= selected_addr;
                    apb_pwdata_o <= selected_data;
                    state <= 2'b02;
                end
                2'b02: begin
                    if (apb_pready_i && timeout_counter < 15) begin
                        timeout_counter <= timeout_counter + 1'd1;
                    end else begin
                        timeout_counter <= 4'd0;
                        state <= 2'b00;
                    end
                end
            endcase
        end
    end

    // Output logic for ACCESS phase
    always @(posedge clk) begin
        if (state == 2'b02 && apb_pready_i) begin
            apb_penable_o <= 1'b1;
        end
    end

    // Output logic for IDLE phase
    always @(posedge clk) begin
        if (state == 2'b00) begin
            apb_psel_o <= 1'b0;
            apb_penable_o <= 1'b0;
            apb_pwrite_o <= 1'b0;
        end
    end

endmodule
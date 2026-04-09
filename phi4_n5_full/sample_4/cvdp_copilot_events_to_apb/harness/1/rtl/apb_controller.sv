// File: rtl/apb_controller.sv

`timescale 1ns / 1ps

module apb_controller (
    input  logic         clk,
    input  logic         reset_n,
    input  logic         select_a_i,
    input  logic         select_b_i,
    input  logic         select_c_i,
    input  logic [31:0]  addr_a_i,
    input  logic [31:0]  data_a_i,
    input  logic [31:0]  addr_b_i,
    input  logic [31:0]  data_b_i,
    input  logic [31:0]  addr_c_i,
    input  logic [31:0]  data_c_i,
    input  logic         apb_pready_i,
    output logic         apb_psel_o,
    output logic         apb_penable_o,
    output logic         apb_pwrite_o,
    output logic [31:0]  apb_paddr_o,
    output logic [31:0]  apb_pwdata_o
);

    // State encoding: IDLE, SETUP, ACCESS
    localparam IDLE  = 2'd0,
               SETUP = 2'd1,
               ACCESS = 2'd2;

    // Internal registers
    reg [1:0] state;
    reg       event_triggered; // Flag indicating an event was captured in IDLE
    reg [31:0] captured_addr;
    reg [31:0] captured_data;
    reg [3:0]  timeout_counter; // 4-bit timeout counter

    // Sequential state machine
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state            <= IDLE;
            event_triggered  <= 1'b0;
            captured_addr    <= 32'b0;
            captured_data    <= 32'b0;
            timeout_counter  <= 4'b0;
            // Drive all outputs to 0
            apb_psel_o       <= 1'b0;
            apb_penable_o    <= 1'b0;
            apb_pwrite_o     <= 1'b0;
            apb_paddr_o      <= 32'b0;
            apb_pwdata_o     <= 32'b0;
        end else begin
            case (state)
                IDLE: begin
                    // Capture event if any select signal is asserted (pulse signals)
                    if (select_a_i || select_b_i || select_c_i) begin
                        event_triggered <= 1'b1;
                        // Prioritize events: A highest, then B, then C
                        if (select_a_i) begin
                            captured_addr <= addr_a_i;
                            captured_data <= data_a_i;
                        end else if (select_b_i) begin
                            captured_addr <= addr_b_i;
                            captured_data <= data_b_i;
                        end else if (select_c_i) begin
                            captured_addr <= addr_c_i;
                            captured_data <= data_c_i;
                        end
                    end else begin
                        event_triggered <= 1'b0;
                        captured_addr   <= 32'b0;
                        captured_data   <= 32'b0;
                    end
                    // Remain in IDLE for one cycle; if an event was captured, transition to SETUP next cycle.
                    if (event_triggered)
                        state <= SETUP;
                    else
                        state <= IDLE;
                    
                    // In IDLE, outputs are deasserted.
                    apb_psel_o       <= 1'b0;
                    apb_penable_o    <= 1'b0;
                    apb_pwrite_o     <= 1'b0;
                    apb_paddr_o      <= 32'b0;
                    apb_pwdata_o     <= 32'b0;
                end
                SETUP: begin
                    // Assert APB signals for write transaction.
                    apb_psel_o       <= 1'b1;
                    apb_pwrite_o     <= 1'b1;
                    apb_paddr_o      <= captured_addr;
                    apb_pwdata_o     <= captured_data;
                    apb_penable_o    <= 1'b0;
                    // Transition to ACCESS phase in the next cycle.
                    state <= ACCESS;
                end
                ACCESS: begin
                    if (apb_pready_i) begin
                        // Peripheral is ready: complete the transaction immediately.
                        apb_psel_o       <= 1'b0;
                        apb_pwrite_o     <= 1'b0;
                        apb_paddr_o      <= 32'b0;
                        apb_pwdata_o     <= 32'b0;
                        apb_penable_o    <= 1'b0;
                        state            <= IDLE;
                        timeout_counter  <= 4'b0;
                    end else if (timeout_counter >= 15) begin
                        // Timeout reached: abort the transaction.
                        apb_psel_o       <= 1'b0;
                        apb_pwrite_o     <= 1'b0;
                        apb_paddr_o      <= 32'b0;
                        apb_pwdata_o     <= 32'b0;
                        apb_penable_o    <= 1'b0;
                        state            <= IDLE;
                        timeout_counter  <= 4'b0;
                    end else begin
                        // Remain in ACCESS: increment the timeout counter.
                        timeout_counter  <= timeout_counter + 1;
                        // Maintain APB signals.
                        apb_psel_o       <= 1'b1;
                        apb_pwrite_o     <= 1'b1;
                        apb_paddr_o      <= captured_addr;
                        apb_pwdata_o     <= captured
// Module copyright (c) 2023 by the Open Source Robotics Team (OSRT)
// This file is part of the 'rtl' ASCII specification library.

module ethernet_mii_tx (
    // Top level input               // Description
    input               clk_in,       // MII clock input
    input               rst_in,       // MII reset input (active-high)
    input  [31:0]       axis_data_in, // AXI-stream data input
    input   [3:0]       axis_strb_in, // AXI-stream byte strobes
    input               axis_last_in, // AXI-stream end-of-frame indicator
    input               axis_valid_in, // AXI-stream validity
    output              mii_txd_out,   // MII transmit data output
    output              mii_tx_en_out  // MII transmit enable signal (active-HIGH)
);

// FIFO integration in tx
rtl/ethernet_fifo_cdc #(
    parameter WIDTH = 38,
    parameter DEPTH = 512,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    wr_clk_i = clk_in,
    wr_rst_i = rst_in,
    wr_push_i = 1,
    wr_data_i = axis_data_in,
    rd_clk_i =clk_in,
    rd_rst_i= rst_in,
    rd_pop_i=1,
    rd_data_o= mii_txd_out,
    rd_empty_o= 1
);

// CRC Calculation
function [31:0] compute_crc32_D8;
compute_crc32_D8(
    in  [31:0] Data,
    out [31:0] Crc
);
endfunction

// State Machine
finite_state_machine fsm (
    input valid_start, valid_data, valid_end,
    output valid_tx_done,
    next_state [
        'idle,
        'preamble,
        'sfd,
        'payload,
        'crc_calculation,
        'transmission_completion,
        'idle
    ]
);

fsm_initial_state = 'idle;
always@(valid_start or valid_data or valid_end) begin
    case(fsm.current_state)
        'idle:
            fsm.next_state = 'preamble';
            // Start transmitting
        'preamble:
            if (valid_data) begin
                fsm.next_state = 'sfd';
            end
            // Wait for SFD
        'sfd:
            if (valid_end) begin
                fsm.next_state = 'payload';
                // Start transmitting payload
            end
            // Wait for payload
        'payload:
            if (valid_data) begin
                fsm.next_state = 'crc_calculation';
                // Start CRC calculation
            end
            // Wait for CRC calculation
        'crc_calculation:
            fsm.next_state = 'transmission_completion';
            // Transmit CRC and terminate
        'transmission_completion:
            fsm.next_state = 'idle';
            // Assert end of transmission
    default:
        fsm.next_state = 'idle';
    endcase
endalways

// Transmit functions
reg [31:0] mii_tx_preamble = {7'b55};
reg [31:0] mii_tx_sfd = 0xD5;
reg [31:0] mii_tx_crc;

always @(valid_end) begin
    mii_tx_preamble = {7'b55};
    // Clear any pending operations
    fsm.next_state = 'idle';
end

always @valid_data begin
    // Add payload to MII
    mii_tx_preamble = axis_data_in;
    fsm.next_state = 'sfd';

    // Encode SFD
    mii_tx_sfd = 0xD5;
    fsm.next_state = 'payload';
end

always @valid_end begin
    // Add CRC to MII
    mii_tx_crc = compute_crc32_D8(axis_data_in);
    fsm.next_state = 'transmission_completion';
end

// Initialize registers
initially valid_start = 0;
initially valid_data = 0;
initially valid_end = 0;

// Mapping of AXI valid signals to MII wire signals
wire (valid_data ? (axis_valid_in ? 1 : 0) : 0) mii_tx_valid_out;
wire (valid_data ? (axis_strb_in ? 31:0) mii_tx strobe_out);

// Output signals
output reg [31:0] mii_tx_preamble, mii_tx_sfd, mii_tx_crc;
output reg [31:0] mii_txd_out;
output reg mii_tx_en_out;

// FSM states
state [
    'idle,
    'preamble,
    'sfd,
    'payload,
    'crc_calculation,
    'transmission_completion
] fsm_state;
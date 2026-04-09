// Include necessary modules
include "rtl/sv.h"
include "dma/dma_params.h"

// Module definition
module dma_xfer_engine (
    input wire clock,
    input wire rstn,
    input wire [7:0] addr,
    input wire we,
    input [31:0] wd,
    output reg rd,
    output reg bus_req,
    output reg bus_lock,
    output [31:0] addr_m,
    output [31:0] we_m,
    output [31:0] wd_m,
    output [31:0] size_m,

    // Slave interface
    input wire [1:0] slv_addr,
    input wire slv_we,
    input wire [31:0] slv_rdy,

    // Bus Arbiter interface
    input wire bus_grant,
    input wire bus_req_master,
    input wire bus_grant_master
);

// State variables
reg state = IDLE;
reg [9:0] control_reg;

// Buffers
 reg [31:0] buffer = 0;
 reg [31:0] packed_data;

// Addresses
 reg [31:0] src_addr, dst_addr;

// Other variables
 integer cnt = 0;
 integer size_idx = 0;
 integer inc_src = 0;
 integer inc_dst = 0;

// FSM transition table
always @* begin
    case(state)
        IDLE: 
            if (dma_req) begin
                state = WB; 
                cnt = 0;
                size_m = 0b00;
                inc_src = 0;
                inc_dst = 0;
            end
        WB: 
            if (bus_grant) begin
                state = TR;
                cnt = 0;
                size_m = 0b00;
                inc_src = 0;
                inc_dst = 0;
            end
        TR: 
            if (cnt == 0) begin
                // Read phase
                packed_data = read_phase();
                packed_data = write_phase();
                cnt = cnt + 1;
                
                // Check if transfer complete
                if (cnt >= transfer_count) begin
                    state = IDLE;
                    // Release bus request
                    bus_req = 0;
                    bus_lock = 0;
                end
            else
                // Transition to next state
                state = TR;
            end
    default: 
        state = IDLE;
    endcase
end

// Read phase implementation
function [31:0] read_phase() {
    // Pack data from buffer
    size_m = get_size();
    
    if (slv_we) begin
        packed_data = buffer[packed_data_base(): packed_data_base() + data_length -1];
        return packed_data;
    end
    
    return 0;
}

// Write phase implementation
function [31:0] write_phase() {
    // Unpack data to buffer
    size_m = get_size();
    
    if (slv_we) begin
        buffer[unpacked_data_base(): unpacked_data_base() + data_length -1] = packed_data;
        return packed_data;
    end
    
    return 0;
}

// Configure block parameters
initializable const parameter transfer_size_encoding = (
    DMA_B = 2'b00,
    DMA_HW = 2'b01,
    DMA_W = 2'b10
);
const parameter transfer_count = 10;

// Initialize buffer
initial 
    buffer = 0;
    packed_data = 0;

// Handle reset condition
always_comb begin
    if (rstn) begin
        control_reg = 0;
        src_addr = 0;
        dst_addr = 0;
        cnt = 0;
        size_idx = 0;
        inc_src = 0;
        inc_dst = 0;
        packed_data = 0;
        buffer = 0;
    end
end

//Slave read logic
always @* begin
    if (slv_we) begin
        if (slv_addr == 0x0) begin // Control Register
            slv_rdy = 1;
            control_reg = slv_rdy_value;
        elsif (slv_addr == 0x4) begin // Source Address
            slv_rdy = 1;
            src_addr = slv_rdy_value;
        elsif (slv_addr == 0x8) begin // Destination Address
            slv_rdy = 1;
            dst_addr = slv_rdy_value;
        end
    end
end

//Master bus requests
always @* begin
    if (!bus_grant) begin
        bus_req = 0;
        bus_lock = 0;
    end
end

//Slave write logic
always @* begin
    if (slv_we) begin
        if (slv_addr == 0xA) begin // Read Request
            we_m = 0;
            addr_m = src_addr;
            rd = buffer;
            we_m = 0;
        elsif (slv_addr == 0xC) begin // Write Request
            we_m = 1;
            addr_m = dst_addr;
            rd = packed_data;
        end
    end
end

// Master Bus Outputs
wire [31:0] bus_wr, bus_wrp;

// Final initialization
initial 
    // State Machine Initialization
    state = IDLE;
    cnt = 0;
    size_idx = 0;
    inc_src = 0;
    inc_dst = 0;
    control_reg = 0;
    src_addr = 0;
    dst_addr = 0;
    packed_data = 0;
    buffer = 0;

// Slave initialization
initial 
    slv_rdy_value = 0;
    // ... rest of the initialization code ...
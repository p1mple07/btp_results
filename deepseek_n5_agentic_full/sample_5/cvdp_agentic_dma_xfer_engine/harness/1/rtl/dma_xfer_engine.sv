// -*- SystemVerilog -*-
parameter TRANSFER_SIZE_ENCODING = 
  DMA_B = 2'b00,
  DMA_HW = 2'b01,
  DMA_W = 2'b10;
  
// Configuration register width
parameter CONTROL_REGISTER_WIDTH = 10;

// Module inputs
input clocks.clk;
input clocks.rstn;

// Slave interface
input [CONTROL_REGISTER_WIDTH-1:0] addr;
input [1:0] we; // Write enable for slave interface
input [32-1:0] wd;

// Master interface
output [32-1:0] rd_m;
output [32-1:0] bus_req;
output [32-1:0] bus_lock;
output [32-1:0] addr_m;
output [1:0] we_m; // Master write enable
output [32-1:0] size_m;

// State machine control
output [1:0] state; // IDLE=0, WB=1, TR=2
output [1:0] FSM_state; // IDLE=0, WB=1, TR=2

// Internal buffer for read data
reg [32-1:0] internal_buffer;

// Control register (10 bits)
reg [CONTROL_REGISTER_WIDTH-1:0] DMA_CR;

// Source and destination addresses (32 bits)
reg [32-1:0] DMA_SRC_ADR, DMA_DST_ADR;

// Parameters from documentation
local param TRANSFER_SIZE: TRANSFER_SIZE_ENCODING = DMA_CR[1:0];
local param SIZE: integer = (TRANSFER_SIZE == DMA_B ? 1 : (TRANSFER_SIZE == DMA_HW ? 2 : 4));

// State initialization
initially(FSM_state) = 0;
always FSM_state: FSM_state <= (dma_req & !bus_grant);
always FSM_state: FSM_state |= (!dma_req | bus_grant);

// Slave read logic
always state[1:0] FSM_state:
  case (state[1:0])
    0b00: FSM_state <= (dma_req && !bus_grant); // IDLE -> WB
    0b01: FSM_state <= 0b01; // WB stays
    0b10: FSM_state <= 0b10; // TR stays
    default: FSM_state <= 0b00;
  endcase

// Address calculation
function [32-1:0] calc_address reg acc;
  if ($ Clk_RisingEdge(clk))
    acc = $acc + (address == 0x4 ? 4 : (address == 0x8 ? 8 : 0));
  end
  return acc;
endfunction

// Read operation
always state[1:0] FSM_state:
  case (state[1:0])
    0b01: FSM_state <= 0b01; // WB->TR
    else: FSM_state <= 0b00; // TR->IDLE
  endcase

// Transfer functionality
always state[1:0] FSM_state:
  case (state[1:0])
    0b10: FSM_state <= 0b10; // TR stays
    default: FSM_state <= 0b00; // TR->IDLE
  endcase

// Address handling
always state[1:0] FSM_state:
  case (state[1:0])
    0b01: FSM_state <= 0b01; // WB->TR
    0b10: FSM_state <= 0b10; // TR->TR
    default: FSM_state <= 0b00; // TR->IDLE
  endcase

// Final transition
always state[1:0] FSM_state:
  case (state[1:0])
    0b10: FSM_state <= 0b00; // TR->IDLE
    default: FSM_state <= FSM_state; // IDLE stays
  endcase

// Address validity check
always FSM_state: if (addr != 0 && addr != 4 && addr != 8) 
  state FSM_state <= 0b00;
end

// DMA transfer implementation
always FSM_state: 
  case (state[1:0]) 
    0b00: 
      if (dma_req && !bus_grant) 
        state FSM_state <= 0b01; 
      else 
        state FSM_state <= 0b00; 
    endcase 

// Memory interface
always FSM_state: 
  case (state[1:0]) 
    0b01: 
      if (we) 
        state FSM_state <= 0b10; 
      else 
        state FSM_state <= 0b00; 
    endcase 

// Buffer management
always FSM_state: 
  case (state[1:0]) 
    0b10: 
      if (we) 
        internal_buffer = rd_m; 
        state FSM_state <= 0b00; 
      else 
        state FSM_state <= 0b10; 
    endcase 

// Increments
always FSM_state: 
  case (state[1:0]) 
    0b00: 
      if (!src_inc || !dst_inc) 
        src_addr = DMA_SRC_ADR; 
        dst_addr = DMA_DST_ADR; 
      else 
        src_addr = calc_address(DMA_SRC_ADR); 
        dst_addr = calc_address(DMA_DST_ADR); 
    endcase 

// Read operation
always FSM_state: 
  case (state[1:0]) 
    0b01: 
      if (we) 
        rd_m = internal_buffer; 
        internal_buffer = 0; 
      else 
        internal_buffer = 0; 
      state FSM_state <= 0b00; 
    endcase 

// Write operation
always FSM_state: 
  case (state[1:0]) 
    0b10: 
      if (!we) 
        if (dma_req && !bus_grant) 
          state FSM_state <= 0b01; 
        else 
          state FSM_state <= 0b00; 
      endcase 
    0b00: 
      if (dma_req && !bus_grant) 
        state FSM_state <= 0b01; 
      else 
        state FSM_state <= 0b00; 
    endcase 
  endcase 

// State transitions 
always FSM_state: 
  case (state[1:0]) 
    0b00: 
      if (dma_req && !bus_grant) 
        state FSM_state <= 0b01; 
      else 
        state FSM_state <= 0b00; 
    endcase 
    0b01: 
      if (bus_grant) 
        state FSM_state <= 0b10; 
      else 
        state FSM_state <= 0b01; 
    endcase 
    0b10: 
      if (dma_req && !bus_grant) 
        state FSM_state <= 0b01; 
      else 
        state FSM_state <= 0b10; 
    endcase 
  endcase 

// Final initialization 
initially(FSM_state) = 0;
always FSM_state: FSM_state = 0b00;
always FSM_state: FSM_state = 0b00;
always FSM_state: FSM_state = 0b00;

// Reset handling 
always FSM_state: 
  if (rstn) 
    state FSM_state <= 0b00; 
    DMA_CR[2:0] = 0; 
    DMA_CR[1:0] = 0; 
    DMA_CR[0] = 0; 
    DMA_SRC_ADR = 0; 
    DMA_DST_ADR = 0; 
    internal_buffer = 0; 
    FSM_state = 0b00; 
  end
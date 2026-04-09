module sprite_controller_fsm#(
   parameter MEM_ADDR_WIDTH = 16,
   parameter PIXEL_WIDTH = 24,
   parameter SPRITE_WIDTH = 16,
   parameter SPRITE_HEIGHT = 16,
   parameter WAIT_WIDTH    = 4,
   parameter N_ROM         = 256
)(
   input  logicclk,
   input  logicrst_n,
   input  logic [WAIT_WIDTH-1:0]i_wait,
   output logicrw,                             
   output logic [MEM_ADDR_WIDTH-1:0]write_addr,
   output logic [PIXEL_WIDTH-1:0]write_data,   
   output logic [SPRITE_WIDTH-1:0]x_pos,       
   output logic [SPRITE_HEIGHT-1:0]y_pos,      
   input  logic [PIXEL_WIDTH-1:0]pixel_out,    
   output logic done                            
);

typedef enum logic [2:0] {
   IDLE,
   INIT_WRITE,
   WRITE,
   INIT_READ,
   READ,
   WAIT,
   DONE
} state_t;

state_t current_state, next_state;

logic [MEM_ADDR_WIDTH-1:0] addr_counter;
logic [PIXEL_WIDTH-1:0] data_counter;
logic [WAIT_WIDTH-1:0] wait_counter;

always @posedgeclk begin
   case(current_state)
   // IDLE state
   IDLE: 
      addr_counter = 0;
      data_counter = 0;
      wait_counter = 0;
      rw = 0;
      done = 0;
      next_state = INIT_WRITE;
      break;
   // INIT_WRITE state
   INIT_WRITE: 
      addr_counter = 0;
      write_data = 24'hFF0000;
      rw = 1;
      next_state = WRITE;
      break;
   // WRITE state
   WRITE: 
      rw = 1;
      while (addr_counter < N_ROM - 1) {
         write_addr = addr_counter;
         write_data = data_counter;
         addr_counter = addr_counter + 1;
         data_counter = data_counter + 1;
      }
      next_state = INIT_READ;
      break;
   // INIT_READ state
   INIT_READ: 
      addr_counter = 0;
      rw = 0;
      next_state = READ;
      break;
   // READ state
   READ: 
      x_pos = addr_counter % SPRITE_WIDTH;
      y_pos = addr_counter / SPRITE_WIDTH;
      addr_counter = addr_counter + 1;
      next_state = WAIT;
      break;
   // WAIT state
   WAIT: 
      wait_counter = wait_counter + 1;
      if (wait_counter == i_wait) {
         done = 1;
         next_state = DONE;
      }
      break;
   // DONE state
   DONE: 
      done = 0;
      next_state = IDLE;
      break;
   endcase
endalways

endmodule
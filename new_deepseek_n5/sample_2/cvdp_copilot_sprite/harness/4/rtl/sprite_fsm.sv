module sprite_controller_fsm#(
   parameter MEM_ADDR_WIDTH = 16,
   parameter PIXEL_WIDTH = 24,
   parameter SPRITE_WIDTH = 16,
   parameter SPRITE_HEIGHT = 16,
   parameter WAIT_WIDTH    = 4,
   parameter N_ROM         = 256
)(
   input  logic clk,
   input  logic rst_n,
   input  logic [WAIT_WIDTH-1:0] i_wait,
   output logic rw,                             
   output logic [MEM_ADDR_WIDTH-1:0] write_addr,
   output logic [PIXEL_WIDTH-1:0] write_data,   
   output logic [SPRITE_WIDTH-1:0] x_pos,       
   output logic [SPRITE_HEIGHT-1:0] y_pos,      
   input  logic [PIXEL_WIDTH-1:0] pixel_out,    
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

  next_state = case {
      IDLE: 
          if (rst_n) {
              next_state = INIT_WRITE;
          }
          else {
              next_state = IDLE;
          }
      INIT_WRITE: 
          next_state = WRITE;
      WRITE: 
          next_state = INIT_READ;
      INIT_READ: 
          next_state = READ;
      READ: 
          next_state = WAIT;
      WAIT: 
          if (wait_counter == i_wait) {
              next_state = DONE;
          }
          else {
              next_state = WAIT;
          }
      DONE: 
          next_state = IDLE;
  };

   // Signal Generation
   rw = (current_state == IDLE || current_state == INIT_WRITE || current_state == WRITE) ? 1 : 0;
   write_addr = addr_counter;
   write_data = (current_state == INIT_WRITE) ? (24'hFF0000) : data_counter;
   x_pos = addr_counter % SPRITE_WIDTH;
   y_pos = addr_counter / SPRITE_WIDTH;

   // Output
   output logic done = (current_state == DONE);

endmodule
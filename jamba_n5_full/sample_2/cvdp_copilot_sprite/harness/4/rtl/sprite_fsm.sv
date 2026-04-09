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

  // Insert the FSM code here

endmodule

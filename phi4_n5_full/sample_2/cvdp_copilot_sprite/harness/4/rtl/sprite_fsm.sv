module sprite_controller_fsm#(
   parameter MEM_ADDR_WIDTH = 16,
   parameter PIXEL_WIDTH    = 24,
   parameter SPRITE_WIDTH   = 16,
   parameter SPRITE_HEIGHT  = 16,
   parameter WAIT_WIDTH     = 4,
   parameter N_ROM          = 256
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

   // FSM state declaration
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

   // Counters
   logic [MEM_ADDR_WIDTH-1:0] addr_counter; 
   logic [PIXEL_WIDTH-1:0] data_counter;    
   logic [WAIT_WIDTH-1:0] wait_counter;     

   // Next state logic
   always_comb begin
       next_state = current_state; // default assignment
       case (current_state)
           IDLE:           next_state = INIT_WRITE;
           INIT_WRITE:     next_state = WRITE;
           WRITE: begin
               if (addr_counter == N_ROM - 1)
                   next_state = INIT_READ;
               else
                   next_state = WRITE;
           end
           INIT_READ:      next_state = READ;
           READ: begin
               if (addr_counter == N_ROM - 1)
                   next_state = WAIT;
               else
                   next_state = READ;
           end
           WAIT: begin
               if (wait_counter == i_wait)
                   next_state = DONE;
               else
                   next_state = WAIT;
           end
           DONE:           next_state = IDLE;
           default:        next_state = IDLE;
       endcase
   end

   // Sequential logic: state register and counter updates
   always_ff @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
           current_state  <= IDLE;
           addr_counter   <= '0;
           data_counter   <= '0;
           wait_counter   <= '0;
           done           <= 1'b0;
       end
       else begin
           current_state <= next_state;
           case (current_state)
               IDLE: begin
                   addr_counter  <= '0;
                   data_counter  <= '0;
                   wait_counter  <= '0;
                   done          <= 1'b0;
               end
               INIT_WRITE: begin
                   addr_counter <= '0; // ensure reset
               end
               WRITE: begin
                   addr_counter <= addr_counter + 1;
                   data_counter <= data_counter + 1;
               end
               INIT_READ: begin
                   addr_counter <= '0;
               end
               READ: begin
                   addr_counter <= addr_counter + 1;
               end
               WAIT: begin
                   wait_counter <= wait_counter + 1;
               end
               DONE: begin
                   done <= 1'b1;
               end
               default: begin
                   // No action
               end
           endcase
       end
   end

   // Output logic: drive outputs based on current state and counter values
   always_comb begin
       // Default assignments
       rw         = 1'b0;
       write_addr = addr_counter;
       write_data = data_counter;
       // Calculate sprite positions using modulus and division
       x_pos = addr_counter % SPRITE_WIDTH;
       y_pos = addr_counter / SPRITE_WIDTH;
       done  = 1'b0;

       case (current_state)
           IDLE: begin
               rw = 1'b0;
           end
           INIT_WRITE: begin
               rw         = 1'b1;
               write_data = 24'hFF0000;
           end
           WRITE: begin
               rw         = 1'b1;
               write_addr = addr_counter;
               write_data = data_counter;
           end
           INIT_READ: begin
               rw = 1'b0;
           end
           READ: begin
               rw         = 1'b0;
               write_addr = addr_counter; // Reused for addressing read operations
               // x_pos and y_pos already computed above
           end
           WAIT: begin
               rw = 1'b0;
           end
           DONE: begin
               done = 1'b1;
           end
       endcase
   end

endmodule
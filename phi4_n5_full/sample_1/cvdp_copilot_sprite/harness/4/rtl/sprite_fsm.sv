module sprite_controller_fsm #(
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

   // Counters for addressing and data
   logic [MEM_ADDR_WIDTH-1:0] addr_counter; 
   logic [PIXEL_WIDTH-1:0]    data_counter;    
   logic [WAIT_WIDTH-1:0]     wait_counter;     

   // FSM sequential process: state transitions and counter updates
   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         current_state <= IDLE;
         addr_counter  <= 0;
         data_counter  <= 0;
         wait_counter  <= 0;
         rw            <= 0;
         done          <= 0;
      end else begin
         case (current_state)
           IDLE: begin
               // Reset all counters and outputs
               addr_counter  <= 0;
               data_counter  <= 0;
               wait_counter  <= 0;
               rw            <= 0;
               done          <= 0;
               current_state <= INIT_WRITE;
           end
           INIT_WRITE: begin
               // Prepare for write operations
               addr_counter <= 0;
               rw           <= 1;  // Set write mode
               current_state<= WRITE;
           end
           WRITE: begin
               // Write pixel data into memory sequentially.
               // Check if the last address has been reached.
               if (addr_counter == N_ROM - 1)
                   current_state <= INIT_READ;
               else begin
                   addr_counter <= addr_counter + 1;
                   data_counter <= data_counter + 1;
                   current_state<= WRITE;
               end
           end
           INIT_READ: begin
               // Prepare for read operations
               addr_counter <= 0;
               rw           <= 0;  // Set read mode
               current_state<= READ;
           end
           READ: begin
               // Read data from memory using addr_counter.
               // Calculate x_pos and y_pos from addr_counter.
               if (addr_counter == N_ROM - 1)
                   current_state <= WAIT;
               else begin
                   addr_counter <= addr_counter + 1;
                   current_state<= READ;
               end
           end
           WAIT: begin
               // Wait for the specified number of cycles.
               if (wait_counter == i_wait)
                   current_state <= DONE;
               else begin
                   wait_counter <= wait_counter + 1;
                   current_state<= WAIT;
               end
           end
           DONE: begin
               // Assert done for one cycle then return to IDLE.
               done <= 1;
               current_state<= IDLE;
           end
         endcase
      end
   end

   // Output assignments based on current state and counters
   always_comb begin
      // Default assignments
      rw          = 0;
      write_addr  = addr_counter;
      write_data  = data_counter;
      x_pos       = addr_counter % SPRITE_WIDTH;
      y_pos       = addr_counter / SPRITE_WIDTH;
      
      // In INIT_WRITE state, override write_data to 24'hFF0000.
      if (current_state == INIT_WRITE)
         write_data = 24'hFF0000;
      // In WRITE state, ensure rw is asserted.
      else if (current_state == WRITE)
         rw = 1;
   end

endmodule
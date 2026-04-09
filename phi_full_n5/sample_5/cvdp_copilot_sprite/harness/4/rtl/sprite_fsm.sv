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

   // State encoding
   logic [2:0] state_encoding;

   // State transition logic
   always @(posedge clk) begin
       if (rst_n) begin
           current_state <= IDLE;
           addr_counter <= (0 >> MEM_ADDR_WIDTH) - 1;
       end else begin
           state_encoding = current_state;
           case (state_encoding)
               IDLE: begin
                   if (!rst_n) current_state <= IDLE;
                   else begin
                       current_state <= INIT_WRITE;
                       addr_counter <= (0 >> MEM_ADDR_WIDTH) - 1;
                       data_counter <= (0 >> PIXEL_WIDTH) - 1;
                   end
               end
               INIT_WRITE: begin
                   if (addr_counter == (N_ROM - 1) / (PIXEL_WIDTH + WAIT_WIDTH - 1)) begin
                       current_state <= WRITE;
                       data_counter <= 0;
                   end else begin
                       current_state <= INIT_WRITE;
                       addr_counter <= addr_counter + 1;
                   end
               end
               WRITE: begin
                   if (addr_counter == N_ROM - 1) begin
                       current_state <= INIT_READ;
                       addr_counter <= 0;
                       data_counter <= (24'hFF << (PIXEL_WIDTH - 1));
                       rw <= 1;
                   end else begin
                       current_state <= WRITE;
                       write_addr <= addr_counter;
                       write_data <= data_counter;
                       addr_counter <= addr_counter + 1;
                       data_counter <= data_counter + 1;
                   end
               end
               INIT_READ: begin
                   if (addr_counter == 0) begin
                       current_state <= READ;
                   end else begin
                       current_state <= INIT_READ;
                       addr_counter <= addr_counter + 1;
                   end
               end
               READ: begin
                   if (addr_counter == (N_ROM - 1) / (PIXEL_WIDTH + WAIT_WIDTH - 1)) begin
                       current_state <= WAIT;
                       wait_counter <= 0;
                   end else begin
                       current_state <= READ;
                       write_addr <= addr_counter;
                       x_pos <= (addr_counter >> (PIXEL_WIDTH - SPRITE_WIDTH)) & ((1 << SPRITE_WIDTH) - 1);
                       y_pos <= (addr_counter >> (PIXEL_WIDTH - SPRITE_WIDTH * SPRITE_HEIGHT)) & ((1 << SPRITE_HEIGHT) - 1);
                       rw <= 0;
                   end
               end
               WAIT: begin
                   if (wait_counter == i_wait) begin
                       current_state <= DONE;
                       wait_counter <= 0;
                   end else begin
                       current_state <= WAIT;
                       wait_counter <= wait_counter + 1;
                   end
               end
               DONE: begin
                   done <= 1;
                   current_state <= IDLE;
               end
               default: current_state <= IDLE;
           endcase
       end
   end

   // Output assignments
   assign x_pos = (addr_counter >> (PIXEL_WIDTH - SPRITE_WIDTH)) & ((1 << SPRITE_WIDTH) - 1);
   assign y_pos = (addr_counter >> (PIXEL_WIDTH - SPRITE_WIDTH * SPRITE_HEIGHT)) & ((1 << SPRITE_HEIGHT) - 1);

endmodule

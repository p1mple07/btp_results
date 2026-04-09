module sprite_controller_fsm#(
   parameter MEM_ADDR_WIDTH = 16,
   parameter PIXEL_WIDTH    = 24,
   parameter SPRITE_WIDTH   = 16,
   parameter SPRITE_HEIGHT  = 16,
   parameter WAIT_WIDTH     = 4,
   parameter N_ROM          = 256
)(
   input  logic                 clk,
   input  logic                 rst_n,
   input  logic [WAIT_WIDTH-1:0] i_wait,
   output logic                 rw,                             
   output logic [MEM_ADDR_WIDTH-1:0] write_addr,
   output logic [PIXEL_WIDTH-1:0] write_data,   
   output logic [SPRITE_WIDTH-1:0] x_pos,       
   output logic [SPRITE_HEIGHT-1:0] y_pos,      
   input  logic [PIXEL_WIDTH-1:0] pixel_out,    
   output logic                 done                            
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

   // Internal registers
   logic [MEM_ADDR_WIDTH-1:0] addr_counter; 
   logic [PIXEL_WIDTH-1:0]    data_counter;    
   logic [WAIT_WIDTH-1:0]     wait_counter;     

   // Combinational block: next state logic and output assignments
   always_comb begin
      // Default assignments for outputs
      rw          = 1'b0;
      write_addr  = addr_counter;
      write_data  = data_counter;
      x_pos       = addr_counter % SPRITE_WIDTH;
      y_pos       = addr_counter / SPRITE_WIDTH;
      done        = 1'b0;

      case (current_state)
         IDLE: begin
            next_state = INIT_WRITE;
         end
         INIT_WRITE: begin
            next_state = WRITE;
         end
         WRITE: begin
            rw = 1'b1;
            next_state = (addr_counter == (N_ROM - 1)) ? INIT_READ : WRITE;
         end
         INIT_READ: begin
            rw = 1'b0;
            next_state = READ;
         end
         READ: begin
            rw = 1'b0;
            next_state = (addr_counter == (N_ROM - 1)) ? WAIT : READ;
         end
         WAIT: begin
            rw = 1'b0;
            next_state = (wait_counter == i_wait) ? DONE : WAIT;
         end
         DONE: begin
            done = 1'b1;
            next_state = IDLE;
         end
         default: next_state = IDLE;
      endcase
   end

   // Sequential block: state update and register updates
   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         current_state <= IDLE;
         addr_counter  <= {MEM_ADDR_WIDTH{1'b0}};
         data_counter  <= {PIXEL_WIDTH{1'b0}};
         wait_counter  <= {WAIT_WIDTH{1'b0}};
      end else begin
         current_state <= next_state;
         case (current_state)
            IDLE: begin
               addr_counter  <= {MEM_ADDR_WIDTH{1'b0}};
               data_counter  <= {PIXEL_WIDTH{1'b0}};
               wait_counter  <= {WAIT_WIDTH{1'b0}};
            end
            INIT_WRITE: begin
               addr_counter  <= {MEM_ADDR_WIDTH{1'b0}};
               data_counter  <= 24'hFF0000;
            end
            WRITE: begin
               addr_counter  <= addr_counter + 1;
               data_counter  <= data_counter + 1;
            end
            INIT_READ: begin
               addr_counter  <= {MEM_ADDR_WIDTH{1'b0}};
            end
            READ: begin
               addr_counter  <= addr_counter + 1;
            end
            WAIT: begin
               wait_counter  <= wait_counter + 1;
            end
            DONE: begin
               // Optionally, counters could be reset here if desired.
            end
            default: begin
               // No action for undefined states.
            end
         endcase
      end
   end

endmodule
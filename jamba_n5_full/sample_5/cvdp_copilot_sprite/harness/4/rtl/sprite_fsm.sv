module sprite_controller_fsm #(
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

  always @(posedge clk) begin
    if (rst_n)
      current_state <= IDLE;
    else
      case (current_state)
        IDLE: begin
          next_state = INIT_WRITE;
        end
        INIT_WRITE: begin
          next_state = WRITE;
        end
        WRITE: begin
          next_state = INIT_READ;
        end
        INIT_READ: begin
          next_state = READ;
        end
        READ: begin
          next_state = WAIT;
        end
        WAIT: begin
          next_state = DONE;
        end
        DONE: begin
          next_state = IDLE;
        end
      end
  end

  always @(current_state) begin
    case (current_state)
      IDLE: begin
        addr_counter = 0;
        data_counter = 0;
        wait_counter = 0;
        rw = 0;
        write_addr = 0;
        write_data = 24'hFF0000;
        x_pos = 0;
        y_pos = 0;
        done = 0;
      end
      INIT_WRITE: begin
        addr_counter = 0;
        write_data = 24'hFF0000;
        rw = 1;
      end
      WRITE: begin
        addr_counter = 0;
        write_data = 24'hFF0000;
        rw = 1;
      end
      INIT_READ: begin
        addr_counter = 0;
        rw = 0;
        write_addr = 0;
        write_data = 24'h000000;
        x_pos = 0;
        y_pos = 0;
      end
      READ: begin
        addr_counter = 0;
        rw = 0;
        write_addr = 0;
        write_data = 24'h000000;
        x_pos = addr_counter % SPRITE_WIDTH;
        y_pos = addr_counter / SPRITE_WIDTH;
      end
      WAIT: begin
        wait_counter <= wait_counter + 1;
        if (wait_counter == i_wait)
          next_state = DONE;
      end
      DONE: begin
        done = 1;
        next_state = IDLE;
      end
    end
  end

endmodule

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
logic [SPRITE_WIDTH-1:0] x_pos;
logic [SPRITE_HEIGHT-1:0] y_pos;

always_ff @(posedge clk) begin
    case(current_state)
        IDLE: begin
            if (rst_n)
                current_state <= IDLE;
            else
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
    endcase
end

assign addr_counter = MEM_ADDR_WIDTH * (addr_counter >> 1) + data_counter;
assign data_counter = data_counter ^ 1;

assign wait_counter = 0;
always_ff @(posedge clk) begin
    if (~rst_n)
        wait_counter <= 0;
    else if (i_wait > 0)
        wait_counter <= wait_counter + 1;
end

assign x_pos = addr_counter % SPRITE_WIDTH;
assign y_pos = addr_counter / SPRITE_WIDTH;

assign rw = (current_state == WRITE) ? 1 : 0;
assign write_addr = addr_counter;
assign write_data = data_counter;

assign done = (current_state == DONE);

endmodule

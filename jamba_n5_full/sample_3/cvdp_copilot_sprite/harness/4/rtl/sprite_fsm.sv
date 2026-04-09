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

reg [MEM_ADDR_WIDTH-1:0] addr_counter;
reg [PIXEL_WIDTH-1:0] data_counter;
reg [WAIT_WIDTH-1:0] wait_counter;
logic current_state, next_state;

localparam IDLE = 2'd0;
localparam INIT_WRITE = 2'd1;
localparam WRITE = 2'd2;
localparam INIT_READ = 2'd3;
localparam READ = 2'd4;
localparam WAIT = 2'd5;
localparam DONE = 2'd6;

always @(posedge clk) begin
    case (current_state)
        IDLE: begin
            if (!rst_n)
                next_state = INIT_WRITE;
            else
                next_state = IDLE;
        end
        INIT_WRITE: begin
            next_state = WRITE;
        end
        WRITE: begin
            write_addr = addr_counter;
            write_data = data_counter;
            rw = 1;
            next_state = INIT_READ;
        end
        INIT_READ: begin
            addr_counter = 0;
            data_counter = 0;
            wait_counter = 0;
            next_state = READ;
        end
        READ: begin
            x_pos = addr_counter % SPRITE_WIDTH;
            y_pos = addr_counter / SPRITE_WIDTH;
            pixel_out = data_counter[PIXEL_WIDTH-1:0];
            done = 1'b1;
            next_state = WAIT;
        end
        WAIT: begin
            wait_counter <= wait_counter + 1;
            if (wait_counter == i_wait) begin
                next_state = DONE;
            end else
                next_state = WAIT;
        end
        DONE: begin
            next_state = IDLE;
            done = 1'b0;
        end
    endcase
end

assign rw = current_state == WRITE ? 1 : 0;
assign write_addr = current_state == WRITE ? addr_counter : 0;
assign write_data = current_state == WRITE ? data_counter : 0;
assign x_pos = current_state == READ ? addr_counter % SPRITE_WIDTH : 0;
assign y_pos = current_state == READ ? addr_counter / SPRITE_WIDTH : 0;
assign done = current_state == DONE;

endmodule

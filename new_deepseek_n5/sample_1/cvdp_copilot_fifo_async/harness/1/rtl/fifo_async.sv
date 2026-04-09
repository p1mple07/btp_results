parameter DATA_WIDTH = 8;
parameter DEPTH = 16;

input
  clock write_clk,
  clock read_clk,
  wire [DATA_WIDTH-1:0] write_data,
  wire [DATA_WIDTH-1:0] read_data,
  wire w_rst,
  wire w_inc,
  wire w_clk,
  wire r_rst,
  wire r_inc,
  wire w_full,
  wire r_empty;

output
  wire [DATA_WIDTH-1:0] read_data,
  wire w_full,
  wire r_empty;

state state machine (
  input
    input logic w_rst,
    input logic w_inc,
    input logic w_clk,
    input logic r_rst,
    input logic r_inc,
    input clock read_clk,
    input clock write_clk,
    input wire [DATA_WIDTH-1:0] write_data,
    input wire [DATA_WIDTH-1:0] read_data,
    input wire w_full,
    input wire r_empty
  output
    output logic w_full,
    output logic r_empty
);

initial state = 0;

always_ff @(w_rst or r_rst) begin
  state = 0;
end

always_ff @* begin
  case (state)
    0:
      // Initialization
      if (w_rst & r_rst) begin
        w_full = 1;
        r_empty = 1;
        state = 1;
      end
      default: state = 1;
    1:
      // Write operation
      if (w_inc && w_clk) begin
        // Check if write pointer is full
        if (write_ptr == DEPTH) begin
          w_full = 1;
          state = 2;
        end else begin
          write_ptr = write_ptr + 1;
          // Check if write pointer overflows
          if (write_ptr >= DEPTH) begin
            write_ptr = 0;
            w_full = 1;
            state = 2;
          end
          w_full = 0;
          w_data = [DATA_WIDTH-1:0] 0;
        end
      end
      default: state = 2;
    2:
      // Read operation
      if (r_inc && r_clk) begin
        // Check if read pointer is empty
        if (read_ptr == 0) begin
          r_empty = 1;
          state = 3;
        end else begin
          read_ptr = read_ptr + 1;
          // Check if read pointer overflows
          if (read_ptr > DEPTH) begin
            read_ptr = 0;
            r_empty = 1;
            state = 3;
          end
          r_empty = 0;
          r_data = [DATA_WIDTH-1:0] 0;
        end
      end
      default: state = 3;
    3:
      // Error state
      if (w_inc & r_inc) begin
        // Both write and read enable signals are active
        state = 4;
      end
      default: state = 4;
    4:
      // Blocked state
      state = 4;
  endcase
end

// Synchronization between write and read clocks
wire [DATA_WIDTH-1:0] write_ptr;
wire [DATA_WIDTH-1:0] read_ptr;

always @* begin
  // Pass write pointer from write clock to read clock domain
  read_ptr = read_ptr + write_ptr;
  read_ptr = read_ptr & ((1 << DATA_WIDTH) - 1);
  
  // Pass read pointer from read clock to write clock domain
  write_ptr = write_ptr + read_ptr;
  write_ptr = write_ptr & ((1 << DATA_WIDTH) - 1);
end
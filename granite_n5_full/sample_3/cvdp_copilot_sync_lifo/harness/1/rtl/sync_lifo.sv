module sync_lifo #(
  parameter int unsigned DATA_WIDTH = 8, // Data width in bits
  parameter int unsigned ADDR_WIDTH = 3  // Address width in bits
)(
  input logic                    clock,     // Clock signal
  input logic                    reset,     // Synchronous reset
  input logic                    write_en,  // Write enable signal
  input logic                    read_en,   // Read enable signal
  input logic [DATA_WIDTH-1:0] data_in,   // Input data
  output logic                   empty,     // Empty flag
  output logic                   full,      // Full flag
  output logic [DATA_WIDTH-1:0] data_out   // Output data
);

  typedef enum logic {
    IDLE,
    WRITE,
    READ
  } state_t;

  localparam int unsigned DEPTH = 2**ADDR_WIDTH;  // Depth of the FIFO

  state_t state, next_state;
  logic [DATA_WIDTH-1:0] fifo[DEPTH];  // Memory array for the FIFO
  int unsigned write_ptr, read_ptr;  // Pointers for writing and reading

  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      write_ptr <= 0;
      read_ptr <= 0;
      empty <= 1'b1;
      full <= 1'b0;
    end else begin
      state <= next_state;

      case (state)
        IDLE: begin
          if (write_en &&!full) begin
            fifo[write_ptr] <= data_in;
            write_ptr <= write_ptr + 1;
            next_state <= WRITE;
          end else if (read_en &&!empty) begin
            data_out <= fifo[read_ptr];
            read_ptr <= read_ptr + 1;
            next_state <= READ;
          end else begin
            next_state <= IDLE;
          end
        end
        WRITE: begin
          next_state <= IDLE;
        end
        READ: begin
          next_state <= IDLE;
        end
      endcase
    end
  end

  assign empty = (write_ptr == read_ptr);
  assign full = ((write_ptr + 1) % DEPTH == read_ptr);

endmodule
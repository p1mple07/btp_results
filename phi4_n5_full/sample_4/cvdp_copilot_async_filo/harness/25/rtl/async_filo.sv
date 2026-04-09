module async_filo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 8
) (
    input  wire                  w_clk,    // Write clock
    input  wire                  w_rst,    // Write reset (asynchronous)
    input  wire                  push,     // Push signal
    input  wire                  r_rst,    // Read reset (asynchronous)
    input  wire                  r_clk,    // Read clock
    input  wire                  pop,      // Pop signal
    input  wire [DATA_WIDTH-1:0] w_data,   // Data input for push
    output logic [DATA_WIDTH-1:0] r_data,   // Data output for pop
    output logic                  r_empty,  // Empty flag
    output logic                  w_full    // Full flag
);

  // Calculate the required address width
  localparam ADDR_WIDTH = $clog2(DEPTH);

  // Binary counters for write and read operations.
  // One extra bit is used to help determine full/empty conditions.
  reg [ADDR_WIDTH:0] w_count;
  reg [ADDR_WIDTH:0] r_count;

  // Gray-coded pointers derived from the binary counters.
  wire [ADDR_WIDTH:0] w_ptr;
  wire [ADDR_WIDTH:0] r_ptr;
  assign w_ptr = bin2gray(w_count);
  assign r_ptr = bin2gray(r_count);

  // Memory array (dual-port RAM inferred for asynchronous FIFO)
  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Memory access addresses (only the lower bits are used)
  wire [ADDR_WIDTH-1:0] w_addr;
  wire [ADDR_WIDTH-1:0] r_addr;
  assign w_addr = w_count[ADDR_WIDTH-1:0];
  assign r_addr = r_count[ADDR_WIDTH-1:0];

  //--------------------------------------------------------------------------
  // Write Domain: Update write counter and write data into memory.
  //--------------------------------------------------------------------------

  always @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      w_count <= 0;
    end else if (push && !w_full) begin
      w_count <= w_count + 1;
    end
  end

  always @(posedge w_clk or posedge w_rst) begin
    if (w_rst)
      ; // Do nothing on reset
    else if (push && !w_full)
      mem[w_addr] <= w_data;
  end

  //--------------------------------------------------------------------------
  // Read Domain: Update read counter.
  // Memory read is performed via a dual-port read.
  //--------------------------------------------------------------------------

  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      r_count <= 0;
    end else if (pop && !r_empty) begin
      r_count <= r_count + 1;
    end
  end

  assign r_data = mem[r_addr];

  //--------------------------------------------------------------------------
  // Full Flag Generation in Write Domain
  // A synchronizer is used to safely cross the clock domains.
  //--------------------------------------------------------------------------

  // Synchronize the read pointer and its MSB (from the read domain) into the write domain.
  reg [ADDR_WIDTH:0] r_ptr_sync1, r_ptr_sync2;
  reg [ADDR_WIDTH:0] r_count_sync1, r_count_sync2;
  always @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      r_ptr_sync1  <= 0;
      r_ptr_sync2  <= 0;
      r_count_sync1<= 0;
      r_count_sync2<= 0;
    end else begin
      r_ptr_sync1  <= r_ptr;
      r_ptr_sync2  <= r_ptr_sync1;
      r_count_sync1<= r_count;
      r_count_sync2<= r_count_sync1;
    end
  end

  // When the Gray-coded pointers match, the FIFO is either full or empty.
  // The extra MSB is used to distinguish between the two.
  assign w_full = (w_ptr == r_ptr_sync2) &&
                   (w_count[ADDR_WIDTH] != r_count_sync2[ADDR_WIDTH]);

  //--------------------------------------------------------------------------
  // Empty Flag Generation in Read Domain
  // A synchronizer is used to safely cross the clock domains.
  //--------------------------------------------------------------------------

  // Synchronize the write pointer into the read domain.
  reg [ADDR_WIDTH:0] w_ptr_sync1, w_ptr_sync2;
  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      w_ptr_sync1 <= 0;
      w_ptr_sync2 <= 0;
    end else begin
      w_ptr_sync1 <= w_ptr;
      w_ptr_sync2 <= w_ptr_sync1;
    end
  end

  assign r_empty = (r_ptr == w_ptr_sync2);

  //--------------------------------------------------------------------------
  // Helper Functions: Binary-to-Gray and Gray-to-Binary conversion
  //--------------------------------------------------------------------------

  function automatic [ADDR_WIDTH:0] bin2gray(input [ADDR_WIDTH:0] bin);
    bin2gray = bin ^ (bin >> 1);
  endfunction

  function automatic [ADDR_WIDTH:0] gray2bin(input [ADDR_WIDTH:0] gray);
    gray2bin = gray;
    for (int i = 1; i <= ADDR_WIDTH; i++) begin
      gray2bin[i] = gray2bin[i] ^ gray2bin[i-1];
    end
  endfunction

endmodule
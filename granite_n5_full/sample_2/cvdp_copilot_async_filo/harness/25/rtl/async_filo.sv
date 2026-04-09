module async_filo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 8
) (
    input                         w_clk,    // Write clock
    input                         w_rst,    // Write reset
    input                         push,     // Push signal
    input                         r_rst,    // Read reset
    input                         r_clk,    // Read clock
    input                         pop,      // Pop signal
    input        [DATA_WIDTH-1:0] w_data,   // Data input for push
    output logic [DATA_WIDTH-1:0] r_data,   // Data output for pop
    output logic                  r_empty,  // Empty flag
    output logic                  w_full     // Full flag
);

  // Address width
  localparam ADDR_WIDTH = $clog2(DEPTH);

  // Address pointers
  logic [ADDR_WIDTH:0] w_ptr;
  logic [ADDR_WIDTH:0] r_ptr;
  logic [ADDR_WIDTH:0] w_ptr_next;
  logic [ADDR_WIDTH:0] r_ptr_next;

  logic [DATA_WIDTH-1:0] mem[0:DEPTH-1];
  wire [ADDR_WIDTH-1:0] w_addr;
  wire [ADDR_WIDTH-1:0] r_addr;


  logic w_full_d1;

  logic [ADDR_WIDTH+1:0] w_full_f1;
  always @(posedge w_clk) begin
    w_full_f1 <= w_count_next_bin;
  end

  always @(posedge w_clk) begin
    w_ptr <= r_ptr_1;
  end

  always @* begin
    if (push) w_full_d1 <= 1;
  end

  logic [ADDR_WIDTH+1:0] w_full_f1;
  always @(posedge w_clk) begin
    if (push &&!w_full) w_addr = w_count_bin;
  end

  always @(posedge w_clk, posedge w_rst) begin
    if (w_rst) begin
      w_addr <= 0;
    end else begin
      w_addr <= w_count_bin + ({(ADDR_WIDTH+1){push}} & ~{(ADDR_WIDTH+1){w_full}};
    end
  end

  always @(posedge w_clk, posedge w_rst) begin
    if (w_rst) begin
      w_addr <= 0;
    end else begin
      w_addr <= w_count_bin + ({(ADDR_WIDTH+1){push}} & ~{(ADDR_WIDTH+1){w_full}};
    end
  end

  always @(posedge w_clk, posedge w_rst) begin
    if (w_rst) begin
      w_addr <= 0;
    end else begin
      w_addr <= w_count_bin + ({(ADDR_WIDTH+1){push}} & ~{(ADDR_WIDTH+1){w_full};
    end
  end

  always @(posedge w_clk) begin
    wq1_rptr = r_ptr;
  end

  always @(posedge r_clk, posedge r_rst) begin
    if (r_rst) begin
      r_addr <= 0;
    end else begin
      r_addr <= r_count_bin;
    end
  end

  always @(posedge w_clk, posedge w_rst) begin
    if (w_rst) begin
      rq1_wptr = wq1_rptr.
    end else begin
      rq1_wptr = gray2bin(rq1_wptr).
    end
  end

  always @(posedge r_clk, posedge r_rst) begin
    if (r_rst) begin
      r_addr <= 0;
    end else begin
      r_addr <= r_count_bin;
    end
  end

  always @* begin
    if (push) begin
      w_full_d1 <= 1;
    end
  end

  always @(posedge w_clk, posedge w_rst) begin
    if (w_rst) begin
      w_addr <= 0;
    end else begin
      w_addr <= w_count_bin[ADDR_WIDTH-1:0] + ({(ADDR_WIDTH+1:0] + ({ADDR_WIDTH+1:0] +1:0]
    end


endmodule
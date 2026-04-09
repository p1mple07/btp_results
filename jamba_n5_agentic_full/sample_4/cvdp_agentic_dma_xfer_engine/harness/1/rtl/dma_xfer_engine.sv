module dma_xfer_engine;

  // Ports
  input  clk,
        rstn,
        addr,
        we,
        wd,
        rd,
        dma_req,
        bus_grant,
        rd_m,
        bus_req,
        bus_lock,
        addr_m,
        we_m,
        wd_m;

  // Internal state
  enum logic { IDLE, WB, TR } state;
  state $random(state);

  // Counters
  always @(posedge clk) begin
    if (state == IDLE) begin
      if (dma_req) begin
        state <= WB;
      end
    end else if (state == WB) begin
      if (bus_grant) begin
        state <= TR;
      end
    end else if (state == TR) begin
      if (cnt < max_count) begin
        state <= IDLE;
      end else begin
        state <= WB;
      end
    end
  end

  // Registers
  reg [3:0] cnt;
  reg [9:0] src_size, dest_size;
  reg [31:0] wd_addr;
  reg [31:0] rd_addr;
  reg [31:0] wd_data;
  reg [31:0] rd_data;
  reg [31:0] src_data;
  reg [31:0] dst_data;

  // Internal buffer for read-before-write
  reg [31:0] buffer;

  // Internal counters
  localparam MAX_COUNT = 100;
  reg [LOG2_MAX-1:0] counter;

  // Generate counters
  always @(posedge clk) begin
    if (state == IDLE) counter <= 0;
    if (state == WB) counter <= cnt;
    if (state == TR) counter <= cnt;
  end

  // Main logic
  assign wd_data = (state == WB) ? wd_addr[31:0] : 0;
  assign rd_data = (state == TR) ? rd_addr[31:0] : 0;

  // Read and write logic
  always @(negedge clk or posedge rstn) begin
    if (!rstn) begin
      state <= IDLE;
      cnt <= 0;
      src_size <= 0;
      dest_size <= 0;
      wd_addr <= 32'h0;
      rd_addr <= 32'h0;
      wd_data <= 0;
      rd_data <= 0;
      buffer <= 32'h0;
    end else begin
      if (state == IDLE) begin
        if (dma_req) begin
          state <= WB;
        end
      end else begin
        if (bus_grant) begin
          state <= TR;
        end
      end
    end
  end

  // Bus arbitration
  always @(*) begin
    if (bus_req) begin
      bus_lock <= 1;
    end else if (bus_lock) begin
      bus_lock <= 0;
    end
  end

  // Read data from bus
  assign rd_m = (bus_req && !bus_lock) ? rd_data : 0;

  // Write data to bus
  assign wd_m = (bus_req && !bus_lock) ? wd_data : 0;

  // Pack data into registers
  always @(posedge clk) begin
    if (state == WB) begin
      if (cnt > 0) begin
        // Pack data into wd_data
        wd_data = wd_addr[31:0];
      end else if (cnt > 0) begin
        // Pack data into rd_data
        rd_data = rd_addr[31:0];
      end
    end else if (state == TR) begin
      // Pack data into src_data and dst_data
      if (inc_src) begin
        src_data = src_data + src_size;
      end
      if (inc_dest) begin
        dst_data = dst_data + dest_size;
      end
    end
  end

  // Transfer count update
  always @(posedge clk) begin
    if (state == IDLE) begin
      if (dma_req) begin
        cnt <= 0;
      end
    end else if (state == WB) begin
      cnt <= cnt + 1;
    end else if (state == TR) begin
      cnt <= cnt + 1;
    end
  end

  // Return to IDLE
  always @(posedge clk) begin
    if (state == TR) begin
      if (cnt == 0) begin
        state <= IDLE;
      end
    end
  end

endmodule

module data_bus_controller #(
  parameter AFINITY = 0
  )(
  input         clk     ,
  input         rst_n   ,

  output        m0_read ,
  input         m0_valid,
  input [31:0]  m0_data ,

  output        m1_read ,
  input         m1_valid,
  input [31:0]  m1_data ,

  input         s_read  ,
  output        s_valid ,
  output [31:0] s_data 
);

  // Define internal signals
  reg m0_ready;
  reg m1_ready;
  wire s_ready_wire;

  // Assign m0_ready and m1_ready based on AFINITY parameter
  always @* begin
    if (AFINITY == 0) begin
      m0_ready = m0_valid & ~s_ready_wire;
      m1_ready = m1_valid & ~s_ready_wire;
    end else begin
      m0_ready = m0_valid & s_ready_wire;
      m1_ready = m1_valid & s_ready_wire;
    end
  end

  // Update s_ready_wire based on the arbitration of m0_ready and m1_ready
  assign s_ready_wire = m0_ready | m1_ready;

  // Implement the ready-valid handshake mechanism for m0
  always @(posedge clk or posedge rst_n) begin
    if (!rst_n) begin
      m0_read <= 1'b0;
    end else begin
      if (m0_ready && m0_valid) begin
        m0_read <= 1'b1;
      end else begin
        m0_read <= 1'b0;
      end
    end
  end

  // Implement the ready-valid handshake mechanism for m1
  always @(posedge clk or posedge rst_n) begin
    if (!rst_n) begin
      m1_read <= 1'b0;
    end else begin
      if (m1_ready && m1_valid) begin
        m1_read <= 1'b1;
      end else begin
        m1_read <= 1'b0;
      end
    end
  end

  // Implement the ready-valid handshake mechanism for s
  always @(posedge clk or posedge rst_n) begin
    if (!rst_n) begin
      s_valid <= 1'b0;
    end else begin
      if (s_ready && m0_ready && m1_ready) begin
        s_valid <= 1'b1;
      end else begin
        s_valid <= 1'b0;
      end
    end
  end

endmodule
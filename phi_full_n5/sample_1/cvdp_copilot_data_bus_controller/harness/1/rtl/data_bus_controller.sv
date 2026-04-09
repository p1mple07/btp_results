module data_bus_controller #(
  parameter AFINITY = 0
  )(
  input         clk      ,
  input         rst_n    ,

  output        m0_read  ,
  input         m0_valid ,
  input [31:0]  m0_data  ,

  output        m1_read  ,
  input         m1_valid ,
  input [31:0]  m1_data  ,

  input         s_read   ,
  output        s_valid  ,
  output [31:0] s_data 
);

  logic m0_ready;
  logic m1_ready;
  logic s_ready;

  assign m0_ready = s_valid & s_ready;
  assign m1_ready = s_valid & s_ready;

  always_ff @(posedge clk) begin
    if (rst_n) begin
      m0_valid <= 1'b0;
      m1_valid <= 1'b0;
      s_valid <= 1'b0;
      m0_data <= 32'h0;
      m1_data <= 32'h0;
      s_data <= 32'h0;
    end else begin
      case (AFINITY)
        0: begin
          if (m0_valid && !m1_valid) begin
            m0_read <= 1'b1;
            s_valid <= m0_valid;
            s_data <= m0_data;
          end
        end
        1: begin
          if (m1_valid && !m0_valid) begin
            m1_read <= 1'b1;
            s_valid <= m1_valid;
            s_data <= m1_data;
          end
        end
        default: begin
          m0_read <= 1'b0;
          m1_read <= 1'b0;
          s_valid <= 1'b0;
          s_data <= 32'h0;
        end
      endcase
    end
  end

  assign s_ready = m0_ready | m1_ready;

endmodule

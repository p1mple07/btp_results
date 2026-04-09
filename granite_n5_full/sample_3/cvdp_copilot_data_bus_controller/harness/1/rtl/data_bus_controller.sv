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

  // Implement the state machine to manage the read and write operations
  enum logic[1:0] { Idle, Read_M0, Read_M1, Write_S } state, next_state;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= Idle;
    end else begin
      state <= next_state;
    end
  end

  assign m0_read   = (state == Read_M0);
  assign m1_read   = (state == Read_M1);
  assign s_valid    = (state == Write_S);

  always_comb begin
    case (state)
      Idle: begin
        if (m0_valid &&!m0_ready) begin
          next_state = Read_M0;
        end else if (m1_valid &&!m1_ready) begin
          next_state = Read_M1;
        end else if (s_ready) begin
          next_state = Write_S;
        end else begin
          next_state = Idle;
        end
      end

      Read_M0: begin
        if (m0_valid &&!m0_ready) begin
          next_state = Read_M0;
        end else begin
          next_state = Idle;
        end
      end

      Read_M1: begin
        if (m1_valid &&!m1_ready) begin
          next_state = Read_M1;
        end else begin
          next_state = Idle;
        end
      end

      Write_S: begin
        if (s_ready) begin
          next_state = Idle;
        end else begin
          next_state = Write_S;
        end
      end
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      s_data <= '0;
    end else begin
      if (state == Write_S && s_ready) begin
        s_data <= m0_data & {{32-AFINITY{m1_data[0]}}, m1_data};
      end
    end
  end

endmodule
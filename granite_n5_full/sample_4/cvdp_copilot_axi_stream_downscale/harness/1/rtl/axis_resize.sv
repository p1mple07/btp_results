module axis_resize (

  input  wire                         clk,
  input  wire                         resetn,
  input  wire                         s_valid,
  output wire                         s_ready,
  input  wire  [15:0]                s_data,
  output wire                         m_valid,
  input  wire                         m_ready,
  output wire  [7:0]                 m_data
);

  reg         valid;
  reg  [7:0] ready_counter;
  reg         s_ready_dly;

  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      valid <= 1'b0;
      ready_counter <= 0;
      s_ready_dly <= 1'b0;
    end else begin
      s_ready_dly <= s_ready;
      if (s_valid &&!valid) begin
        valid <= 1'b1;
        ready_counter <= 0;
      end else if (s_ready_dly && valid) begin
        valid <= 1'b0;
        if (ready_counter == 15) begin
          ready_counter <= 0;
        end else begin
          ready_counter <= ready_counter + 1;
        end
      end
    end
  end

  assign m_valid = valid;
  assign m_data = s_data[15:8];
  assign s_ready =!valid | (ready_counter!= 0);

endmodule
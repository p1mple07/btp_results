module axis_joiner (
  input  logic         clk,
  input  logic         rst,
  // AXI Stream Input 1
  input  logic [7:0]   s_axis_tdata_1,
  input  logic         s_axis_tvalid_1,
  output logic         s_axis_tready_1,
  input  logic         s_axis_tlast_1,
  // AXI Stream Input 2
  input  logic [7:0]   s_axis_tdata_2,
  input  logic         s_axis_tvalid_2,
  output logic         s_axis_tready_2,
  input  logic         s_axis_tlast_2,
  // AXI Stream Input 3
  input  logic [7:0]   s_axis_tdata_3,
  input  logic         s_axis_tvalid_3,
  output logic         s_axis_tready_3,
  input  logic         s_axis_tlast_3,
  // Merged AXI Stream Output
  output logic [7:0]   m_axis_tdata,
  output logic         m_axis_tvalid,
  input  logic         m_axis_tready,
  output logic         m_axis_tlast,
  output logic [1:0]   m_axis_tuser,
  output logic         busy
);

  // FSM state encoding
  localparam integer STATE_IDLE = 0,
                    STATE_1    = 1,
                    STATE_2    = 2,
                    STATE_3    = 3;

  // Internal registers for FSM state and buffering
  reg [1:0] state;
  reg       temp_flag;          // Indicates that data is buffered
  reg [7:0] buffered_data;
  reg       buffered_last;
  reg [1:0] buffered_tuser;

  // Drive input ready signals based on active state
  assign s_axis_tready_1 = (state == STATE_1);
  assign s_axis_tready_2 = (state == STATE_2);
  assign s_axis_tready_3 = (state == STATE_3);

  // Drive merged AXI Stream output signals
  // When temp_flag is asserted, output the buffered data; otherwise, use the active input stream.
  assign m_axis_tvalid  = ((state != STATE_IDLE) || temp_flag);
  assign m_axis_tdata   = (temp_flag) ? buffered_data :
                            ( (state == STATE_1) ? s_axis_tdata_1 :
                              ( (state == STATE_2) ? s_axis_tdata_2 : s_axis_tdata_3) );
  assign m_axis_tlast   = (temp_flag) ? buffered_last :
                            ( (state == STATE_1) ? s_axis_tlast_1 :
                              ( (state == STATE_2) ? s_axis_tlast_2 : s_axis_tlast_3) );
  assign m_axis_tuser   = (temp_flag) ? buffered_tuser :
                            ( (state == STATE_1) ? 2'b01 :
                              ( (state == STATE_2) ? 2'b10 : 2'b11) );

  // busy indicates that the module is processing data (either actively transferring or buffering)
  assign busy = ((state != STATE_IDLE) || temp_flag);

  // FSM and buffering control logic
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state           <= STATE_IDLE;
      temp_flag       <= 1'b0;
      buffered_data   <= 8'd0;
      buffered_last   <= 1'b0;
      buffered_tuser  <= 2'd0;
    end
    else begin
      if (m_axis_tready) begin
        // If there is buffered data, output it and clear the buffer.
        if (temp_flag) begin
          temp_flag <= 1'b0;
        end

        // Update state machine based on current state and input valid signals.
        case (state)
          STATE_IDLE: begin
            if (s_axis_tvalid_1)
              state <= STATE_1;
            else if (s_axis_tvalid_2)
              state <= STATE_2;
            else if (s_axis_tvalid_3)
              state <= STATE_3;
            else
              state <= STATE_IDLE;
          end
          STATE_1: begin
            // Once the packet is complete (tlast asserted), return to idle.
            if (s_axis_tvalid_1 && s_axis_tlast_1)
              state <= STATE_IDLE;
            // Else remain in STATE_1 to continue transferring the packet.
          end
          STATE_2: begin
            if (s_axis_tvalid_2 && s_axis_tlast_2)
              state <= STATE_IDLE;
          end
          STATE_3: begin
            if (s_axis_tvalid_3 && s_axis_tlast_3)
              state <= STATE_IDLE;
          end
          default: begin
            state <= STATE_IDLE;
          end
        endcase
      end
      else begin
        // m_axis_tready is deasserted: buffer the current data from the active input stream.
        case (state)
          STATE_1: begin
            buffered_data <= s_axis_tdata_1;
            buffered_last <= s_axis_tlast_1;
            buffered_tuser <= 2'b01;  // TAG_ID for stream 1
            temp_flag     <= 1'b1;
          end
          STATE_2: begin
            buffered_data <= s_axis_tdata_2;
            buffered_last <= s_axis_tlast_2;
            buffered_tuser <= 2'b10;  // TAG_ID for stream 2
            temp_flag     <= 1'b1;
          end
          STATE_3: begin
            buffered_data <= s_axis_tdata_3;
            buffered_last <= s_axis_tlast_3;
            buffered_tuser <= 2'b11;  // TAG_ID for stream 3
            temp_flag     <= 1'b1;
          end
          default: begin
            // No buffering action when in idle.
          end
        endcase
      end
    end
  end

endmodule
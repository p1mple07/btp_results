module merges three independent AXI Stream inputs into a single AXI Stream output using a simple fixed‐priority (round‐robin) arbitration scheme.
// The module supports data buffering when the output is not ready and tags the output data with a unique 2‐bit TAG_ID.

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
  // AXI Stream Output
  output logic [7:0]   m_axis_tdata,
  output logic         m_axis_tvalid,
  input  logic         m_axis_tready,
  output logic         m_axis_tlast,
  output logic [1:0]   m_axis_tuser,
  // Status signal
  output logic         busy
);

  // FSM state encoding
  typedef enum logic [1:0] {
    STATE_IDLE = 2'd0,
    STATE_1    = 2'd1,
    STATE_2    = 2'd2,
    STATE_3    = 2'd3
  } state_t;

  state_t state;
  // Flag to indicate that data is buffered
  logic buffered;
  // Temporary registers to hold data when m_axis_tready is low
  logic [7:0] temp_tdata;
  logic       temp_tvalid;
  logic       temp_tlast;
  logic [1:0] temp_tuser;

  // Drive input ready signals based on FSM state and output ready.
  // Only the active stream is ready to accept data.
  assign s_axis_tready_1 = (state == STATE_1) ? m_axis_tready : 1'b0;
  assign s_axis_tready_2 = (state == STATE_2) ? m_axis_tready : 1'b0;
  assign s_axis_tready_3 = (state == STATE_3) ? m_axis_tready : 1'b0;

  // busy signal is asserted when module is processing data (i.e. not in idle state)
  assign busy = (state != STATE_IDLE);

  // FSM and data buffering logic
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state         <= STATE_IDLE;
      buffered      <= 1'b0;
      temp_tdata    <= 8'd0;
      temp_tvalid   <= 1'b0;
      temp_tlast    <= 1'b0;
      temp_tuser    <= 2'd0;
    end
    else begin
      // Case 1: Buffered data exists from a previous cycle.
      if (buffered) begin
        if (m_axis_tready) begin
          // Output the buffered data.
          // If this is the last word of the packet, transition to idle.
          if (temp_tlast)
            state <= STATE_IDLE;
          // Capture new data from the currently selected input stream.
          case (state)
            STATE_1: begin
              temp_tdata    <= s_axis_tdata_1;
              temp_tvalid   <= s_axis_tvalid_1;
              temp_tlast    <= s_axis_tlast_1;
              temp_tuser    <= 2'd1;  // TAG_ID for stream 1 = 0x1
            end
            STATE_2: begin
              temp_tdata    <= s_axis_tdata_2;
              temp_tvalid   <= s_axis_tvalid_2;
              temp_tlast    <= s_axis_tlast_2;
              temp_tuser    <= 2'd2;  // TAG_ID for stream 2 = 0x2
            end
            STATE_3: begin
              temp_tdata    <= s_axis_tdata_3;
              temp_tvalid   <= s_axis_tvalid_3;
              temp_tlast    <= s_axis_tlast_3;
              temp_tuser    <= 2'd3;  // TAG_ID for stream 3 = 0x3
            end
          endcase
          // If the buffered data was the last word, clear the buffered flag.
          if (temp_tlast)
            buffered <= 1'b0;
        end
        // If m_axis_tready is low, retain the buffered data.
      end
      // Case 2: No buffered data.
      else begin
        if (m_axis_tready) begin
          // If in idle state, check for valid input streams in fixed priority order.
          if (state == STATE_IDLE) begin
            if (s_axis_tvalid_1)
              state <= STATE_1;
            else if (s_axis_tvalid_2)
              state <= STATE_2;
            else if (s_axis_tvalid_3)
              state <= STATE_3;
          end
          else begin
            // In active state, check if the current packet has ended.
            case (state)
              STATE_1: if (s_axis_tlast_1) state <= STATE_IDLE;
              STATE_2: if (s_axis_tlast_2) state <= STATE_IDLE;
              STATE_3: if (s_axis_tlast_3) state <= STATE_IDLE;
            endcase
          end
          // Capture current data into temporary registers.
          case (state)
            STATE_1: begin
              temp_tdata    <= s_axis_tdata_1;
              temp_tvalid   <= s_axis_tvalid_1;
              temp_tlast    <= s_axis_tlast_1;
              temp_tuser    <= 2'd1;
            end
            STATE_2: begin
              temp_tdata    <= s_axis_tdata_2;
              temp_tvalid   <= s_axis_tvalid_2;
              temp_tlast    <= s_axis_tlast_2;
              temp_tuser    <= 2'd2;
            end
            STATE_3: begin
              temp_tdata    <= s_axis_tdata_3;
              temp_tvalid   <= s_axis_tvalid_3;
              temp_tlast    <= s_axis_tlast_3;
              temp_tuser    <= 2'd3;
            end
          endcase
        end
        else begin
          // If m_axis_tready is low and we are in an active state, buffer the current data.
          if (state != STATE_IDLE) begin
            case (state)
              STATE_1: begin
                temp_tdata    <= s_axis_tdata_1;
                temp_tvalid   <= s_axis_tvalid_1;
                temp_tlast    <= s_axis_tlast_1;
                temp_tuser    <= 2'd1;
                buffered      <= 1'b1;
              end
              STATE_2: begin
                temp_tdata    <= s_axis_tdata_2;
                temp_tvalid   <= s_axis_tvalid_2;
                temp_tlast    <= s_axis_tlast_2;
                temp_tuser    <= 2'd2;
                buffered      <= 1'b1;
              end
              STATE_3: begin
                temp_tdata    <= s_axis_tdata_3;
                temp_tvalid   <= s_axis_tvalid_3;
                temp_tlast    <= s_axis_tlast_3;
                temp_tuser    <= 2'd3;
                buffered      <= 1'b1;
              end
            endcase
          end
        end
      end
    end
  end

  // Output assignment: use buffered data if available; otherwise, use data from active input stream.
  always_comb begin
    if (buffered) begin
      m_axis_tdata = temp_tdata;
      m_axis_tvalid = temp_tvalid;
      m_axis_tlast = temp_tlast;
      m_axis_tuser = temp_tuser;
    end
    else begin
      case (state)
        STATE_IDLE: begin
          m_axis_tdata = 8'd0;
          m_axis_tvalid = 1'b0;
          m_axis_tlast = 1'b0;
          m_axis_tuser = 2'd0;
        end
        STATE_1: begin
          m_axis_tdata = s_axis_tdata_1;
          m_axis_tvalid = s_axis_tvalid_1;
          m_axis_tlast = s_axis_tlast_1;
          m_axis_tuser = 2'd1;
        end
        STATE_2: begin
          m_axis_tdata = s_axis_tdata_2;
          m_axis_tvalid = s_axis_tvalid_2;
          m_axis_tlast = s_axis_tlast_2;
          m_axis_tuser = 2'd2;
        end
        STATE_3: begin
          m_axis_tdata = s_axis_tdata_3;
          m_axis_tvalid = s_axis_tvalid_3;
          m_axis_tlast = s_axis_tlast_3;
          m_axis_tuser = 2'd3;
        end
      endcase
    end
  end

endmodule
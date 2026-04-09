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
  // Status signal: indicates module is processing data
  output logic         busy
);

  //-------------------------------------------------------------------------
  // FSM State Encoding
  //-------------------------------------------------------------------------
  typedef enum logic [1:0] {
    STATE_IDLE = 2'd0,
    STATE_1    = 2'd1,
    STATE_2    = 2'd2,
    STATE_3    = 2'd3
  } state_t;

  state_t current_state, next_state;

  //-------------------------------------------------------------------------
  // Buffer Registers: hold the current word being transferred.
  //-------------------------------------------------------------------------
  logic [7:0]   buffered_tdata;
  logic         buffered_tlast;
  logic [1:0]   buffered_tuser;  // TAG_ID: 0x1, 0x2, 0x3 for streams 1,2,3 respectively

  //-------------------------------------------------------------------------
  // Combinational Next-State Logic
  //-------------------------------------------------------------------------
  always_comb begin
    next_state = current_state;
    case (current_state)
      STATE_IDLE: begin
        // Arbitration: check inputs in round-robin priority order.
        if (s_axis_tvalid_1)
          next_state = STATE_1;
        else if (s_axis_tvalid_2)
          next_state = STATE_2;
        else if (s_axis_tvalid_3)
          next_state = STATE_3;
        else
          next_state = STATE_IDLE;
      end
      STATE_1: begin
        // Only update state when m_axis_tready is high.
        if (m_axis_tready) begin
          // If the current buffered word indicates the end of a packet,
          // complete the transfer and return to idle.
          if (buffered_tlast)
            next_state = STATE_IDLE;
          else
            next_state = STATE_1;
        end
        else
          next_state = STATE_1;
      end
      STATE_2: begin
        if (m_axis_tready) begin
          if (buffered_tlast)
            next_state = STATE_IDLE;
          else
            next_state = STATE_2;
        end
        else
          next_state = STATE_2;
      end
      STATE_3: begin
        if (m_axis_tready) begin
          if (buffered_tlast)
            next_state = STATE_IDLE;
          else
            next_state = STATE_3;
        end
        else
          next_state = STATE_3;
      end
      default: next_state = STATE_IDLE;
    endcase
  end

  //-------------------------------------------------------------------------
  // Sequential Logic: State Update and Buffer Management
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      current_state   <= STATE_IDLE;
      buffered_tdata  <= 8'd0;
      buffered_tlast  <= 1'b0;
      buffered_tuser  <= 2'd0;
    end
    else begin
      current_state <= next_state;
      // Update the buffer only when the output is ready.
      if (m_axis_tready) begin
        case (current_state)
          STATE_1: begin
            // Capture new data from stream 1 if available.
            if (s_axis_tvalid_1) begin
              buffered_tdata  <= s_axis_tdata_1;
              buffered_tlast  <= s_axis_tlast_1;
              buffered_tuser  <= 2'd1;  // TAG_ID_1 = 0x1
            end
          end
          STATE_2: begin
            if (s_axis_tvalid_2) begin
              buffered_tdata  <= s_axis_tdata_2;
              buffered_tlast  <= s_axis_tlast_2;
              buffered_tuser  <= 2'd2;  // TAG_ID_2 = 0x2
            end
          end
          STATE_3: begin
            if (s_axis_tvalid_3) begin
              buffered_tdata  <= s_axis_tdata_3;
              buffered_tlast  <= s_axis_tlast_3;
              buffered_tuser  <= 2'd3;  // TAG_ID_3 = 0x3
            end
          end
          default: begin
            // No buffering update in STATE_IDLE.
          end
        endcase
      end
    end
  end

  //-------------------------------------------------------------------------
  // Output Assignments and s_axis_tready Generation
  //-------------------------------------------------------------------------
  always_comb begin
    // Drive merged output from the buffered registers.
    m_axis_tdata  = buffered_tdata;
    m_axis_tvalid = (current_state != STATE_IDLE);
    m_axis_tlast  = buffered_tlast;
    m_axis_tuser  = buffered_tuser;

    // Only the active input stream is acknowledged.
    s_axis_tready_1 = (current_state == STATE_1) ? m_axis_tready : 1'b0;
    s_axis_tready_2 = (current_state == STATE_2) ? m_axis_tready : 1'b0;
    s_axis_tready_3 = (current_state == STATE_3) ? m_axis_tready : 1'b0;

    // The busy signal is high when processing a packet.
    busy = (current_state != STATE_IDLE);
  end

endmodule
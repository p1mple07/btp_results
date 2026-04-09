module data_serializer #(
  parameter DATA_W   = 8,
  parameter BIT_ORDER= 0,
  parameter PARITY   = 0
)(
  // Local constants
  localparam ST RX = 1'b0;
  localparam ST TX = 1'b1;

  // Sequential state & register updates
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state_q     <= ST RX;
      shift_reg_q <= {SHIFT_W{1'b0}};
      count_q     <= 0;
    end else begin
      state_q     <= state_d;
      shift_reg_q <= shift_reg_d;
      count_q     <= count_d;
    end
  end

  // Next-state logic
  always @* begin
    // ST RX: Load parallel data + parity
    case (state_q)
      // ST RX: Load parallel data + parity
      ST RX: begin
        if (p_valid_i) begin
          if (BIT_ORDER == 0) begin
            if (EXTRA_BIT == 1)
              shift_reg_d = {parity_bit, p_data_i};
            else
              shift_reg_d = p_data_i;
          end
          else begin
            if (EXTRA_BIT == 1) begin
              shift_reg_d[8:4] = {p_data_i[4:0], parity_bit};
              shift_reg_d[3:0] = p_data_i[8:5];
            end else begin
              shift_reg_d = p_data_i;
            end
          end;
          count_d = 0;
          state_d = ST_TX;
        end else begin
          state_d = ST_RX;
        end
      end

      // ST TX: Shift bits out until SHIFT_W done
      ST TX: begin
        if (p_valid_i && tx_en_i) begin
          if (count_q == (SHIFT_W - 1)) begin
            // Done sending SHIFT_W bits
            state_d   = ST RX;
            shift_reg_d = shift_reg_q;
            count_d    = 0;
          end else begin
            if (BIT_ORDER == 1) begin
              if (EXTRA_BIT == 1) begin
                shift_reg_d[SHIFT_W-1:2] = shift_reg_q[SHIFT_W-3:0];
                shift_reg_d[1:0]      = 2'b00;
              end else begin
                shift_reg_d = {shift_reg_q[SHIFT_W-2:0], 1'b00};
              end
              count_d = count_q + 1;
            end else begin
              shift_reg_d = {1'b0, shift_reg_q[SHIFT_W-1:1]};
              count_d = count_q + 1;
            end
          end
        end else begin
          state_d = ST_RX;
        end
      end

      default: begin
        state_d = ST_RX;
      end
    endcase
  end

  // Outputs
  assign s_valid_o = (state_q == ST RX);
  assign s_data_o  = (BIT_ORDER == 0) ? shift_reg_q[0] : shift_reg_q[SHIFT_W-1];
  assign p_ready_o = (state_q == ST TX);
  assign p_ready_o = (state_q == ST TX);
  assign s_valid_o = (state_q == ST RX);
  assign s_data_o = (BIT_ORDER == 0) ? shift_reg_q[0] : shift_reg_q[SHIFT_W-1];
  assign p_ready_o = (state_q == ST TX);
  assign p_ready_o = (state_q == ST TX);
  assign s_valid_o = (state_q == ST RX);
  assign s_data_o = (BIT_ORDER == 0) ? shift_reg_q[0] : shift_reg_q[SHIFT_W-1];
  assign p_ready_o = (state_q == ST TX);
  assign p_ready_o = (state_q == ST TX);
  assign s_valid_o = (state_q == ST RX);
  assign s_data_o = (BIT_ORDER == 0) ? shift_reg_q[0] : shift_reg_q[SHIFT_W-1];
  assign p_ready_o = (state_q == ST TX);
  assign p_ready_o = (state_q == ST TX);
  assign s_valid_o = (state_q == ST RX);
  assign s_data_o = (BIT_ORDER == 0) ? shift_reg_q[0] : shift_reg_q[SHIFT_W-1];
  assign p_ready_o = (state_q == ST TX);
  assign p_ready_o = (state_q == ST TX);
  assign s_valid_o = (state_q == ST RX);
  assign s_data_o = (BIT_ORDER == 0) ? shift_reg_q[0] : shift_reg_q[SHIFT_W-1];
  assign p_ready_o = (state_q == ST TX);
  assign p_ready_o = (state_q == ST TX);
  assign s_valid_o = (state_q == ST RX);
  assign s_data_o = (BIT_ORDER == 0) ? shift_reg_q[0] : shift_reg_q[SHIFT_W-1];
  assign p_ready_o = (state_q == ST TX);
  assign p_ready_o = (state_q == ST TX);
  assign s_valid_o = (state_q == ST RX);
  assign s_data_o = (BIT_ORDER == 0) ? shift_reg_q[0] : shift_reg_q[SHIFT_W-1];
  assign p_ready_o = (state_q == ST TX);
  assign p_ready_o = (state_q == ST TX);
  assign s_valid_o = (state_q == ST RX);
  assign s_data_o = (BIT_ORDER == 0) ? shift_reg_q[0] : shift_reg_q[SHIFT_W-1];
  assign p_ready_o = (state_q == ST TX);
  assign p_ready_o = (state_q == ST TX);
  assign s_valid_o = (state_q == ST RX);
  assign s_data_o = (BIT_ORDER == 0) ? shift_reg_q[0] : shift_reg_q[SHIFT_W-1];
  assign p_ready_o = (state_q == ST TX);
  assign p_ready_o = (state_q == ST TX);
  assign s_valid_o = (state_q == ST RX);
  assign s_data_o = (BIT_ORDER == 0) ? shift_reg_q[0] : shift_reg_q[SHIFT_W-1];
  assign p_ready_o = (state_q == ST TX);
  assign p_ready_o = (state_q == ST TX);
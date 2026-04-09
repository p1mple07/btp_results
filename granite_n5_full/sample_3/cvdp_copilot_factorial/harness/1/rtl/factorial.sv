module factorial (
  input logic clk,
  input logic arst_n,
  input logic [4:0] num_in,
  input logic start,
  output logic busy,
  output logic [63:0] fact,
  output logic done
);

  typedef enum logic {IDLE, BUSY, DONE} fsm_state;
  fsm_state state, next_state;

  always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always_comb begin
    case (state)
      IDLE:
        if (start) begin
          next_state = BUSY;
        end else begin
          next_state = IDLE;
        end

      BUSY:
        next_state = DONE;

      DONE:
        next_state = DONE;
    endcase
  end

  always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      fact <= 0;
    end else begin
      case (state)
        IDLE:
        BUSY:
          // Calculate factorial
          fact <= 1;
          for (int i = 1; i <= num_in; i = i + 1) begin
            fact <= fact * i;
          end

        DONE:
          done <= 1;
      endcase
    end
  end

  assign busy = (state == BUSY);

endmodule
module sorting_engine #(parameter integer N = 8, parameter integer WIDTH = 8) (
    input  logic           clk,
    input  logic           rst,
    input  logic           start,
    input  logic [N*WIDTH-1:0] in_data,
    output logic           done,
    output logic [N*WIDTH-1:0] out_data
);

  // Define the FSM states
  typedef enum logic [1:0] {
    STATE_IDLE   = 2'd0,
    STATE_SORTING= 2'd1,
    STATE_DONE   = 2'd2
  } state_t;

  state_t state;
  // Counter for comparisons.
  // We perform N*(N-1) comparisons (one per clock cycle) so the maximum count is N*(N-1)-1.
  localparam integer CMP_MAX = N*(N-1) - 1;
  integer cmp_cnt;

  // Internal register array to hold the data during sorting.
  // The array is indexed from 0 to N-1.
  logic [WIDTH-1:0] data_reg [0:N-1];

  // FSM process: sequential operations on the rising edge of clk or asynchronous reset.
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state      <= STATE_IDLE;
      cmp_cnt    <= 0;
      done       <= 0;
    end
    else begin
      case (state)
        STATE_IDLE: begin
          if (start) begin
            // Load the input bus into the internal register array.
            // Each element is extracted using the +: slicing operator.
            for (int i = 0; i < N; i++) begin
              data_reg[i] <= in_data[i*WIDTH +: WIDTH];
            end
            cmp_cnt    <= 0;
            state      <= STATE_SORTING;
            done       <= 0;
          end
        end

        STATE_SORTING: begin
          if (cmp_cnt < CMP_MAX) begin
            // Determine the index for comparison.
            // For each pass, we compare adjacent elements at indices idx and idx+1.
            int idx = cmp_cnt % (N-1);
            // Compare and swap if out of order.
            if (data_reg[idx] > data_reg[idx+1]) begin
              logic [WIDTH-1:0] temp;
              temp = data_reg[idx];
              data_reg[idx] <= data_reg[idx+1];
              data_reg[idx+1] <= temp;
            end
            cmp_cnt <= cmp_cnt + 1;
          end
          else begin
            // All comparisons have been performed.
            state <= STATE_DONE;
          end
        end

        STATE_DONE: begin
          // Assert done for one clock cycle.
          done <= 1;
          // Pack the sorted data into the output bus.
          // The sorted array is in data_reg[0] ... data_reg[N-1].
          logic [N*WIDTH-1:0] temp;
          for (int i = 0; i < N; i++) begin
            temp[i*WIDTH +: WIDTH] = data_reg[i];
          end
          out_data <= temp;
          // Return to idle state; done signal will deassert in the next cycle.
          state <= STATE_IDLE;
          done <= 0;
        end

      endcase
    end
  end

endmodule
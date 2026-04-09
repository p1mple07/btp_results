module sorting_engine #(
  parameter int N    = 8,
  parameter int WIDTH = 8
)(
  input  logic         clk,
  input  logic         rst,
  input  logic         start,
  input  logic [N*WIDTH-1:0] in_data,
  output logic         done,
  output logic [N*WIDTH-1:0] out_data
);

  //-------------------------------------------------------------------------
  // FSM States
  //-------------------------------------------------------------------------
  typedef enum logic [1:0] {
    IDLE   = 2'd0,
    SORTING = 2'd1,
    DONE   = 2'd2
  } state_t;

  state_t state, next_state;

  //-------------------------------------------------------------------------
  // Internal Registers
  //-------------------------------------------------------------------------
  // Array to hold the unsorted data.
  reg [WIDTH-1:0] data [0:N-1];

  // Counter for bubble sort comparisons.
  // We perform exactly N*(N-1) comparisons.
  reg [31:0] cmp_cnt;

  //-------------------------------------------------------------------------
  // Main FSM Process
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state      <= IDLE;
      cmp_cnt    <= 0;
      done       <= 0;
    end
    else begin
      case (state)
        IDLE: begin
          // Clear done signal in IDLE.
          done <= 0;
          if (start) begin
            // Load the input array from in_data into the internal array.
            for (int j = 0; j < N; j = j + 1) begin
              data[j] <= in_data[(j+1)*WIDTH-1 -: WIDTH];
            end
            cmp_cnt <= 0;
            state   <= SORTING;
          end
        end

        SORTING: begin
          // Perform one comparison per clock cycle.
          if (cmp_cnt < (N*(N-1)) - 1) begin
            // Calculate the index for the adjacent pair.
            int idx;
            logic [WIDTH-1:0] temp;
            idx = cmp_cnt % (N-1);
            // Compare and swap if out of order.
            if (data[idx] > data[idx+1]) begin
              temp = data[idx];
              data[idx]   <= data[idx+1];
              data[idx+1] <= temp;
            end
            cmp_cnt <= cmp_cnt + 1;
          end
          else begin
            state <= DONE;
          end
        end

        DONE: begin
          // Pack the sorted array into the output bus.
          for (int j = 0; j < N; j = j + 1) begin
            out_data[(j+1)*WIDTH-1 -: WIDTH] <= data[j];
          end
          // Assert done for one clock cycle.
          done <= 1;
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule
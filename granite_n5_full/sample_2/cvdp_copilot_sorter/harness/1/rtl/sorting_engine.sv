module sorting_engine #(
  parameter int N = 8,
  parameter int WIDTH = 8
) (
  input logic clk,
  input logic rst,
  input logic start,
  input [N*WIDTH-1:0] in_data,
  output logic done,
  output logic [N*WIDTH-1:0] out_data
);

  typedef enum logic {
    IDLE,
    SORTING,
    DONE
  } fsm_state_t;

  localparam int NUM_COMPARISONS = N*(N-1);

  fsm_state_t state, next_state;
  logic [N-1:0][WIDTH-1:0] sorted_array;
  logic [NUM_COMPARISONS-1:0] comparisons;
  logic [N-1:0][WIDTH-1:0] temp_array;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
      comparisons <= '0;
      sorted_array <= '0;
    end else begin
      state <= next_state;
      comparisons <= comparisons + 1;
      temp_array <= sorted_array;

      // Perform bubble sort algorithm here
      for (int i = 1; i < N; i++) begin
        for (int j = 0; j < N-i; j++) begin
          if (temp_array[j] > temp_array[j+1]) begin
            sorted_array[j] <= temp_array[j+1];
            sorted_array[j+1] <= temp_array[j];
          end
        end
      end
    end
  end

  always_comb begin
    case (state)
      IDLE: begin
        if (start) begin
          next_state = SORTING;
        end else begin
          next_state = IDLE;
        end
      end
      SORTING: begin
        if (comparisons == NUM_COMPARISONS) begin
          next_state = DONE;
        end else begin
          next_state = SORTING;
        end
      end
      DONE: begin
        next_state = IDLE;
      end
    endcase
  end

  always_comb begin
    case (state)
      IDLE: begin
        // Initialize output data
        out_data = '0;
      end
      SORTING: begin
        // Update output data with sorted array
        out_data = sorted_array;
      end
      DONE: begin
        // Update output data with sorted array
        out_data = sorted_array;
      end
    endcase
  end

endmodule
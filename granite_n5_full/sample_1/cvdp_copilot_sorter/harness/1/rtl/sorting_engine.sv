module sorting_engine #(parameter integer N = 8, parameter integer WIDTH = 8) (
  // Clock and Reset
  input wire clk,
  input wire rst,

  // Start Signals
  input wire start,

  // Input Data Bus
  input wire [N*WIDTH-1:0] in_data,

  // Output Data Bus
  output logic [N*WIDTH-1:0] out_data,

  // Done Signal
  output logic done
);

  localparam integer NUM_COMPARISONS = (N*(N-1));

  // State Machine
  typedef enum logic {
    IDLE,
    SORTING,
    DONE
  } fsm_state;

  logic [NUM_COMPARISONS-1:0] comparisons;
  logic [WIDTH-1:0] data_a, data_b;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reset Internals
      comparisons <= '0;
      data_a <= '0;
      data_b <= '0;
      fsm_state <= IDLE;
    end else begin
      case(fsm_state)
        IDLE: begin
          // Start Signals
          if (start) begin
            comparisons <= '0;
            data_a <= in_data[N*WIDTH-1:WIDTH];
            data_b <= in_data[(N-1)*WIDTH-1:0];
            fsm_state <= SORTING;
          end
        end
        SORTING: begin
          // Compare and Swap
          if (comparisons == NUM_COMPARISONS - 1) begin
            // Swap Data
            out_data[((N-1)-comparisons)*WIDTH +: WIDTH] <= data_a;
            out_data[comparisons*WIDTH +: WIDTH] <= data_b;

            // Update Comparisons and Data
            comparisons <= comparisons + 1;
            data_a <= data_b;
            if ((comparisons+1) < NUM_COMPARISONS)
              data_b <= in_data[(comparisons+1)*WIDTH-1:0];
            else
              data_b <= '0;

            // Check if Complete
            if (comparisons == NUM_COMPARISONS - 1) begin
              fsm_state <= DONE;
            end
          end
        end
        DONE: begin
          // Done Signal
          done <= 1'b1;
        end
      endcase
    end
  end

endmodule
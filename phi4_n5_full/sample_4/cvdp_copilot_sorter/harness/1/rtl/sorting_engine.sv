module sorting_engine #(
  parameter int N    = 8,  // Number of elements (N > 0)
  parameter int WIDTH = 8   // Bit-width of each element (WIDTH > 0)
)(
  input  logic         clk,
  input  logic         rst,
  input  logic         start,
  input  logic [N*WIDTH-1:0] in_data,
  output logic         done,
  output logic [N*WIDTH-1:0] out_data
);

  // State encoding
  localparam IDLE    = 2'd0;
  localparam SORTING = 2'd1;
  localparam DONE    = 2'd2;

  // State registers and counters
  reg [1:0] state;
  reg [$clog2(N)-1:0] pass_cnt;  // Counts passes (we perform N passes)
  reg [$clog2(N)-1:0] inner_cnt; // Counts comparisons within a pass

  // Internal data array to hold the unsorted (and then sorted) values
  reg [WIDTH-1:0] data [0:N-1];

  // Register to latch the sorted array for output
  reg [N*WIDTH-1:0] sorted_reg;

  // State machine: IDLE, SORTING, DONE
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state       <= IDLE;
      pass_cnt    <= 0;
      inner_cnt   <= 0;
      done        <= 0;
      sorted_reg  <= 0;
      integer i;
      for (i = 0; i < N; i = i + 1) begin
        data[i] <= 0;
      end
    end
    else begin
      case (state)
        IDLE: begin
          // Clear done signal in IDLE
          done <= 0;
          if (start) begin
            // Load the input array from the bus.
            integer i;
            for (i = 0; i < N; i = i + 1) begin
              // Extract each element; element 0 is the least-significant bits.
              data[i] <= in_data[((i+1)*WIDTH)-1 -: WIDTH];
            end
            pass_cnt <= 0;
            inner_cnt <= 0;
            state <= SORTING;
          end
        end

        SORTING: begin
          // Each comparison and potential swap takes one clock cycle.
          if (inner_cnt < (N-1)) begin
            // Compare adjacent elements.
            if (data[inner_cnt] > data[inner_cnt+1]) begin
              logic [WIDTH-1:0] temp;
              temp = data[inner_cnt];
              data[inner_cnt] <= data[inner_cnt+1];
              data[inner_cnt+1] <= temp;
            end
            inner_cnt <= inner_cnt + 1;
          end
          else begin
            // End of one pass: reset inner counter and increment pass counter.
            inner_cnt <= 0;
            pass_cnt <= pass_cnt + 1;
            if (pass_cnt == N) begin
              // After N passes (i.e. N*(N-1) comparisons), sorting is complete.
              state <= DONE;
            end
          end
        end

        DONE: begin
          // Latch the sorted array into sorted_reg.
          integer j;
          sorted_reg <= 0;
          for (j = 0; j < N; j = j + 1) begin
            // Pack each element into the output bus.
            // Element 0 goes to bits [WIDTH-1:0], element 1 to [2*WIDTH-1:WIDTH], etc.
            sorted_reg[((j+1)*WIDTH)-1 -: WIDTH] <= data[j];
          end
          state <= IDLE;
          // Assert done for one clock cycle.
          done <= 1;
        end
      endcase
    end
  end

  // Drive the output port with the sorted array.
  assign out_data = sorted_reg;

endmodule
module parallel_run_length
#(
    parameter DATA_WIDTH = 8,           // Maximum run length per stream (>= 1)
    parameter NUM_STREAMS = 4           // Number of parallel input streams
)
(
    input  wire                        clk,
    input  wire                        reset_n,
    input  wire [NUM_STREAMS-1:0]      data_in,
    input  wire [NUM_STREAMS-1:0]      stream_enable,
    output reg  [NUM_STREAMS-1:0]      data_out,
    output reg  [(NUM_STREAMS*($clog2(DATA_WIDTH)+1))-1:0] run_value,
    output reg  [NUM_STREAMS-1:0]      valid
);

    // Each stream's run_length and run_value_local are stored in arrays.
    // run_length and run_value_local are ($clog2(DATA_WIDTH)+1) bits wide.
    reg [$clog2(DATA_WIDTH):0] run_length    [NUM_STREAMS-1:0];
    reg [$clog2(DATA_WIDTH):0] run_value_local[NUM_STREAMS-1:0];
    // Store the previous data value for each stream.
    reg [NUM_STREAMS-1:0] prev_data;

    //--------------------------------------------------------------------------
    // First always block: Update run_length, run_value_local, and prev_data
    // for each stream independently.
    //--------------------------------------------------------------------------
    genvar i;
    generate
       for(i = 0; i < NUM_STREAMS; i = i + 1) begin : stream_loop_1
          always @(posedge clk or negedge reset_n) begin
              if (!reset_n) begin
                  run_length[i]        <= '0;
                  run_value_local[i]   <= '0;
                  prev_data[i]         <= 1'b0;
              end
              else begin
                  // If the stream is disabled, reset its registers.
                  if (!stream_enable[i]) begin
                      run_length[i]        <= '0;
                      run_value_local[i]   <= '0;
                      prev_data[i]         <= 1'b0;
                  end
                  else begin
                      // When enabled, perform run-length encoding.
                      if (data_in[i] == prev_data[i]) begin
                          // If the run length has reached DATA_WIDTH,
                          // latch the current run length.
                          if (run_length[i] == DATA_WIDTH)
                              run_value_local[i] <= run_length[i];
                          // Increment the run counter if it hasn't reached DATA_WIDTH.
                          if (run_length[i] < DATA_WIDTH)
                              run_length[i] <= run_length[i] + 1;
                          // (The else branch is redundant since run_length == DATA_WIDTH
                          //  is handled above, but is included for clarity.)
                          else
                              run_length[i] <= 1;
                      end
                      else begin
                          // Data changed: latch the previous run length and reset counter.
                          run_value_local[i] <= run_length[i];
                          run_length[i]     <= 1;
                      end
                      // Update the stored previous data.
                      prev_data[i] <= data_in[i];
                  end
              end
          end
       end
    endgenerate

    //--------------------------------------------------------------------------
    // Second always block: Generate valid and data_out signals for each stream.
    // A new run is available when the run length has reached DATA_WIDTH or
    // when the data changes.
    //--------------------------------------------------------------------------
    generate
       for(i = 0; i < NUM_STREAMS; i = i + 1) begin : stream_loop_2
          always @(posedge clk or negedge reset_n) begin
              if (!reset_n) begin
                  valid[i]    <= 1'b0;
                  data_out[i] <= 1'b0;
              end
              else begin
                  if (!stream_enable[i]) begin
                      valid[i]    <= 1'b0;
                      data_out[i] <= 1'b0;
                  end
                  else begin
                      // Assert valid when a run terminates.
                      if ((run_length[i] == DATA_WIDTH) || (data_in[i] != prev_data[i])) begin
                          valid[i]    <= 1'b1;
                          data_out[i] <= prev_data[i];
                      end
                      else begin
                          valid[i]    <= 1'b0;
                          data_out[i] <= 1'b0;
                      end
                  end
              end
          end
       end
    endgenerate

    //--------------------------------------------------------------------------
    // Concatenate each stream's run_value_local into the output bus run_value.
    // The bus is organized as: { run_value_local[NUM_STREAMS-1], ..., run_value_local[0] }.
    //--------------------------------------------------------------------------
    integer k;
    always @(*) begin
        for (k = 0; k < NUM_STREAMS; k = k + 1) begin
            run_value[(k+1)*($clog2(DATA_WIDTH)+1)-1 -: ($clog2(DATA_WIDTH)+1)] = run_value_local[k];
        end
    end

endmodule
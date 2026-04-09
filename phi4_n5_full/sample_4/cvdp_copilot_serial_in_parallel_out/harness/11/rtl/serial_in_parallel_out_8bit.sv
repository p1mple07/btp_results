modules.
//----------------------------------------------------------

module serial_in_parallel_out_8bit #(
  parameter WIDTH         = 64,
  parameter SHIFT_DIRECTION = 1
)
(
  input         clk,
  input         rst,
  input         sin,
  input         shift_en,
  output reg    done,
  output reg [WIDTH-1:0] parallel_out
);

  reg [31:0] shift_count;

  always @(posedge clk) begin
    if (rst) begin
      parallel_out <= '0;
      shift_count  <= '0;
      done         <= 1'b0;
    end
    else if (shift_en) begin
      if (SHIFT_DIRECTION == 1) begin
        parallel_out <= {parallel_out[WIDTH-2:0], sin};
      end
      else begin
        parallel_out <= {sin, parallel_out[WIDTH-1:0]};
      end

      shift_count <= shift_count + 1;
      if (shift_count == WIDTH-1) begin
        done         <= 1'b1;
        shift_count  <= '0;
        parallel_out <= '0;
      end
      else begin
        done <= 1'b0;
      end
    end
  end

endmodule


module onebit_ecc #(
  parameter DATA_WIDTH  = 16,
  parameter CODE_WIDTH  = DATA_WIDTH + $clog2(DATA_WIDTH+1)
)
(
  input  [DATA_WIDTH-1:0] data_in,
  input  [CODE_WIDTH-1:0] received,
  output reg [DATA_WIDTH-1:0] data_out,
  output reg [CODE_WIDTH-1:0] encoded,
  output reg              error_detected,
  output reg              error_corrected
);

  // Function to check if a number is a power of two.
  function automatic bit is_power_of_two(input int x);
    begin
      is_power_of_two = ((x & (x-1)) == 0) && (x != 0);
    end
  endfunction

  integer i, k;
  integer syndrome;
  integer num_parity;
  reg [CODE_WIDTH-1:0] temp_encoded;
  reg [CODE_WIDTH-1:0] corrected_received;
  reg [DATA_WIDTH-1:0] temp_data;

  always @(*) begin
    // Initialize temporary variables
    temp_encoded      = '0;
    syndrome          = 0;
    num_parity        = $clog2(DATA_WIDTH+1);
    corrected_received= received;
    temp_data         = '0;
    k                 = 0;

    // Map data_in bits to non-parity positions in the encoded word.
    for (i = 0; i < CODE_WIDTH; i = i + 1) begin
      if (is_power_of_two(i+1)) begin
        temp_encoded[i] = 1'b0;  // Parity bits will be computed later.
      end
      else begin
        temp_encoded[i] = data_in[k];
        k = k + 1;
      end
    end

    // Compute parity bits for each parity position.
    for (i = 0; i < num_parity; i = i + 1) begin
      integer parity;
      parity = 1'b0;
      for (k = 0; k < CODE_WIDTH; k = k + 1) begin
        // Check if bit (i) of (k+1) is set.
        if ((((k+1) >> i) & 1) == 1) begin
          parity = parity ^ temp_encoded[k];
        end
      end
      temp_encoded[(1 << i) - 1] = parity;
    end

    encoded = temp_encoded;

    // Syndrome computation from the received encoded word.
    for (i = 0; i < num_parity; i = i + 1) begin
      integer parity;
      parity = 1'b0;
      for (k = 0; k < CODE_WIDTH; k = k + 1) begin
        if ((((k+1) >> i) & 1) == 1) begin
          parity = parity ^ received[k];
        end
      end
      if (parity != received[(1 << i) - 1])
        syndrome = syndrome + (1 << i);
    end

    error_detected = (syndrome != 0);

    if (syndrome != 0) begin
      if ($countones(syndrome) == 1) begin
        error_corrected = 1;
        corrected_received = received ^ (1 << syndrome);
      end
      else begin
        error_corrected = 0;
        corrected_received = received;
      end
    end
    else begin
      error_corrected = 0;
      corrected_received = received;
    end

    // Extract the original data bits from the corrected received word.
    k = 0;
    for (i = 0; i < CODE_WIDTH; i = i + 1) begin
      if (!is_power_of_two(i+1)) begin
        temp_data[k] = corrected_received[i];
        k = k + 1;
      end
    end
    data_out = temp_data;
  end

endmodule


module sipo_top #(
  parameter DATA_WIDTH     = 16,
  parameter SHIFT_DIRECTION = 1,
  parameter CODE_WIDTH     = DATA_WIDTH + $clog2(DATA_WIDTH+1)
)
(
  input         clk,
  input         rst,
  input         serial_in,
  input         shift_en,
  input  [CODE_WIDTH-1:0] received,
  output        done,
  output [DATA_WIDTH-1:0] data_out,
  output [CODE_WIDTH-1:0] encoded,
  output        error_detected,
  output        error_corrected
);

  wire [DATA_WIDTH-1:0] sipo_data;
  wire                  sipo_done;

  // Instantiate the Serial in Parallel Out module.
  serial_in_parallel_out_8bit #(
    .WIDTH(DATA_WIDTH),
    .SHIFT_DIRECTION(SHIFT_DIRECTION)
  ) sipo_inst (
    .clk(clk),
    .rst(rst),
    .sin(serial_in),
    .shift_en(shift_en),
    .parallel_out(sipo_data),
    .done(sipo_done)
  );

  // Instantiate the One Bit ECC module.
  onebit_ecc #(
    .DATA_WIDTH(DATA_WIDTH),
    .CODE_WIDTH(CODE_WIDTH)
  ) ecc_inst (
    .data_in(sipo_data),
    .received(received),
    .data_out(data_out),
    .encoded(encoded),
    .error_detected(error_detected),
    .error_corrected(error_corrected)
  );

endmodule
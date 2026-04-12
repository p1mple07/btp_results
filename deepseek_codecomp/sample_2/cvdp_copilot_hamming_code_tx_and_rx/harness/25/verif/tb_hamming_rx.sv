module tb_hamming_rx;

  parameter DATA_WIDTH   = 6;
  parameter PARITY_BIT   = 4;
  parameter ENCODED_DATA = PARITY_BIT + DATA_WIDTH + 1;
  parameter ENCODED_DATA_BIT = $clog2(ENCODED_DATA);
  
  parameter MAX_RANDOM_CHECK = 16;

  reg [DATA_WIDTH-1:0] data_in, data_out_from_dut, bit_value;
  reg [ENCODED_DATA-1:0] data_out;       
  reg [ENCODED_DATA-1:0] modified_data;
  reg [31:0] ok_count, not_ok_count;

  hamming_rx 
  #(
    .DATA_WIDTH(DATA_WIDTH),
    .PARITY_BIT(PARITY_BIT),
    .ENCODED_DATA(ENCODED_DATA),
    .ENCODED_DATA_BIT(ENCODED_DATA_BIT)
  )
  latest_dut_rx (
    .data_in(modified_data), 
    .data_out(data_out_from_dut)
  );

  integer i, j;

  task automatic check_data(
    input [DATA_WIDTH-1:0] expected_data,
    input [DATA_WIDTH-1:0] received_data
    
  );
    begin
      if (received_data == expected_data) begin
        ok_count = ok_count + 1;
        $display("FROM TESTBENCH: design ok %d ", ok_count);
      end else begin
        not_ok_count = not_ok_count + 1;
        $display("FROM TESTBENCH: design not ok %d", not_ok_count);
      end
    end
  endtask

  task automatic send_data(
    input [ENCODED_DATA-1:0] original_data,
    output reg [ENCODED_DATA-1:0] modified_data_out,
    output reg [DATA_WIDTH-1:0] bit_pos
  );
    begin
      modified_data_out = original_data;
      bit_pos = $urandom_range(1, ENCODED_DATA-1);
      modified_data_out[bit_pos] = ~modified_data_out[bit_pos];
    end
  endtask

  function automatic [ENCODED_DATA-1:0] golden_hamming_tx(
    input [DATA_WIDTH-1:0] input_data
  );
    reg [PARITY_BIT-1:0] parity;
    reg [ENCODED_DATA-1:0] temp_data;
    integer i, j, count;
    reg [ENCODED_DATA_BIT:0] pos;
    begin
      temp_data = {ENCODED_DATA{1'b0}};
      parity = {PARITY_BIT{1'b0}};
      count = 0;

      for (pos = 1; pos < ENCODED_DATA; pos = pos + 1) begin
        if (count < DATA_WIDTH) begin
          if ((pos & (pos - 1)) != 0) begin
            temp_data[pos] = input_data[count];
            count = count + 1;
          end
        end
      end

      for (j = 0; j < PARITY_BIT; j = j + 1) begin
        for (i = 1; i <= ENCODED_DATA - 1; i = i + 1) begin
          if ((i & (1 << j)) != 0) begin
            parity[j] = parity[j] ^ temp_data[i];
          end
        end
      end

      for (j = 0; j < PARITY_BIT; j = j + 1) begin
        temp_data[(1 << j)] = parity[j];
      end

      golden_hamming_tx = temp_data;
    end
  endfunction

  task automatic corner_check();
    for (i = 0; i < 16; i = i + 1) begin
      data_in = i;
      #10;

      $display("FROM TESTBENCH: Original data: %b", data_in);

      data_out = golden_hamming_tx(data_in);
      $display("FROM TRANSMIT DESIGN: Transmitted data: %b", data_out);

      send_data(data_out, modified_data, bit_value);
      $display("FROM TESTBENCH: Modified data: %b", modified_data);

      #10;

      check_data(data_in, data_out_from_dut);

      $display("-----------------------------------");
    end
  endtask

  task automatic random_check();
    for (j = 0; j < MAX_RANDOM_CHECK; j = j + 1) begin
      data_in = $random;
      #10;

      $display("FROM TESTBENCH: Original data: %b", data_in);

      data_out = golden_hamming_tx(data_in);
      $display("FROM TRANSMIT DESIGN: Transmitted data: %b", data_out);

      send_data(data_out, modified_data, bit_value);
      $display("FROM TESTBENCH: Modified data: %b", modified_data);

      #10;

      check_data(data_in, data_out_from_dut);

      $display("-----------------------------------");
    end
  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);

    ok_count = 0;
    not_ok_count = 0;

    $display("Starting Corner Check\n");
    corner_check();

    $display("Starting Random Check\n");
    random_check();

    $display("Total test cases: %0d correct: %0d incorrect: %0d", i + j, ok_count, not_ok_count);
    $finish;
  end

endmodule

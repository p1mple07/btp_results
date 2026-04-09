module data_bus_controller #(
  parameter AFINITY = 0
  )(
  input         clk      ,
  input         rst_n    ,

  output        m0_read  ,
  input         m0_valid ,
  input [31:0]  m0_data  ,

  output        m1_read  ,
  input         m1_valid ,
  input [31:0]  m1_data  ,

  input         s_read   ,
  output        s_valid  ,
  output [31:0] s_data 
);

  // FIFO for master data
  FIFO [31:0] master_data FIFO_size=2;

  // Counter for master priority
  integer master_counter = 0;

  // FIFO for slave read
  FIFO [31:0] slave_data FIFO_size=1;

  always begin
    // Enqueue master data
    if (m0_valid) master_data[0] = m0_data;
    if (m1_valid) master_data[1] = m1_data;

    // Dequeue data based on priority
    if (master_counter == 0) begin
      slave_data = master_data[0];
      master_counter = 1;
    elsif (master_counter == 1) begin
      slave_data = master_data[1];
      master_counter = 0;
    end

    // Slave read
    s_read = slave_data;

    // Slave valid
    s_valid = 1;
  end

  // Reset initialization
  initial begin
    master_counter = 0;
    // Initialize FIFO
    master_data[0] = 0;
    master_data[1] = 0;
  end

endmodule
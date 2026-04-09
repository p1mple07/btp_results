module cache_controller_tb;

  logic clk, reset;
  logic [4:0] address;
  logic [31:0] write_data, read;
  logic read, write;
  logic [31:0] read_data, mem_read_data;
  logic hit, miss, mem_ready;
  logic [5:0] mem_address;
  logic [31:0] mem_write_data, mem_write_addr;
  logic [31:0] mem_read_data;
  logic mem_ready;

  cache_controller uut (
    .clk           (clk),
    .reset         (reset),
    .address       (address),
    .write_data    (write_data),
    .read          (read),
    .read_data     (read_data),
    .hit           (hit),
    .miss          (miss),
    .mem_write     (mem_write),
    .mem_address   (mem_address),
    .mem_write_data(mem_write_data),
    .mem_read_data (mem_read_data),
    .mem_ready     (mem_ready)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    reset = 1;
    address = 0;
    write_data = 0;
    read = 0;
    write = 0;
    mem_ready = 0;

    #10 reset = 0;

    // Test case 1: Read miss
    address = 5'h01;
    read = 1;
    mem_read_data = 32'hDEADBEEF;
    mem_ready = 1;
    #10 read = 0;
    #20;

    // Test case 2: Write hit
    address = 5'h01;
    write = 1;
    write_data = 32'hCAFEBABE;
    #10 write = 0;
    #20;

    // Test case 3: Read hit
    address = 5'h01;
    read = 1;
    #10 read = 0;
    #20;

    #100 $finish;
  end

endmodule

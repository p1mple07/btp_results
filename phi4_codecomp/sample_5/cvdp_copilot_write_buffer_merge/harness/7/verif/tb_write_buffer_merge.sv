`timescale 1ns/1ps
module tb_write_buffer_merge ();
    
// Uncomment only one define at a time
// Uncomment these to test different configurations; if none are defined, the default will be used.
// `define TEST_8_16_32
// `define TEST_16_12_4
// `define TEST_64_20_16
// `define TEST_64_20_1 // Passthrough Case

// Uncomment this define to provide continuous write enable input
// `define CONTINUOUS_WRITE_ENABLE_INPUT

// -------------------------------------------------------------------------
// Parameter Declarations
// -------------------------------------------------------------------------
// INPUT_DATA_WIDTH  - Bit width of the input data
// INPUT_ADDR_WIDTH  - Bit width of the input address
// BUFFER_DEPTH      - Depth of the write buffer
// OUTPUT_DATA_WIDTH - Bit width of the output data
// OUTPUT_ADDR_WIDTH - Bit width of the output address
// -------------------------------------------------------------------------
`ifdef TEST_8_16_32
    parameter INPUT_DATA_WIDTH  = 8;
    parameter INPUT_ADDR_WIDTH  = 16;
    parameter BUFFER_DEPTH      = 32;
`elsif TEST_16_12_4
    parameter INPUT_DATA_WIDTH  = 16;
    parameter INPUT_ADDR_WIDTH  = 12;
    parameter BUFFER_DEPTH      = 4;
`elsif TEST_64_20_16
    parameter INPUT_DATA_WIDTH  = 64;
    parameter INPUT_ADDR_WIDTH  = 20;
    parameter BUFFER_DEPTH      = 16;
`elsif TEST_64_20_16
    parameter INPUT_DATA_WIDTH  = 64;
    parameter INPUT_ADDR_WIDTH  = 20;
    parameter BUFFER_DEPTH      = 1;
`else
    parameter INPUT_DATA_WIDTH  = 32;
    parameter INPUT_ADDR_WIDTH  = 16;
    parameter BUFFER_DEPTH      = 8;
`endif

parameter OUTPUT_DATA_WIDTH = INPUT_DATA_WIDTH * BUFFER_DEPTH;
parameter OUTPUT_ADDR_WIDTH = INPUT_ADDR_WIDTH - $clog2(BUFFER_DEPTH);

// -------------------------------------------------------------------------
// Signal Declarations
// -------------------------------------------------------------------------
logic                         clk                     = 0 ; // Clock signal
logic                         srst                        ; // Reset signal (active high, synchronous)
logic                         wr_en_in                    ; // Write enable input
logic [ INPUT_ADDR_WIDTH-1:0] wr_addr_in                  ; // Write address input
logic [ INPUT_DATA_WIDTH-1:0] wr_data_in                  ; // Write data input
logic                         wr_en_out                   ; // Write enable output
logic [OUTPUT_ADDR_WIDTH-1:0] wr_addr_out                 ; // Write address output
logic [OUTPUT_DATA_WIDTH-1:0] wr_data_out                 ; // Write data output
logic                         start_test              = 0 ; // Signal to start the test
logic                         start_test_reg              ; // Registered version of start_test
logic [OUTPUT_ADDR_WIDTH-1:0] addr_q              [$]     ; // Queue for storing addresses
logic [ INPUT_DATA_WIDTH-1:0] data_q              [$]     ; // Queue for storing data
logic                         data_matched                ; // Flag indicating data match
logic                         addr_matched                ; // Flag indicating address match
logic [                 31:0] num_inputs                  ; // Number of inputs
logic [                 31:0] num_inputs_reg              ; // Number of inputs register
logic [                 31:0] num_wr_en_out           = 0 ; // Number of output write enables observed
logic [                 31:0] num_outputs_expected        ; // Expected number of output writes
logic [                 31:0] num_inputs_expected         ; // Expected number of input writes
logic [OUTPUT_DATA_WIDTH-1:0] expected_data           = '0; // Expected data value
logic                         write_req                   ;
int                           temp                        ; // Temporary variable for pop operations

// -------------------------------------------------------------------------
// Module Instantiation
// -------------------------------------------------------------------------
write_buffer_merge #(
    .INPUT_DATA_WIDTH (INPUT_DATA_WIDTH),
    .INPUT_ADDR_WIDTH (INPUT_ADDR_WIDTH),
    .BUFFER_DEPTH     (BUFFER_DEPTH),
    .OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH),
    .OUTPUT_ADDR_WIDTH(OUTPUT_ADDR_WIDTH)
) write_buffer_merge_inst (
    .clk        (clk        ),
    .srst       (srst       ),
    .wr_en_in   (wr_en_in   ),
    .wr_addr_in (wr_addr_in ),
    .wr_data_in (wr_data_in ),
    .wr_en_out  (wr_en_out  ),
    .wr_addr_out(wr_addr_out),
    .wr_data_out(wr_data_out)
);

// Clock generation
always
    #1 clk = ~clk;

initial
begin
    wr_en_in = 0;
    wr_addr_in = 0;
    wr_data_in = 0;
    num_outputs_expected = $urandom_range(1, 16);
    num_inputs_expected = num_outputs_expected * BUFFER_DEPTH;
    start_test = 0;
    data_matched = 0;

    srst = 1'b1;
    repeat(20) @(posedge clk);
    srst = 1'b0;
    repeat(20) @(posedge clk);

    start_test = 1'b1;

    while (1) begin
        verify_output();
        @(posedge clk);
        if (num_inputs == num_inputs_expected)
            start_test = 0;
        if (num_wr_en_out == num_outputs_expected)
            break;
    end

    if (data_matched && addr_matched)
        $display("Test Passed!");
    else
        $display("Test Failed!");

    @(posedge clk);
    $finish;
end

always_ff @(posedge clk)
    if (srst)
        num_inputs <= '0;
    else if (start_test_reg && write_req)
        num_inputs <= num_inputs + 1;

always_ff @(posedge clk)
    num_inputs_reg <= num_inputs;

always_ff @(posedge clk)
    start_test_reg <= start_test;

always_ff @(posedge clk)
`ifdef CONTINUOUS_WRITE_ENABLE_INPUT
    write_req <= 1'b1;
`else 
    write_req <= $urandom_range(0,1);
`endif

always_ff @(posedge clk)
    if (srst)
        wr_en_in <= '0;
    else if (start_test_reg && (num_inputs != num_inputs_expected))
        wr_en_in <= write_req;
    else
        wr_en_in <= '0;

always_ff @(posedge clk)
    if (srst)
        wr_addr_in <= '0;
    else if (start_test_reg && (num_inputs != num_inputs_expected) && write_req)
        wr_addr_in <= ((num_inputs % BUFFER_DEPTH) == 0) ? BUFFER_DEPTH*($urandom_range(0,(1<<INPUT_ADDR_WIDTH)-1)/BUFFER_DEPTH) : wr_addr_in + 1;

always_ff @(posedge clk)
    if (srst)
        wr_data_in <= '0;
    else if (start_test_reg && (num_inputs != num_inputs_expected) && write_req)
        wr_data_in <= $urandom_range(0,(1<<INPUT_DATA_WIDTH)-1);

always
begin
    if (wr_en_in) begin
        if ((num_inputs_reg % BUFFER_DEPTH) == 0) begin
            addr_q.push_back(wr_addr_in[INPUT_ADDR_WIDTH-1:$clog2(BUFFER_DEPTH)]);
        end
        data_q.push_back(wr_data_in);
    end
    @(posedge clk);
end

task verify_output();
    int idx;

    if (wr_en_out) begin
        for (idx = 0; idx < BUFFER_DEPTH; idx++) begin
            expected_data = expected_data | (data_q[idx] << (idx * INPUT_DATA_WIDTH));
        end

        if (wr_addr_out == addr_q[0]) begin
            $display("INFO: Match: Addr = %h", wr_addr_out);
            addr_matched = 1;
        end else begin
            $display("ERROR: Mismatch: Addr = %h, Expected Addr = %h", wr_addr_out, addr_q[0]);
            addr_matched = 0;
        end

        if (wr_data_out == expected_data) begin
            $display("INFO: Match: Data = %h", wr_data_out);
            data_matched = 1;
        end else begin
            $display("ERROR: Mismatch: Data = %h, Expected Data = %h", wr_data_out, expected_data);
            data_matched = 0;
        end

        temp = addr_q.pop_front();
        for (idx = 0; idx < BUFFER_DEPTH; idx++) begin
            temp = data_q.pop_front();
        end
        expected_data = 0;
        num_wr_en_out++;
    end
endtask

initial
begin
    $dumpfile("test.vcd");
    $dumpvars(0, tb_write_buffer_merge);
end

endmodule
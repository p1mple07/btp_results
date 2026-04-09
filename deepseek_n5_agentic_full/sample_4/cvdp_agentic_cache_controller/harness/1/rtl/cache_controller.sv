RTL/cache_controller.sv

include "verilog.h"

module cache_controller (
    // Pins going out
    reg         [31:0] address       ;  // Address to be sent to CPU
    reg         [31:0] write_data    ;  // Word to be written to cache
    reg         read          ;      // Bit indicating if data is available
    reg         write         ;      // Bit indicating if write is pending
    wire [31:0] read_data     ;     // Data received from CPU
    wire        hit           ;     // Bit indicating if hit occurred
    wire        miss          ;     // Bit indicating if miss occurred
    wire        mem_write     ;     // Bit indicating if memory was written to
    wire [31:0] mem_address   ;    // Address to be sent to memory
    wire [31:0] mem_write_data;
    reg  [31:0] mem_read_data ;
    reg         mem_ready     ;     // Bit indicating if ready to send data

    // Pins coming in
    input      reg clock           ;  // Clock signal
    input      reg reset         ;  // Reset signal
    input      wire  [31:0] address       ;  // Address from CPU
    input      wire  [31:0] write_data    ;  // Word from CPU
    input      reg   read          ;      // Availability bit from CPU
    input      reg   write         ;      // Pending write bit from CPU
);

// State machine variables
reg  [31:0] tag          ;      // Tag part of the address
reg  [31:0] valid         ;     // Validity bit for each cache line
reg  [31:0] dirty        ;     // Dirty bit for each cache line
wire [31:0] next_valid    ;     // Next validity after modification
wire [31:0] next_dirty    ;     // Next dirtiness after modification

// Internal signals
wire [31:0] data_in       ;     // Data from memory
wire [31:0] data_out      ;     // Data from cache
wire [31:0] address_out   ;     // Address from cache
wire [31:0] valid_in      ;     // Validity from memory
wire [31:0] valid_out     ;     // Validity from cache
wire [31:0] dirty_in      ;    // Dirtiness from memory
wire [31:0] dirty_out     ;    // Dirtiness from cache
wire [31:0] mem_address_out;    // Address to memory
wire [31:0] mem_write_in    ;    // Memory write request
wire [31:0] mem_write_data_in; // Memory write data
wire [31:0] mem_read_data_out;// Cache read data
wire [31:0] mem_write_out;     // Cache write data
wire [31:0] mem_valid_out;     // Cache validity
wire [31:0] mem_dirty_out;     // Cache dirtiness

// Local variables
localparam mem_size = 8;      // Number of cache lines
localparam cache_width = 32;  // Width of each cache line

// State machine
state machine;
    // States:
    // 0: Ready to process instruction
    // 1: Waiting for address
    // 2: Comparing tag
    // 3: Handling miss
    // 4: Handling hit
    // 5: Waiting for write data
    // 6: Validating write data
    // 7: Writing to memory
    // 8: Validating memory write
    // 9: Updating cache
    // 10: Waiting for next instruction

    always_ff+ (clock, reset, machine) {
        case machine
            0: machine = 1; #10;
            1: address_out = address; #10;
                        if (hit) machine = 4;
                        else    machine = 3;
            2: 
                        if (hit) machine = 4;
                        else    machine = 3;
            3: 
                        if (miss) begin
                            // Fetch from memory
                            data_in = mem_read_data;
                            valid_in = mem_valid;
                            dirty_in = mem_dirty;
                            
                            // Update cache
                            data_out = data_in;
                            valid_out = valid_in;
                            dirty_out = dirty_in;
                            
                            address_out = mem_address;
                            mem_address_out = mem_address;
                            
                            #10;
                            if (hit) machine = 4;
                            else    machine = 2;
                        end
                        else begin
                            // Send data to CPU
                            read_data = data_out;
                            hit = valid_out;
                            miss = !valid_out;
                            mem_write_in = 1;
                            mem_write_data_out = data_out;
                            
                            #10;
                            machine = 2;
                        end
            4: 
                        if (write) begin
                            // Write through policy
                            data_out = data_in;
                            valid_out = 1;
                            dirty_out = 1;
                            
                            // Fetch current line status
                            mem_write_in = 1;
                            
                            #10;
                            if (!valid_in) begin
                                // Invalidate cache line
                                valid_out = 0;
                                dirty_out = 1;
                            end
                            
                            #10;
                            machine = 6;
                        end
                        else    machine = 5;
            5: 
                        if (write_data) begin
                            // Request write to memory
                            mem_write_in = 1;
                            mem_write_data_in = write_data;
                            
                            #10;
                            if (!valid_in) begin
                                // Invalidate cache line
                                valid_out = 0;
                                dirty_out = 1;
                            end
                            
                            #10;
                            machine = 7;
                        end
                        else    machine = 5;
            6: valid_out = 0;
            7: mem_write_in = 1;
            8: mem_write_data_out = write_data;
            9: invalid_in = 1;
            default: machine = 2;
        endcase
    }

    // Initial state
    initial begin
        machine = 0;
        $finish;
    end
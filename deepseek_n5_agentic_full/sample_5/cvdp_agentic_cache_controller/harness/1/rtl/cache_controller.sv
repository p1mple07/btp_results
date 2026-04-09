// File: rtl/cache_controller.sv

module cache_controller (
    parameter size_t Address_T = 5,
    parameter size_t Data_T = 5,
    parameter size_t Validity_T = 1,
    input clock,
    input reset,
    input [31:0] address,
    input [31:Data_T-1] write_data,
    output [31:0] read_data,
    output hit,
    output mem_write,
    wire [31:0] mem_address,
    wire [31:0] mem_write_data,
    wire [31:0] mem_read_data,
    wire [size_t Address_T:0] tag Reg,
    wire [size_t Address_T:0] valid Reg,
    register [
        size_t Address_T:0
    ] tag_cache,
    register [
        size_t Address_T:0
    ] valid_cache,

    // State Machine Control Signals
    input [Address_T+1:0] st_state,
    input [Address_T+1:0] st_next
)

// Tags
    always @* begin
        // Load tags from CPU
        tag_reg = address[Size_T:0];
        valid_reg = 1;
    end

// Validity Register
    always @* begin
        // Load valid information from tag cache
        tag_valid = valid_cache[tag_reg];
    end

// Memory Interface
    // Read Path
    // Read Hit
    case (st_state)
        0: // Initial State
            // Initialize all cache lines to invalid
            foreach(i in 0..Cache_Size-1) begin
                tag_cache[i] = (i == 0) ? 0 : (Tag_T+1);
                valid_cache[i] = 0;
            end
            st_next = Read_Hit;
            #Initial_Cache_Setup;
        1: Read_Hit
            // Read Hit
            read_data = write_data;
            hit = 1;
            st_next = Read_Max;
        2: Read_Max
            // Read Max
            read_data = 0;
            hit = 0;
            st_next = Read_Max;
        3: Read_Max
            // Read Max
            st_next = Read_Max;
    endcase

// Write Path
    // Write Hit
    case (st_state)
        0: // Initial State
            st_next = Write_Hit;
            #Initial_Cache_Setup;
        1: Write_Hit
            // Write Hit
            mem_write = 1;
            mem_write_data = write_data;
            hit = 1;
            st_next = Write_Max;
        2: Write_Max
            // Write Max
            hit = 0;
            st_next = Write_Max;
        3: Write_Max
            // Write Max
            st_next = Write_Max;
    endcase

    // Read Miss
    default:
        // Fetch from memory
        #100
        mem_address = address;
        mem_write = 1;
        mem_write_data = write_data;
        #10
        valid_cache[mem_address[T-1:0]] = 1;
        #10
        tag_cache[mem_address[T-1:0]] = mem_address[T-1:0];
        #10
        hit = 1;
        read_data = mem_read_data;
        st_next = Read_Max;
    endcase

    // Write Miss
    default:
        // Fetch from memory
        #100
        mem_address = address;
        mem_write = 1;
        mem_write_data = write_data;
        #10
        valid_cache[mem_address[T-1:0]] = 1;
        #10
        tag_cache[mem_address[T-1:0]] = mem_address[T-1:0];
        #10
        hit = 0;
        st_next = Write_Max;
    endcase

    // State Machine Setup
    initial begin
        // Set up initial state
        $while true
            #100;
        end
    end
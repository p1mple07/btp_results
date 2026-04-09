module direct_map_cache (
    // Parameters
    parameter CACHE_SIZE   = 256; // Number of cache lines
    parameter DATA_WIDTH   = 16;  // Width of data
    parameter TAG_WIDTH    = 5;   // Width of the tag
    parameter OFFSET_WIDTH = 3;   // Width of the offset
    
    // Internal parameters
    localparameter INDEX_WIDTH = $clog2(CACHE_SIZE); // Width of the index
    localparameter OFFSET_WIDTH = 3;               // Width of the offset
    
    // Input signals
    reg enable;                                       // Enable control
    reg [INDEX_WIDTH-1:0] index;                       // Index (cache line address)
    reg [OFFSET_WIDTH-1:0] offset;                     // Offset (address within the line)
    reg comp;                                           // Tag comparison control
    reg write;                                          // Write control
    reg [TAG_WIDTH-1:0] tag_in;                        // Tag input
    reg [DATA_WIDTH-1:0] data_in;                      // Data input
    reg valid_in;                                     // Validity input
    // Output signals
    wire hit;                                           // Hit flag
    wire dirty;                                        // Dirty flag
    wire [TAG_WIDTH-1:0] tag_out;                       // Output tag
    wire [DATA_WIDTH-1:0] data_out;                     // Output data
    wire valid;                                         // Validity output
    wire error;                                          // Error flag
    
    // Internal storage
    reg [INDEX_WIDTH-1:0] stored_index;                 // Cached index
    reg [OFFSET_WIDTH-1:0] stored_offset;                 // Cached offset
    reg [TAG_WIDTH-1:0]    stored_tag;                    // Cached tag
    reg [DATA_WIDTH-1:0]   stored_data;                   // Cached data
    
    // Instantiate submodules
    direct_map_cache_stg tag_storage (
        tag_in = tag_in,
        tag_out = tag_out,
        valid_in = valid_in,
        valid_out = valid
    );
    
    direct_map_cache_stg data_storage (
        data_in = data_in,
        data_out = data_out,
        valid_in = valid_in,
        valid_out = valid
    );
    
    direct_map_cache_stg valid_storage (
        valid_in = valid_in,
        valid_out = valid
    );
    
    direct_map_cache_stg dirty_storage (
        valid_in = valid_in,
        dirty_in = dirty,
        dirty_out = dirty
    );
    

    // Top level tasks
    task reset() 
    // Perform initializations
    begin
        // Reset the entire system
        enable = 0;
        
        // 1) Initialization phase
        // 1a) Initialize all the storage units
        tag_storage.init();
        data_storage.init();
        valid_storage.init();
        dirty_storage.init();
        
        // 2) Initial debugging operations
        // 2a) Write some data to the cache
        write_comp1();
        // 2b) Read some data from the cache
        read_comp1();
        // 2c) Ensure all assertions pass
        
        // 3) Finalize the simulation
        $finish;
    end
    
    // Tasks for testbench control
    task write_comp0();                              // Write operation with compare=0
    task write_comp1();                              // Write operation with compare=1
    task read_comp1();                               // Read operation with compare=1
    task read_comp0();                               // Read operation with compare=0
    task miss_test();                                // Miss test
    task force_offset_error();                      // Force offset LSB=1 for error detection
    
    // Definitions of helper tasks
    // [Other tasks follow similar pattern]
];

// Submodule definitions
localmodule direct_map_cache_stg
    // Implementation of tag storage unit
    tag_storage (
        input  [TAG_WIDTH-1:0] tag_in;
        output [TAG_WIDTH-1:0] tag_out;
        input  [data valid]    valid_in;
        output [data valid]    valid_out;
    ) 
    // Use standard FIFO implementation
    inherit(tag_storage芯片);
endmodule
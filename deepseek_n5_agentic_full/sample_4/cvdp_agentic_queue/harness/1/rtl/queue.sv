// Parameters
parameter DEPTH = 100;
parameter DBITS  = 32;
parameter ALMOST_EMPTY_THRESHOLD = 5;
parameter ALMOST_FULL_THRESHOLD = 95;

module queue(clk_i,
            rst_ni,
            cler_i,
            we_i,
            d_i,
            re_i,
            q_o);

    // State variables
    integer queue_wadr;  // Queue pointer
    integer queue_size;  // Number of valid data entries

    // Event queues for async events
    event rst_ni_event;
    event cler_i_event;
    event clk_i_event;

    // Internal initialization
    initial begin
        // Initialize queue pointers and state
        $init();
    end

    always_comb begin
        // Handle asynchronous events
        if ($event[rst_ni_event]) 
            queue_wadr = 0; // Reset queue pointer
        else if ($event[cler_i_event])
            queue_wadr = 0; // Reset queue pointer
        else if ($event[clk_i_event]) begin
            // Process events on positive edge
            // [Processing logic]
        endif
    end

    // Main logic
    always @*begin #+1
        if (we_i && !re_i) begin
            // Write-only mode
            if (queue_wadr < DEPTH - 1) begin
                queue_data[queue_wadr] = d_i;
                queue_wadr++;
            else
                // Queue is full
                $error("Queue full");
            endif
        elif (re_i && !we_i) begin
            // Read-only mode
            if (queue_wadr > 0) begin
                q_o = queue_data[queue_wadr - 1];
                queue_wadr--;
            else
                // Queue is empty
                q_o = {d_i}; // Fallback to input data?
            endif
        else begin
            // Simultaneous read/write mode
            if (queue_wadr == 0) begin
                // First-word-fall-through behavior
                q_o = d_i;
                queue_wadr = 0;
            else
                // Normal processing
                temp_data = queue_data[queue_wadr - 1];
                q_o = temp_data;
                queue_wadr--;
                queue_data[queue_wadr] = d_i;
            endif
        endif
    always @*end

    // Update status signals
    always begin
        if (queue_wadr == 0)
            empty_o = 1;
        else if (queue_wadr >= DEPTH)
            full_o = 1;
        else
            empty_o = 0;

        if (queue_wadr <= ALMOST_EMPTY_THRESHOLD)
            almost_empty_o = 1;
        else if (queue_wadr >= ALMOST_FULL_THRESHOLD)
            almost_full_o = 1;
        else
            almost_empty_o = 0;
            almost_full_o = 0;
    end

    // Module ports
    port (
        input  clock_i,
        input  rst_ni,
        input  cler_i,
        input  we_i,
        input  d_i=DBITS{1#(DBITS-1)},
        output re_i,
        output q_o=DBITS{1#(DBITS-1)},
        output empty_o,
        output full_o,
        output almost_empty_o,
        output almost_full_o
    );
    
    // Register array
    reg [DBITS-1:0] queue_data[DEPTH-1:0];
    reg queue_wadr;

    // Event handling
    wire ($rst_ni_event(rst_ni)) 
        ($cler_i_event(cler_i)) 
        ($clk_i_event(clk_i));

    // Initial block
    initial begin
        // Initialize queue
        $init_queue();
    end

    initial procedure $init_queue() begin
        queue_wadr = 0;
        // Initialize queue_data
        for (integer i=0; i<DEPTH; i++) begin
            queue_data[i] = 0;
        end
    end
// Additional inputs and outputs for timeout mechanism
input   [31:0] timeout_threshold;
output  reg timeout_flag;

// Timeout counters
reg [31:0] read_timeout_counter = 0;
reg [31:0] write_timeout_counter = 0;

// Timeout threshold constant
parameter TIMEOUT_THRESHOLD = timeout_threshold;

// Timeout flag initialization
initial begin
    timeout_flag = 0;
end

// Read transaction timeout logic
always @(posedge clk_i or negedge rst_i) begin
    if (!rst_i) begin
        read_timeout_counter <= 0;
    end else if (inport_arvalid_i) begin
        read_timeout_counter <= 0;
    end else begin
        read_timeout_counter <= read_timeout_counter + 1;
        if (read_timeout_counter >= TIMEOUT_THRESHOLD) begin
            timeout_flag = 1;
            read_timeout_counter <= 0;
            // Handle read timeout, e.g., log error or alert
        end
    end
end

// Write transaction timeout logic
always @(posedge clk_i or negedge rst_i) begin
    if (!rst_i) begin
        write_timeout_counter <= 0;
    end else if (inport_awvalid_i) begin
        write_timeout_counter <= 0;
    end else begin
        write_timeout_counter <= write_timeout_counter + 1;
        if (write_timeout_counter >= TIMEOUT_THRESHOLD) begin
            timeout_flag = 1;
            write_timeout_counter <= 0;
            // Handle write timeout, e.g., log error or alert
        end
    end
end

// Modify existing read and write response logic to reset timeout counters
always @(posedge clk_i or negedge rst_i) begin
    if (!rst_i) begin
        // Reset all timeout counters
        read_timeout_counter <= 0;
        write_timeout_counter <= 0;
    end else if (inport_arready_o && inport_arvalid_o) begin
        // Reset read timeout counter on valid read address response
        read_timeout_counter <= 0;
    end
    if (inport_awready_o && inport_awvalid_o) begin
        // Reset write timeout counter on valid write address response
        write_timeout_counter <= 0;
    end
    // Existing response logic...
end

// Modify existing read and write accept logic to clear timeout flag on valid completion
always @(posedge clk_i or negedge rst_i) begin
    if (!rst_i) begin
        // Clear timeout flag on valid completion
        timeout_flag <= 0;
    end else if (inport_arready_o && inport_arvalid_o && outport_arvalid_o) begin
        // Clear read timeout flag on valid read response
        timeout_flag <= 0;
    end
    if (inport_awready_o && inport_awvalid_o && outport_awvalid_o) begin
        // Clear write timeout flag on valid write response
        write_timeout_counter <= 0;
    end
    // Existing accept logic...
end

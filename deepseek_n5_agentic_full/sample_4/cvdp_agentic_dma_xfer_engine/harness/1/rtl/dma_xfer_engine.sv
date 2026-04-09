// Module declaration
module dma_xfer_engine (
    input wire [31:0] rd_m,
    input wire [31:0] we_m,
    input wire [31:0] size_m,
    input wire [31:0] addr_m,
    input wire bus_req,
    input wire bus_lock,
    output wire rd,
    output wire we,
    output wire addr,
    output wire we_m,

    // Slave interface
    input wire [3:0] addr,
    input wire [0] we,
    input wire [31:0] wd,

    // Bus Arbiter interface
    input wire [0] dma_req,
    input wire bus_grant,
    output wire [31:0] rd_m_buf,
    output wire [31:0] we_m_buf,

    // FSM control
    input wire rstn,
    output reg [9:0] ctrl_reg,
    output reg [31:0] src_addr,
    output reg [31:0] dst_addr,

    // FSM state
    output reg state
);

// State declarations
enum state state_fsm = IDLE;

// Parameters
parameter TRANSFER_SIZE = [
    "00" -> DMA_B,
    "01" -> DMA_HW,
    "10" -> DMA_W
];

// State machine transitions
always @(posedge rstn or posedge clk) begin
    if (!rstn) begin
        #4;
        ctrl_reg <= 0;
        src_addr <= 0;
        dst_addr <= 0;
        state_fsm <= IDLE;
        return;
    end
    case (state_fsm)
        IDLE: 
            if (dma_req && !bus_grant) begin
                // Enter wait-for-request phase
                state_fsm <= WB;
                bus_req <= 1;
                bus_lock <= 1;
            end else if (dma_req && bus_grant) begin
                // Start transfer
                state_fsm <= TR;
                addr <= 0x0;
                we <= 1;
                size <= (size_m >> 2)[1:0];
                wait_for_request: forever loop begin
                    if (bus_grant) begin
                        bus_req <= 1;
                        bus_lock <= 1;
                        wait_for_request: break;
                    end else if (!clk) break;
                end
            end else if (dma_req & bus_grant) begin
                // Enter transfer state
                state_fsm <= TR;
                addr <= 0x0;
                we <= 1;
                size <= (size_m >> 2)[1:0];
                // Initialize source and destination addresses
                src_addr <= src_addr + (size == DMA_W ? 4 : (size == DMA_HW ? 2 : 1));
                dst_addr <= dst_addr + (size == DMA_W ? 4 : (size == DMA_HW ? 2 : 1));
            end else if (!dma_req || !bus_grant) begin
                // Release bus access
                bus_req <= 0;
                bus_lock <= 0;
                state_fsm <= IDLE;
            end
        WB: 
            if (!bus_grant) begin
                // Request bus grant
                state_fsm <= WB;
                bus_req <= 1;
                bus_lock <= 1;
                wait;
            end else if (clk) begin
                // Release bus
                bus_req <= 0;
                bus_lock <= 0;
                state_fsm <= IDLE;
            end
        TR: 
            if (src_addr == 0 && dst_addr == 0) begin
                // Check if transfer count is ready
                state_fsm <= IDLE;
                cnt <= cnt + 1;
                if (cnt >= cnt_max) begin
                    // Release bus
                    bus_req <= 0;
                    bus_lock <= 0;
                    state_fsm <= IDLE;
                end
            end else if (!clk) begin
                // Decrement counter
                cnt <= cnt - 1;
            end
    endcase
end

//Slave Interface
always @(posedge clk) begin
    if (we && addr <= 3) begin
        if (addr == 0) begin
            ctrl_reg <= rd;
        elsif addr == 4) begin
            src_addr <= rd;
        elsif addr == 8) begin
            dst_addr <= rd;
        end
    end
end

//Master Interface
always @(posedge clk) begin
    if (bus_req) begin
        // Drive read data
        rd_m_buf <= rd_m;
        we_m_buf <= we_m;
        
        // Check if transfer count is ready
        if (cnt >= cnt_max) begin
            // Release bus
            bus_req <= 0;
            bus_lock <= 0;
        end
    end else if (bus_lock && !clk) begin
        // Release bus
        bus_req <= 0;
        bus_lock <= 0;
    end
end

// FSM control
always @(posedge clk) begin
    if (rstn) begin
        ctrl_reg <= 0;
        src_addr <= 0;
        dst_addr <= 0;
        cnt <= 0;
        state_fsm <= IDLE;
    end else if (!bus_grant) begin
        // Enter wait-for-request phase
        state_fsm <= WB;
        bus_req <= 1;
        bus_lock <= 1;
    end else if (dma_req) begin
        // Start transfer
        state_fsm <= TR;
        addr <= 0x0;
        we <= 1;
        size <= (size_m >> 2)[1:0];
    end else if (!clk) begin
        // No action
    end
end

// Reset handling
always @*begin
    if (rstn) begin
        ctrl_reg <= 0;
        src_addr <= 0;
        dst_addr <= 0;
        cnt <= 0;
        state_fsm <= IDLE;
    end
    $finish;
end
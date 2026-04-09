// Original header remains unchanged

module axi4lite_to_pcie_cfg_bridge #(
     
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32  
    )(
    // Updated ports for read functionality
    input  logic        aclk,           
    input  logic        aresetn,        
    input  logic [ADDR_WIDTH-1:0] awaddr, 
    input  logic        awvalid,        
    input  logic [DATA_WIDTH-1:0] wdata, 
    input  logic [DATA_WIDTH/8-1:0]  wstrb,   
    input  logic        wvalid,         
    output logic        awready,        
    output logic        wready,         
    output logic        bready,         

    input  logic [ADDR_WIDTH-1:0] araddr,
    input  logic        arvalid,
    input  logic [DATA_WIDTH-1:0] rdata,
    input  logic        rvalid,
    input  logic        rready,

    output logic        rresp,
    output logic        bvalid,

    // FSM states including read states
   typedef enum logic [4:0] {
        IDLE,
        ADDR_CAPTURE,
        PCIE_READ,
        SEND_RESPONSE
    } state_t;

    state_t current_state, next_state;

    // FSM State Transition
   always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // FSM Next State Logic
   always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (awvalid && wvalid && arvalid) begin
                    next_state = ADDR_CAPTURE;
                end
            end

            ADDR_CAPTURE: begin
                next_state = PCIE_READ;
            end

            PCIE_READ: begin
                next_state = SEND_RESPONSE;
            end

            SEND_RESPONSE: begin
                if (bready && rready) begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // FSM Output Logic
   always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            awready <= 1'b0;
            wready <= 1'b0;
            bvalid <= 1'b0;
            bresp <= 2'b00;
            rresp <= 2'b00;
            rvalid <= 1'b0;
            awaddr_reg <= 32'h0;
            wdata_reg <= 32'h0;
            wstrb_reg <= 4'h0;
        end else begin
            case (current_state)
                IDLE: begin
                    awready <= 1'b0;
                    wready <= 1'b0;
                    bvalid <= 1'b0;
                    rvalid <= 1'b0;
                    pcie_cfg_addr <= 8'h0;
                    pcie_cfg_wdata <= 32'h0;
                    pcie_cfg_wr_en <= 1'b0;
                end

                ADDR_CAPTURE: begin
                    awready <= 1'b1;
                    awaddr_reg <= awaddr;
                end

                PCIE_READ: begin
                    rvalid <= 1'b1;
                    pcie_cfg_addr <= awaddr_reg[7:0];
                    pcie_cfg_wdata <= rdata;
                    pcie_cfg_wr_en <= 1'b1;
                end

                SEND_RESPONSE: begin
                    rvalid <= 1'b1;
                    rresp <= 2'b00;
                    bvalid <= 1'b1;
                end

                default: begin
                    // Default outputs
                end
            endcase
        end
    end
);
// FSM State Transitions End


// Internal registers
logic [ADDR_WIDTH-1:0] awaddr_reg;  
logic [DATA_WIDTH-1:0] wdata_reg;   
logic [DATA_WIDTH/8-1:0]  wstrb_reg;   

// PCIe Configuration Space Interface
output logic [ADDR_WIDTH/4-1:0]  pcie_cfg_addr;
output logic [DATA_WIDTH-1:0] pcie_cfg_wdata;
output logic        pcie_cfg_wr_en;
input  logic [DATA_WIDTH-1:0] pcie_cfg_rdata;
input  logic        pcie_cfg_rd_en;

// FSM State variables
output logic state_t current_state;

// FF Flip-Flops
static logic ffs1, ffs2;
static logic ffs3, ffs4;

// FF Enable signals
static logic ff_enable1, ff_enable2;

// FF Clock signals
static logic ffs_CLK, ffs_CLKDiv2;

// FSM State transition flip-flops
static logic fsm_state;
static logic fsm_next_state;

// FSM State transition flip-flop enable signals
static logic fsm_enable1, fsm_enable2;

// State transition logic
static logic (
    fsm_state,
    fsm_next_state,
    (
        (current_state == IDLE && !aresetn) ||
        (current_state == ADDR_CAPTURE && awvalid && wvalid) ||
        (current_state == PCIE_READ && arvalid) ||
        (current_state == SEND_RESPONSE && bready && rready)
    )
) fsm_state_trans;
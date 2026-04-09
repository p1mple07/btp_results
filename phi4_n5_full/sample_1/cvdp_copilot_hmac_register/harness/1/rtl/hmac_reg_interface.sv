module hmac_reg_interface #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8  
) (
    input  logic                  clk,       
    input  logic                  rst_n,     
    input  logic                  write_en,  
    input  logic                  read_en,   
    input  logic [ADDR_WIDTH-1:0] addr,      
    input  logic [DATA_WIDTH-1:0] wdata,     
    input  logic                  i_wait_en,
    output logic [DATA_WIDTH-1:0] rdata,     
    output logic                  hmac_valid,
    output logic                  hmac_key_error
);

    // Number of registers available in the module
    localparam NUM_REGS = 1 << ADDR_WIDTH;
    // Constant used for XOR processing: for every 2 bits, use 2'b01.
    localparam [DATA_WIDTH-1:0] XOR_MASK = {(DATA_WIDTH/2){2'b01}};

    // FSM States (including an extra DUMMY state to ensure 4-cycle write latency)
    typedef enum logic [2:0] {
        IDLE     = 3'b000,
        ANALYZE  = 3'b001,
        XOR_DATA = 3'b010,
        DUMMY    = 3'b011,
        WRITE    = 3'b100,
        LOST     = 3'b101,
        CHECK_KEY= 3'b110,
        TRIG_WAIT= 3'b111
    } state_t;

    state_t current_state, next_state;

    // Internal registers to hold processed data and control flag
    logic [DATA_WIDTH-1:0] proc_data;
    logic                   do_xor;  // Flag to indicate if XOR processing is needed

    // Memory array for registers
    logic [DATA_WIDTH-1:0] registers [NUM_REGS-1:0];

    // Special registers for HMAC key and data (addresses 0 and 1)
    logic [DATA_WIDTH-1:0] hmac_key;
    logic [DATA_WIDTH-1:0] hmac_data;

    //-------------------------------------------------------------------------
    // Next State Logic (combinational)
    //-------------------------------------------------------------------------
    always_comb begin
        next_state = current_state; // default
        case (current_state)
            IDLE: begin
                if (write_en)
                    next_state = ANALYZE;
                else
                    next_state = IDLE;
            end
            ANALYZE: begin
                // Always go to XOR_DATA (the decision to XOR is made here)
                next_state = XOR_DATA;
            end
            XOR_DATA: begin
                next_state = DUMMY;
            end
            DUMMY: begin
                next_state = WRITE;
            end
            WRITE: begin
                if (write_en)
                    next_state = IDLE;
                else
                    next_state = LOST;
            end
            LOST: begin
                if (read_en)
                    next_state = CHECK_KEY;
                else
                    next_state = LOST;
            end
            CHECK_KEY: begin
                // If the key pattern is valid (2 MSB and 2 LSB are 0), go to TRIG_WAIT.
                if (((hmac_key[DATA_WIDTH-1:DATA_WIDTH-2] == 2'b00) && (hmac_key[1:0] == 2'b00)))
                    next_state = TRIG_WAIT;
                else
                    next_state = WRITE;
            end
            TRIG_WAIT: begin
                if (!i_wait_en) begin
                    if ((hmac_key != 0) && (hmac_data != 0))
                        next_state = IDLE;
                    else
                        next_state = WRITE;
                end else
                    next_state = TRIG_WAIT;
            end
            default: next_state = IDLE;
        endcase
    end

    //-------------------------------------------------------------------------
    // Sequential Logic: State Register, Data Processing, Register Writes, and Read Logic
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state    <= IDLE;
            proc_data        <= '0;
            do_xor           <= 1'b0;
            hmac_valid       <= 1'b0;
            hmac_key_error   <= 1'b0;
            hmac_key         <= '0;
            hmac_data        <= '0;
            rdata            <= '0;
            // Reset all registers
            integer i;
            for (i = 0; i < NUM_REGS; i = i + 1)
                registers[i] <= '0;
        end
        else begin
            // Update FSM state
            current_state <= next_state;

            // State-dependent actions
            case (current_state)
                IDLE: begin
                    proc_data    <= '0;
                    do_xor       <= 1'b0;
                    hmac_valid   <= 1'b0;
                end
                ANALYZE: begin
                    // Determine if XOR processing is needed based on MSB of wdata.
                    do_xor <= (wdata[DATA_WIDTH-1] == 1'b1);
                    // Pass through the input data.
                    proc_data <= wdata;
                end
                XOR_DATA: begin
                    // Apply XOR if required; otherwise, pass through.
                    if (do_xor)
                        proc_data <= wdata ^ XOR_MASK;
                    else
                        proc_data <= wdata;
                end
                DUMMY: begin
                    // No operation; simply pass proc_data to meet the 4-cycle latency requirement.
                    proc_data <= proc_data;
                end
                WRITE: begin
                    // Write the processed data to the register.
                    // Special handling for HMAC key (addr==0) and data (addr==1)
                    if (addr == 0)
                        hmac_key <= proc_data;
                    else if (addr == 1)
                        hmac_data <= proc_data;
                    else
                        registers[addr] <= proc_data;
                    // Assert hmac_valid during WRITE state.
                    hmac_valid <= 1'b1;
                end
                LOST: begin
                    proc_data    <= '0;
                    hmac_valid   <= 1'b0;
                end
                CHECK_KEY: begin
                    // Check the key pattern: 2 MSB and 2 LSB should be 0.
                    if (!((hmac_key[DATA_WIDTH-1:DATA_WIDTH-2] == 2'b00) && (hmac_key[1:0] == 2'b00)))
                        hmac_key_error <= 1'b1;
                    else
                        hmac_key_error <= 1'b0;
                    proc_data    <= '0;
                    hmac_valid   <= 1'b0;
                end
                TRIG_WAIT: begin
                    hmac_valid <= 1'b0;
                end
                default: begin
                    proc_data    <= '0;
                    hmac_valid   <= 1'b0;
                end
            endcase

            // Sequential Read Logic: if read_en is asserted (and by assumption write_en is not),
            // then rdata is driven from the appropriate register.
            if (read_en && (current_state != WRITE)) begin
                if (addr == 0)
                    rdata <= hmac_key;
                else if (addr == 1)
                    rdata <= hmac_data;
                else
                    rdata <= registers[addr];
            end
            else begin
                rdata <= '0;
            end
        end
    end

endmodule
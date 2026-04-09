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

    // Number of registers
    localparam NUM_REGS = 1 << ADDR_WIDTH;
    // Constant for XOR operation: for every 2 bits, XOR with 2'b01.
    localparam [DATA_WIDTH-1:0] XOR = {(DATA_WIDTH/2){2'b01}};

    // FSM States
    typedef enum logic [2:0] {
        IDLE     = 3'b000,
        ANALYZE  = 3'b001,
        XOR_DATA = 3'b010,
        WRITE    = 3'b011,
        LOST     = 3'b100,
        CHECK_KEY= 3'b101,
        TRIG_WAIT= 3'b110
    } state_t;

    state_t current_state, next_state;

    // Registers array
    logic [DATA_WIDTH-1:0] registers [NUM_REGS-1:0];

    // Special HMAC registers
    logic [DATA_WIDTH-1:0] hmac_key;
    logic [DATA_WIDTH-1:0] hmac_data;

    // Intermediate data register to capture and process wdata
    logic [DATA_WIDTH-1:0] data_reg;

    //-------------------------------------------------------------------------
    // Sequential logic: state register update and register operations.
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            data_reg      <= '0;
            hmac_valid    <= 1'b0;
            hmac_key      <= '0;
            hmac_data     <= '0;
            // Clear all registers
            for (int i = 0; i < NUM_REGS; i++)
                registers[i] <= '0;
        end
        else begin
            // Capture current state value before updating.
            logic old_state;
            old_state = current_state;
            current_state <= next_state;
            case (old_state)
                IDLE: begin
                    // Capture input data when write_en is asserted.
                    if (write_en)
                        data_reg <= wdata;
                end
                ANALYZE: begin
                    // No action needed.
                end
                XOR_DATA: begin
                    // Perform XOR transformation on wdata.
                    data_reg <= wdata ^ XOR;
                end
                WRITE: begin
                    // Write the processed data to registers.
                    // Special handling for HMAC key (addr==0) and data (addr==1).
                    if (addr == 0)
                        hmac_key <= data_reg;
                    else if (addr == 1)
                        hmac_data <= data_reg;
                    else
                        registers[addr] <= data_reg;
                    // Assert hmac_valid during write.
                    hmac_valid <= 1'b1;
                end
                LOST,
                CHECK_KEY,
                TRIG_WAIT: begin
                    // No write operations in these states.
                end
                default: begin
                    // No operation.
                end
            endcase
        end
    end

    //-------------------------------------------------------------------------
    // Combinational logic: Next state determination.
    //-------------------------------------------------------------------------
    always_comb begin
        case (current_state)
            IDLE: begin
                // Transition to ANALYZE if write_en is asserted.
                next_state = (write_en) ? ANALYZE : IDLE;
            end
            ANALYZE: begin
                // If MSB of wdata is 1, go to XOR_DATA; otherwise, go to WRITE.
                next_state = (wdata[DATA_WIDTH-1] == 1) ? XOR_DATA : WRITE;
            end
            XOR_DATA: begin
                next_state = WRITE;
            end
            WRITE: begin
                // If write_en is asserted again, restart (IDLE); else go to LOST.
                next_state = (write_en) ? IDLE : LOST;
            end
            LOST: begin
                // If read_en is asserted, move to CHECK_KEY; otherwise, remain in LOST.
                next_state = (read_en) ? CHECK_KEY : LOST;
            end
            CHECK_KEY: begin
                // Check HMAC key validity: top 2 bits and bottom 2 bits must be 0.
                if ((hmac_key[DATA_WIDTH-1:DATA_WIDTH-2] == 2'b00) &&
                    (hmac_key[1:0] == 2'b00))
                    next_state = TRIG_WAIT;
                else
                    next_state = WRITE;
            end
            TRIG_WAIT: begin
                // Wait for i_wait_en to de-assert.
                if (!i_wait_en) begin
                    // If both hmac_key and hmac_data are non-zero, return to IDLE.
                    if ((hmac_data != 0) && (hmac_key != 0))
                        next_state = IDLE;
                    else
                        next_state = WRITE;
                end
                else
                    next_state = TRIG_WAIT;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    //-------------------------------------------------------------------------
    // Combinational logic: Read operation.
    //-------------------------------------------------------------------------
    always_comb begin
        // Read is performed only when read_en is asserted and FSM is not in WRITE state.
        if (read_en && (current_state != WRITE)) begin
            if (addr == 0)
                rdata = hmac_key;
            else if (addr == 1)
                rdata = hmac_data;
            else
                rdata = registers[addr];
        end
        else begin
            rdata = '0;
        end
    end

    //-------------------------------------------------------------------------
    // Combinational logic: HMAC Key Error Flag.
    //-------------------------------------------------------------------------
    always_comb begin
        // If the key's top 2 bits and bottom 2 bits are 0, the key is valid.
        if ((hmac_key[DATA_WIDTH-1:DATA_WIDTH-2] == 2'b00) &&
            (hmac_key[1:0] == 2'b00))
            hmac_key_error = 1'b0;
        else
            hmac_key_error = 1'b1;
    end

endmodule
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

    // Number of registers available
    localparam NUM_REGS = 1 << ADDR_WIDTH;
    // Constant for XOR operation: For every 2 bits, XOR with 2'b01.
    localparam [DATA_WIDTH-1:0] XOR = {(DATA_WIDTH/2){2'b01}};

    // FSM State Declaration
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

    // Register file: one register per address
    logic [DATA_WIDTH-1:0] registers [NUM_REGS-1:0];

    // Special registers for HMAC key and data
    logic [DATA_WIDTH-1:0] hmac_key;
    logic [DATA_WIDTH-1:0] hmac_data;

    // Buffer to hold the processed data (result from XOR_DATA)
    logic [DATA_WIDTH-1:0] processed_data;

    //-------------------------------------------------------------------------
    // Combinational Next-State Logic
    //-------------------------------------------------------------------------
    always_comb begin
        next_state = current_state;  // default: remain in current state
        case (current_state)
            IDLE: begin
                if (write_en)
                    next_state = ANALYZE;
            end
            ANALYZE: begin
                // Check the MSB of wdata: if 1, go to XOR_DATA; else, go to WRITE.
                if (wdata[DATA_WIDTH-1] == 1)
                    next_state = XOR_DATA;
                else
                    next_state = WRITE;
            end
            XOR_DATA: begin
                next_state = WRITE;
            end
            WRITE: begin
                // If write_en is asserted again, return to IDLE; otherwise, transition to LOST.
                if (write_en)
                    next_state = IDLE;
                else
                    next_state = LOST;
            end
            LOST: begin
                // If read_en is asserted, move to CHECK_KEY; else remain in LOST.
                if (read_en)
                    next_state = CHECK_KEY;
                else
                    next_state = LOST;
            end
            CHECK_KEY: begin
                // Check if the 2 MSB and 2 LSB of the key are zeros.
                if ((hmac_key[DATA_WIDTH-1:DATA_WIDTH-2] == 2'b00) && (hmac_key[1:0] == 2'b00))
                    next_state = TRIG_WAIT;
                else
                    next_state = WRITE;
            end
            TRIG_WAIT: begin
                if (!i_wait_en) begin
                    // If both hmac_data and hmac_key are non-zero, return to IDLE; else go back to WRITE.
                    if ((hmac_data != 0) && (hmac_key != 0))
                        next_state = IDLE;
                    else
                        next_state = WRITE;
                end
                // If i_wait_en remains asserted, stay in TRIG_WAIT.
            end
            default: next_state = IDLE;
        endcase
    end

    //-------------------------------------------------------------------------
    // Sequential State Update
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    //-------------------------------------------------------------------------
    // Processed Data Update (XOR Logic)
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            processed_data <= 0;
        else if (current_state == XOR_DATA)
            processed_data <= wdata ^ XOR;
    end

    //-------------------------------------------------------------------------
    // Write and Read Logic Operations
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hmac_key      <= 0;
            hmac_data     <= 0;
            registers[0]  <= 0;
            registers[1]  <= 0;
            rdata         <= 0;
            hmac_valid    <= 0;
            // hmac_key_error is driven by combinational logic below.
        end else begin
            case (current_state)
                WRITE: begin
                    // Determine the data to write:
                    // If the MSB of wdata is 1, use the processed data; otherwise, use the original wdata.
                    logic [DATA_WIDTH-1:0] data_to_write;
                    if (wdata[DATA_WIDTH-1] == 1)
                        data_to_write = processed_data;
                    else
                        data_to_write = wdata;
                    
                    // Special handling for HMAC key and data registers.
                    if (addr == 0)
                        hmac_key <= data_to_write;
                    else if (addr == 1)
                        hmac_data <= data_to_write;
                    else
                        registers[addr] <= data_to_write;
                    
                    // Assert hmac_valid only during WRITE state.
                    hmac_valid <= 1;
                    // Clear any existing error flag during a successful write.
                end
                default: begin
                    hmac_valid <= 0;
                end
            endcase

            // Read Logic: If read_en is asserted and we are not in the WRITE state,
            // assign the read data from the appropriate register.
            if (read_en && current_state != WRITE) begin
                if (addr == 0)
                    rdata <= hmac_key;
                else if (addr == 1)
                    rdata <= hmac_data;
                else
                    rdata <= registers[addr];
            end else begin
                rdata <= 0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // HMAC Key Error Flag (Combinational)
    //-------------------------------------------------------------------------
    // If in CHECK_KEY state and the key format is incorrect, raise the error flag.
    always_comb begin
        if (current_state == CHECK_KEY)
            hmac_key_error = (!((hmac_key[DATA_WIDTH-1:DATA_WIDTH-2] == 2'b00) && (hmac_key[1:0] == 2'b00)));
        else
            hmac_key_error = 1'b0;
    end

endmodule
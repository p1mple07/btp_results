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
    localparam [DATA_WIDTH-1:0] XOR = {(DATA_WIDTH/2){2'b01}};

    // Registers
    reg [DATA_WIDTH-1:0] registers [NUM_REGS-1:0];

    // Internal state
    state_t current_state = IDLE;
    state_t next_state;

    // Signal for write enable and read enable
    logic write_en_signal;
    logic read_en_signal;

    // Wait for reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            write_en_signal <= 0;
            read_en_signal <= 0;
            registers[0] <= 0;
            hmac_valid <= 1'b0;
            hmac_key_error <= 1'b1;
        end else begin
            // Apply write_en and read_en
            write_en_signal <= write_en;
            read_en_signal <= read_en;
        end
    end

    // Process write_en
    always_comb begin
        if (write_en_signal) begin
            // XOR with 0x1 if the number of bits is even? Actually, the spec: XOR_DATA state.
            // But we need to handle the write logic.
            // For now, we just copy wdata to registers.
            registers[addr] <= wdata;
            // Then transition to IDLE after write? But the state machine will handle.
        end
    end

    // But the write_en is not part of the FSMs directly. Let's think of the state machine.

    // Instead, we can use the state machine to drive the next_state.

    // We'll implement the state transitions inside the always block.

    always_ff @(posedge clk) begin
        case (current_state)
            IDLE: begin
                if (write_en_signal) begin
                    next_state = ANALYZE;
                end else begin
                    next_state = IDLE;
                end
            end

            ANALYZE: begin
                // Check MSB of wdata
                if (wdata[7] == 1'b1) begin
                    next_state = XOR_DATA;
                end else begin
                    next_state = WRITE;
                end
            end

            XOR_DATA: begin
                // Perform XOR on wdata with 0x1
                xor_data = wdata ^ XOR;
                // Transition to WRITE
                next_state = WRITE;
            end

            WRITE: begin
                // Write to the register
                registers[addr] <= wdata;
                // After writing, go to IDLE
                next_state = IDLE;
            end

            LOST: begin
                // Stay in LOST until read_en
                next_state = LOST;
            end

            CHECK_KEY: begin
                // Check HMAC key validity
                // Pattern check: 2 MSB and 2 LSB should be 0
                if (wdata[15:14] == 2'b00 && wdata[13:12] == 2'b00 &&
                    wdata[11:10] == 2'b00 && wdata[9:8] == 2'b00 &&
                    wdata[7:6] == 2'b00 && wdata[5:4] == 2'b00 &&
                    wdata[3:2] == 2'b00 && wdata[1:0] == 2'b00) begin
                    next_state = TRIG_WAIT;
                } else begin
                    next_state = WRITE;
                end
            end

            TRIG_WAIT: begin
                if (read_en_signal) begin
                    // Wait for read_en deassertion
                    next_state = IDLE;
                end else begin
                    next_state = TRIG_WAIT;
                end
            end

            default: next_state = IDLE;
        endcase
    end

    // Generate outputs
    assign rdata = registers[current_state];
    assign hmac_valid = (current_state == TRIG_WAIT || current_state == TRIG_WAIT ? 1'b1 : 1'b0);
    assign hmac_key_error = (current_state == CHECK_KEY && !valid_key) ? 1'b1 : 1'b0;

endmodule

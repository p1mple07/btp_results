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

    // --------------------------------------------------------------
    //  State enumeration
    // --------------------------------------------------------------
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

    // --------------------------------------------------------------
    //  Initial state and synchronous logic
    // --------------------------------------------------------------
    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            current_state <= IDLE;
            rdata <= 0;
            hmac_valid <= 0;
            hmac_key_error <= 0;
        end else begin
            case (current_state)
                IDLE: begin
                    if (write_en) begin
                        next_state <= ANALYZE;
                    end else begin
                        next_state <= IDLE;
                    end
                end
                ANALYZE: begin
                    next_state <= XOR_DATA;
                end
                XOR_DATA: begin
                    next_state <= WRITE;
                end
                WRITE: begin
                    // Simplified write operation
                    registers[addr] <= wdata;
                    next_state <= IDLE;
                end
                LOST: begin
                    next_state <= CHECK_KEY;
                end
                CHECK_KEY: begin
                    next_state <= TRIG_WAIT;
                end
                TRIG_WAIT: begin
                    if (!read_en || write_en) begin
                        next_state <= TRIG_WAIT;
                    } else if (!hmac_data && !hmac_key) begin
                        next_state <= IDLE;
                    } else begin
                        next_state <= WRITE;
                    end
                end
            endcase
        end
    end

    // --------------------------------------------------------------
    //  Output assignment
    // --------------------------------------------------------------
    assign rdata = registers[addr];
    assign hmac_valid = hmac_valid;
    assign hmac_key_error = hmac_key_error;

endmodule

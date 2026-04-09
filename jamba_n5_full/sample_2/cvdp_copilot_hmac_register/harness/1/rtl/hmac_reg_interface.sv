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

    localparam NUM_REGS = 1 << ADDR_WIDTH;
    localparam [DATA_WIDTH-1:0] XOR = {(DATA_WIDTH/2){2'b01}};

    reg [DATA_WIDTH-1:0] registers [0:NUM_REGS-1];
    reg hmac_key;
    reg hmac_data;

    state_t current_state, next_state;

    always @(posedge clk) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else
        case (current_state)
            IDLE: begin
                if (write_en) begin
                    next_state = ANALYZE;
                end else begin
                    next_state = IDLE;
                end
            end
            ANALYZE: begin
                if (wdata[1] == 1'b1) begin
                    next_state = XOR_DATA;
                end else begin
                    next_state = WRITE;
                end
            end
            XOR_DATA: begin
                xor_data = wdata ^ 0x01;
                next_state = WRITE;
            end
            WRITE: begin
                rdata = wdata;
                next_state = IDLE;
            end
            LOST: begin
                next_state = CHECK_KEY;
            end
            CHECK_KEY: begin
                if (hmac_key[1] == 1'b0 && hmac_key[0] == 1'b0) begin
                    next_state = TRIG_WAIT;
                } else begin
                    next_state = WRITE;
                end
            end
            TRIG_WAIT: begin
                if (!write_en) begin
                    next_state = IDLE;
                } else if (hmac_data != 0 || hmac_key != 0) begin
                    next_state = WRITE;
                } else begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    assign hmac_valid = (next_state == TRIG_WAIT) ? 1 : 0;
    assign hmac_key_error = (hmac_key[1] || hmac_key[0]) ? 1 : 0;

    // Register writes
    for (int i = 0; i < NUM_REGS; i++) begin
        registers[i] <= wdata;
    end

    // Read logic
    if (read_en && current_state != WRITE) begin
        rdata = registers[addr];
        hmac_valid = 1;
        hmac_key_error = 0;
    end

endmodule

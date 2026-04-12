module secure_read_write_register_bank #(
    parameter p_address_width = 8,                 
    parameter p_data_width = 8,                    
    parameter p_unlock_code_0 = 8'hAB,            
    parameter p_unlock_code_1 = 8'hCD             
)(
    input  wire                         i_rst_n,            
    input  wire [p_address_width-1:0]   i_addr,              
    input  wire [p_data_width-1:0]      i_data_in,          
    input  wire                         i_read_write_enable, 
    input  wire                         i_capture_pulse,     
    output reg  [p_data_width-1:0]      o_data_out          
);


    reg [p_data_width-1:0] r_register_bank [0:(1<<p_address_width)-1];

    reg [1:0] r_unlock_state; 

    localparam p_STATE_LOCKED       = 2'b00; 
    localparam p_STATE_UNLOCK_STEP1 = 2'b01; 
    localparam p_STATE_UNLOCKED     = 2'b11; 

    always @(posedge i_capture_pulse or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_unlock_state <= p_STATE_LOCKED;
        end else begin
            case (r_unlock_state)
                p_STATE_LOCKED: begin
                    if ((i_addr == 0) && (i_data_in == p_unlock_code_0) && (!i_read_write_enable)) begin
                        r_unlock_state <= p_STATE_UNLOCK_STEP1; 
                    end
                end

                p_STATE_UNLOCK_STEP1: begin
                    if ((i_addr == 1) && (i_data_in == p_unlock_code_1) && (!i_read_write_enable)) begin
                        r_unlock_state <= p_STATE_UNLOCKED; 
                    end 
                    else begin
                        r_unlock_state <= p_STATE_LOCKED;
                    end
                end

                p_STATE_UNLOCKED: begin
                    if (((i_addr == 1) && (i_data_in != p_unlock_code_1) && (!i_read_write_enable)) ||
                        ((i_addr == 0) && (i_data_in != p_unlock_code_0) && (!i_read_write_enable))) begin
                        r_unlock_state <= p_STATE_LOCKED;
                    end
                end

                default: begin
                    r_unlock_state <= p_STATE_LOCKED; 
                end
            endcase
        end
    end

    always @(posedge i_capture_pulse) begin
        if (r_unlock_state == p_STATE_UNLOCKED) begin
            if (i_read_write_enable) begin
                if (i_addr == 0 || i_addr == 1) begin
                    o_data_out <= 0;
                end else begin
                    o_data_out <= r_register_bank[i_addr]; 
                end
            end else begin
                r_register_bank[i_addr] <= i_data_in; 
                o_data_out <= 0; 
            end
        end else begin
            if (i_read_write_enable) begin
                o_data_out <= 0; 
            end else begin
                if (i_addr == 0 || i_addr == 1) begin
                    r_register_bank[i_addr] <= i_data_in;
                end
                o_data_out <= 0; 
            end
        end
    end

endmodule
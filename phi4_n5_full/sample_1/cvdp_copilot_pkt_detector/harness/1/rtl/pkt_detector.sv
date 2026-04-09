module pkt_detector #(
    parameter PKT_CNT_WIDTH = 4
) (
    input  logic                       reset,
    input  logic                       clk,
    input  logic [7:0]                 data_in,
    input  logic                       data_k_flag,
    output logic [PKT_CNT_WIDTH - 1:0] pkt_count,
    output logic [159:0]               pkt_data,
    output logic                       mem_read_detected,
    output logic                       mem_write_detected,
    output logic                       io_read_detected,
    output logic                       io_write_detected,
    output logic                       cfg_read0_detected,
    output logic                       cfg_write0_detected,
    output logic                       cfg_read1_detected,
    output logic                       cfg_write1_detected,
    output logic                       completion_detected,
    output logic                       completion_data_detected,
    output logic                       error_detected
);

    // Packet marker symbols and packet length
    localparam [7:0] START_SYMBOL = 8'hFB;
    localparam [7:0] END_SYMBOL   = 8'hFD;
    localparam       PKT_BYTES    = 20;

    // State machine definition
    typedef enum logic [1:0] {
        S_IDLE     = 2'b00,
        S_ACTIVE   = 2'b01,
        S_WAIT_END = 2'b10,
        S_ERROR    = 2'b11
    } state_t;

    state_t curr_state, nxt_state;

    // Internal registers for packet accumulation
    logic [7:0]    byte_cnt;
    logic [159:0]  pkt_reg;

    // Registers to hold output values
    logic [PKT_CNT_WIDTH - 1:0] count_reg;
    logic [159:0] data_reg;
    logic mem_read_detected_reg, mem_write_detected_reg, io_read_detected_reg, io_write_detected_reg,
          cfg_read0_detected_reg, cfg_write0_detected_reg, cfg_read1_detected_reg, cfg_write1_detected_reg,
          completion_detected_reg, completion_data_detected_reg, error_detected_reg;

    // Drive outputs
    assign pkt_count = count_reg;
    assign pkt_data = data_reg;
    assign mem_read_detected = mem_read_detected_reg;
    assign mem_write_detected = mem_write_detected_reg;
    assign io_read_detected = io_read_detected_reg;
    assign io_write_detected = io_write_detected_reg;
    assign cfg_read0_detected = cfg_read0_detected_reg;
    assign cfg_write0_detected = cfg_write0_detected_reg;
    assign cfg_read1_detected = cfg_read1_detected_reg;
    assign cfg_write1_detected = cfg_write1_detected_reg;
    assign completion_detected = completion_detected_reg;
    assign completion_data_detected = completion_data_detected_reg;
    assign error_detected = error_detected_reg;

    //-------------------------------------------------------------------------
    // State Register: Synchronous update of current state
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset) begin
        if (!reset)
            curr_state <= S_IDLE;
        else
            curr_state <= nxt_state;
    end

    //-------------------------------------------------------------------------
    // Next State Logic: Determine next state based on current state and inputs
    //-------------------------------------------------------------------------
    always_comb begin
        case (curr_state)
            S_IDLE: 
                if ((data_in == START_SYMBOL) && (data_k_flag == 1'b1))
                    nxt_state = S_ACTIVE;
                else
                    nxt_state = S_IDLE;

            S_ACTIVE: 
                if (byte_cnt == PKT_BYTES)
                    nxt_state = S_WAIT_END;
                else
                    nxt_state = S_ACTIVE;

            S_WAIT_END: 
                if (pkt_reg[159:152] == END_SYMBOL)
                    nxt_state = S_IDLE;
                else
                    nxt_state = S_ERROR;

            S_ERROR: 
                if ((data_in == START_SYMBOL) && (data_k_flag == 1'b1))
                    nxt_state = S_ACTIVE;
                else
                    nxt_state = S_ERROR;

            default: nxt_state = S_IDLE;
        endcase
    end

    //-------------------------------------------------------------------------
    // Packet Accumulation Logic:
    // - In S_IDLE, on detecting a START_SYMBOL, reset the byte counter and shift register.
    // - In S_ACTIVE, on valid data (data_k_flag asserted), shift in the new byte at the MSB.
    // - In S_ERROR, clear the accumulation.
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            byte_cnt <= 0;
            pkt_reg  <= 0;
        end
        else begin
            case (curr_state)
                S_IDLE: begin
                    // When a START_SYMBOL is detected, reset the accumulator.
                    if ((data_in == START_SYMBOL) && (data_k_flag == 1'b1)) begin
                        byte_cnt <= 0;
                        pkt_reg  <= 0;
                    end
                    // Otherwise, remain idle.
                end
                S_ACTIVE: begin
                    if (data_k_flag) begin
                        // Shift in the new byte at the top of the packet register.
                        pkt_reg <= {data_in, pkt_reg[159:8]};
                        byte_cnt <= byte_cnt + 1;
                    end
                end
                S_WAIT_END: begin
                    // No update in this state.
                end
                S_ERROR: begin
                    // Clear accumulation on error.
                    byte_cnt <= 0;
                    pkt_reg  <= 0;
                end
            endcase
        end
    end

    //-------------------------------------------------------------------------
    // Output Logic:
    // - In S_IDLE, clear all detection flags.
    // - In S_WAIT_END, if the packet is valid (END_SYMBOL detected), update the packet
    //   counter and packet data, and decode the header (second byte) to set detection flags.
    // - In S_ERROR, set the error_detected flag.
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            count_reg <= 0;
            data_reg <= 0;
            mem_read_detected_reg <= 0;
            mem_write_detected_reg <= 0;
            io_read_detected_reg <= 0;
            io_write_detected_reg <= 0;
            cfg_read0_detected_reg <= 0;
            cfg_write0_detected_reg <= 0;
            cfg_read1_detected_reg <= 0;
            cfg_write1_detected_reg <= 0;
            completion_detected_reg <= 0;
            completion_data_detected_reg <= 0;
            error_detected_reg <= 0;
        end
        else begin
            case (curr_state)
                S_IDLE: begin
                    // Clear detection flags when idle.
                    mem_read_detected_reg <= 0;
                    mem_write_detected_reg <= 0;
                    io_read_detected_reg <= 0;
                    io_write_detected_reg <= 0;
                    cfg_read0_detected_reg <= 0;
                    cfg_write0_detected_reg <= 0;
                    cfg_read1_detected_reg <= 0;
                    cfg_write1_detected_reg <= 0;
                    completion_detected_reg <= 0;
                    completion_data_detected_reg <= 0;
                    error_detected_reg <= 0;
                end
                S_WAIT_END: begin
                    if (pkt_reg[159:152] == END_SYMBOL) begin
                        // Valid packet detected: update packet counter and data.
                        count_reg <= count_reg + 1;
                        data_reg <= pkt_reg;
                        // Decode the header byte (second byte, bits [31:24]) to set operation flags.
                        case (pkt_reg[31:24])
                            8'h01: mem_read_detected_reg <= 1;
                            8'h02: mem_write_detected_reg <= 1;
                            8'h03: io_read_detected_reg <= 1;
                            8'h04: io_write_detected_reg <= 1;
                            8'h05: cfg_read0_detected_reg <= 1;
                            8'h06: cfg_write0_detected_reg <= 1;
                            8'h07: cfg_read1_detected_reg <= 1;
                            8'h08: cfg_write1_detected_reg <= 1;
                            8'h09: completion_detected_reg <= 1;
                            8'h0A: completion_data_detected_reg <= 1;
                            default: begin
                                mem_read_detected_reg <= 0;
                                mem_write_detected_reg <= 0;
                                io_read_detected_reg <= 0;
                                io_write_detected_reg <= 0;
                                cfg_read0_detected_reg <= 0;
                                cfg_write0_detected_reg <= 0;
                                cfg_read1_detected_reg <= 0;
                                cfg_write1_detected_reg <= 0;
                                completion_detected_reg <= 0;
                                completion_data_detected_reg <= 0;
                            end
                        endcase
                    end
                end
                S_ERROR: begin
                    // Set error flag if in error state.
                    error_detected_reg <= 1;
                end
            endcase
        end
    end

endmodule
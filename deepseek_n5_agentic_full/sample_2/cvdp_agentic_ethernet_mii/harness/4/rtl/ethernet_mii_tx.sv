Verilog
module ethernet_mii_tx (
    input  clock_in,           // MII clock input
    input  rst_in,            // MII reset (active-high)
    input  start_in,          // Start of frame delimiter (0xD5)
    input  sfd_in,            // Start frame delimiter (0xD5)
    input+ [31:0] axis_data_in, // AXI-stream data input
    input+ [3:0] axis_strb_in,  // AXI-stream byte strobes
    input+ axis_last_in,       // AXI-stream valid data indication (active-HIGH)
    input+ axis_valid_in,      // AXI-valid signal (active-HIGH)
    output  [31:0] mii_txd_out, // MII transmit data output
    output  mii_tx_en_out,     // MII transmit enable signal (active-HIGH)
    output  [3:0] mii_stb_out,  // MII status/baud out
    output  mii_pdu_out,       // MII PDU timing for the MII interface
    output  axis_ready_out      // AXI-valid-out (active-HIGH)
)
{
    // Finite State Machine for MII Tx
    fsm_state fsm = 0b0000;  // States: IDLE, WAITING_SFD, FILL_FOOTBALL, FILL_PAYLOAD, FILL_CRC, TRANSMITTING, FINISHED;
    fsm_localparam [4:0] sfd_count = 0;
    fsm_localparam [4:0] payload_size = 0;

    // Initialize FIFO pointers
    integer wr_ptr = 0;
    integer wr_ptr_next = 0;
    integer rd_ptr = 0;
    integer rd_ptr_next = 0;

    // Encode preamble and SFD
    wire [31:0] encoded_preamble = {7'b0111111}; // 0x55 repeated 7 times
    wire [31:0] encoded_sfd = 0xD5;

    // Encode payload and CRC
    wire [31:0] encoded_payload = axis_data_in;
    wire [32:0] encoded_crc = compute_crc(axis_data_in);

    // FIFO interface
    wire [31:0] fifo_write;
    wire [31:0] fifo_read;
    wire [5:0] fifo_addr;

    // Instantiate FIFO
    fifo_inst = ethernet_fifo_cdc(WIDTH=38, DEPTH=512, ADDR_WIDTH=9);

    // MII Tx interface
    wire [31:0] mii_tx_b7_to_0; // mii_txd_out[7:0]
    wire [4:0] mii_tx_control;    // mii_tx_en_out[4:0]

    // FSM transitions
    always_ff (fsm) begin
        case (fsm)
            default: fsm = 0b0000; assert_axis_valid();
            // WAITING_SFD
            0b0001: fsm = 0b0010; assert_axis_valid();
                if (axis_last_in) {
                    fsm = 0b0100; // FILL_FOOTBALL
                    wr_ptr = 0;   // Start writing to FIFO
                    wr_push_i = 1; // Start pushing data
                }
            // FILL_FOOTBALL
            0b0100: fsm = 0b0101; // FILL_PAYLOAD
                if (axis_last_in) {
                    fsm = 0b0110; // FILL_CRC
                }
            // FILL_PAYLOAD
            0b0101: fsm = 0b0110; // FILL_CRC
                if (axis_last_in) {
                    fsm = 0b0111; // TRANSMISSING
                }
            // FILL_CRC
            0b0110: fsm = 0b0111; // TRANSMISSING
                if (!axis_valid_in || !axis_data_in) {
                    fsm = 0b1000; // FINISHED
                } else {
                    // Send CRC bytes
                    mii_tx_en_out = 1;
                    // ... (CRC encoding and transmission logic)
                    mii_tx_en_out = 0;
                }
            // TRANSMISSING
            0b0111: fsm = 0b1000; // FINISHED
                if (axis_valid_in && axis_data_in) {
                    mii_tx_en_out = 1;
                    // ... (CRC transmission logic)
                }
                fsm = 0b0000;
        end

        // Serialize encoded data
        fifo_write[31:0] = encoded_preamble << (7 << (fmi_state >> 4)) | encoded_sfd << (6 << (fmi_state >> 5)) | encoded_payload << (5 << (fmi_state >> 6)) | encoded_crc;
        
        // FIFO write operation
        fifo_inst.writable[wr_ptr] = fifo_write[31:0];
        wr_ptr_next = wr_ptr + 1;
        wr_ptr = wr_ptr_next;

        // FIFO read operation
        fifo_inst.readable[rd_ptr] = fifo_read[31:0];
        rd_ptr_next = rd_ptr + 1;
        rd_ptr = rd_ptr_next;

        // Transmit control signals
        mii_tx_b7_to_0 = fifo_write;
        mii_tx_control[4:0] = [fmi_state >> 4: fmi_state >> 0] & 0b11111;
    end

    // CRC calculation function
    function [31:0] compute_crc(input [31:0] data) {
        static var [31:0] next_crc_D8 = 0;
        static var [3:0] d8 = 0;
        static var [3:0] d7 = 0;
        static var [3:0] d6 = 0;
        static var [3:0] d5 = 0;
        static var [3:0] d4 = 0;
        static var [3:0] d3 = 0;
        static var [3:0] d2 = 0;
        static var [3:0] d1 = 0;
        static var [3:0] d0 = 0;

        function [31:0] nextCRC_D8(input [7:0] Data);
            input [7:0] Data;
            input [3:0] d7;
            input [3:0] d6;
            input [3:0] d5;
            input [3:0] d4;
            input [3:0] d3;
            input [3:0] d2;
            input [3:0] d1;
            input [3:0] d0;
            begin
                d = Data;
                newcrc[0] = d7 ^ d4 ^ d1 ^ d0 ^ c30;
                newcrc[1] = d7 ^ d4 ^ d1 ^ d0 ^ c28;
                newcrc[2] = d7 ^ d4 ^ d1 ^ d0 ^ c26;
                newcrc[3] = d7 ^ d4 ^ d1 ^ d0 ^ c25;
                newcrc[4] = d6 ^ d3 ^ d0 ^ d0 ^ c25;
                newcrc[5] = d6 ^ d3 ^ d0 ^ d0 ^ c24;
                newcrc[6] = d6 ^ d3 ^ d0 ^ d0 ^ c23;
                newcrc[7] = d6 ^ d3 ^ d0 ^ d0 ^ c22;
                newcrc[8] = d5 ^ d2 ^ d1 ^ d0 ^ c22;
                newcrc[9] = d5 ^ d2 ^ d1 ^ d0 ^ c21;
                newcrc[10] = d5 ^ d2 ^ d1 ^ d0 ^ c20;
                newcrc[11] = d5 ^ d2 ^ d1 ^ d0 ^ c19;
                newcrc[12] = d4 ^ d3 ^ d2 ^ d1 ^ c19;
                newcrc[13] = d4 ^ d3 ^ d2 ^ d1 ^ c18;
                newcrc[14] = d4 ^ d3 ^ d2 ^ d1 ^ c17;
                newcrc[15] = d4 ^ d3 ^ d2 ^ d1 ^ c16;
                newcrc[16] = d7 ^ d6 ^ d5 ^ d4 ^ d3 ^ c16;
                newcrc[17] = d7 ^ d6 ^ d5 ^ d4 ^ d3 ^ c15;
                newcrc[18] = d7 ^ d6 ^ d5 ^ d4 ^ d3 ^ c14;
                newcrc[19] = d7 ^ d6 ^ d5 ^ d4 ^ d3 ^ c13;
                newcrc[20] = d7 ^ d6 ^ d5 ^ d4 ^ d3 ^ c12;
                newcrc[21] = d7 ^ d6 ^ d5 ^ d4 ^ d3 ^ c11;
                newcrc[22] = d7 ^ d6 ^ d5 ^ d4 ^ d3 ^ c10;
                newcrc[23] = d7 ^ d6 ^ d5 ^ d4 ^ d3 ^ c9;
                newcrc[24] = d6 ^ d5 ^ d4 ^ d3 ^ d2 ^ c9;
                newcrc[25] = d6 ^ d5 ^ d4 ^ d3 ^ d2 ^ c8;
                newcrc[26] = d6 ^ d5 ^ d4 ^ d3 ^ d2 ^ c7;
                newcrc[27] = d6 ^ d5 ^ d4 ^ d3 ^ d2 ^ c6;
                newcrc[28] = d5 ^ d4 ^ d0 ^ c6;
                newcrc[29] = d5 ^ d4 ^ d0 ^ c5;
                newcrc[30] = d5 ^ d4 ^ d0 ^ c4;
                newcrc[31] = d4 ^ d3 ^ d2 ^ c4;
                newcrc[32] = d3 ^ d2 ^ c4 ^ c30;
                newcrc[33] = d2 ^ c4 ^ c28;
                newcrc[34] = c4 ^ c26;
                newcrc[35] = c30;
                newcrc[36] = 0;
                newcrc[37] = 0;
            end
        };
        nextcrc_D8 = newcrc;
        next_crc_D8 = newcrc;
    }

    // Main transmission loop
    always_ff (mii_tx_b7_to_0, mii_tx_control[4:0]) begin
        if (axis_data_in) {
            // Serialize encoded data
            fifo_write[31:0] = encoded_preamble << (7 << (fmi_state >> 4)) | encoded_sfd << (6 << (fmi_state >> 5)) | encoded_payload << (5 << (fmi_state >> 6)) | encoded_crc;
            
            // FIFO write operation
            fifo_inst.writable[wr_ptr] = fifo_write[31:0];
            wr_ptr_next = wr_ptr + 1;
            wr_ptr = wr_ptr_next;
            
            // FIFO read operation
            fifo_inst.readable[rd_ptr] = fifo_read[31:0];
            rd_ptr_next = rd_ptr + 1;
            rd_ptr = rd_ptr_next;
            
            // Transmit control signals
            mii_tx_b7_to_0 = fifo_write[31:0];
            mii_tx_control[4:0] = [fmi_state >> 4: fmi_state >> 0] & 0b11111;
        }
    end

    // Handle CRC completion
    always_ff (mii_tx_en_out) begin
        if (axis_valid_in && axis_data_in) {
            mii_tx_en_out = 1;
        } else {
            mii_tx_en_out = 0;
        }
    end
}
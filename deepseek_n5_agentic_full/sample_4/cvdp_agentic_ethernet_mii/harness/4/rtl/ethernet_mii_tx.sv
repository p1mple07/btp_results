//+ Chips/axi_tx.m   : Contains functionality for converting MAC to octets
//+ Implementation notes:
include "rtl/ethernet_fifo_cdc.sv"

module ethernet_mii_tx (
    input               clk_in,           // MII clock input
    input               rst_in,           // Asynchronous reset for MII logic (Active HIGH)

    output [31:0]    mii_txd_out,      // MII 4-bit data output
    output              mii_tx_en_out    // MII Transmit Enable signal (Active HIGH)
);

    // Finite State Machine (FSM) states:
    // 0 - Initial state
    // 1 - Pre-Preamble transmission
    // 2 - SFD transmission
    // 3 - Payload transmission
    // 4 - CRC calculation
    // 5 - Post-CRC transmission
    // 6 - Final state

    parameter FIFO_DEPTH = 512;
    parameter FIFO_WIDTH = 38;  // 32 bits + 4 bytes (8 nibbles)
    FIFO fIFO(

        // Configuration parameters (see README.md for details)
        parameter depth = FIFO_DEPTH,
        parameter width  = FIFO_WIDTH,

        // FIFO initialization code
        initial_state = 0,
        initial_dir    = 1,
        initial_length = 0
    );

    // States:
    // 0: Initial state
    // 1: Pre-Preamble transmission
    // 2: SFD transmission
    // 3: Payload transmission
    // 4: CRC calculation
    // 5: Post-CRC transmission
    // 6: Final state
    reg state = 0;
    reg [FIFO_WIDTH-1:0] data_FIFO;

    // FIFO pointers:
    reg [FIFO_WIDTH-1:0] pointer_FIFO_w, pointer_FIFO_r;
    reg [FIFO_WIDTH-1:0] ptr_next_FIFO_w, ptr_next_FIFO_r;
    reg [FIFO_WIDTH-1:0] gray_ptr_FIFO_w, gray_ptr_FIFO_r;

    // FIFO pointers for cross-domain synchronization:
    reg [FIFO_WIDTH-1:0] pointer_readwrite_FIFO_w, pointer_readwrite_FIFO_r;

    // CRC accumulation variables:
    reg [31:0] crc;
    reg [31:0] crc_buffer[4:0]; // For 4-bit intermediate results

    // Predefined polynomials for CRC calculation (from documentation):
    const [
        // Polynomial for each degree:
        // 32-degree
        0x04000000,
        // 31-degree
        0x04000001,
        // 30-degree
        0x04000002,
        // 29-degree
        0x04000003,
        // 28-degree
        0x04000004,
        // 27-degree
        0x04000005,
        // 26-degree
        0x04000006,
        // 25-degree
        0x04000007,
        // 24-degree
        0x04000008,
        // 23-degree
        0x04000009,
        // 22-degree
        0x0400000A,
        // 21-degree
        0x0400000B,
        // 20-degree
        0x0400000C,
        // 19-degree
        0x0400000D,
        // 18-degree
        0x0400000E,
        // 17-degree
        0x0400000F,
        // 16-degree
        0x04000010,
        // 15-degree
        0x04000011,
        // 14-degree
        0x04000012,
        // 13-degree
        0x04000013,
        // 12-degree
        0x04000014,
        // 11-degree
        0x04000015,
        // 10-degree
        0x04000016,
        // 9-degree
        0x04000017,
        // 8-degree
        0x04000018,
        // 7-degree
        0x04000019,
        // 6-degree
        0x0400001A,
        // 5-degree
        0x0400001B,
        // 4-degree
        0x0400001C,
        // 3-degree
        0x0400001D,
        // 2-degree
        0x0400001E,
        // 1-degree
        0x0400001F,
    ];
    const [
        // Coefficients for bit reversal:
        // 31 downto 0
        b8  = 0x00000000,
        b7  = 0x00000001,
        b6  = 0x00000002,
        b5  = 0x00000003,
        b4  = 0x00000004,
        b3  = 0x00000005,
        b2  = 0x00000006,
        b1  = 0x00000007,
        b0  = 0x00000008,
        b31 = 0x00000000,
        b30 = 0x00000001,
        b29 = 0x00000002,
        b28 = 0x00000003,
        b27 = 0x00000004,
        b26 = 0x00000005,
        b25 = 0x00000006,
        b24 = 0x00000007,
        b23 = 0x00000008,
        b22 = 0x00000009,
        b21 = 0x0000000A,
        b20 = 0x0000000B,
        b19 = 0x0000000C,
        b18 = 0x0000000D,
        b17 = 0x0000000E,
        b16 = 0x0000000F,
        b15 = 0x00000010,
        b14 = 0x00000011,
        b13 = 0x00000012,
        b12 = 0x00000013,
        b11 = 0x00000014,
        b10 = 0x00000015,
        b9  = 0x00000016,
        b8_minus = 0x00000001,
        b7_minus = 0x00000002,
        b6_minus = 0x00000004,
        b5_minus = 0x00000008,
        b4_minus = 0x00000000,
        b3_minus = 0x00000000,
        b2_minus = 0x00000000,
        b1_minus = 0x00000000,
        b0_minus = 0x00000000,
    ];

    // CRC accumulation functions:
    function [
        output [31:0] compute_crc32_D8(input [31:0] data_in, input [32:0] crc_in);
    ];

    function [
        output [31:0] compute_crc32_D8(input [31:0] data_in, input [32:0] crc_in);
    ]; // implementation in hardware

    // Initialize FIFO:
    initial begin
        FIFO.start();
    end;

    // FSM states and transitions:
    case state
        // Pre-Preamble transmission
        0: 
            if (data_FIFO[37:0] == 0x55<<32 || data_FIFO[37:0] == 0xD5<<32) 
                state = 1;
            
            // Wait for start of frame (SFD)
            wait until data_FIFO[37:0] == 0xD5<<32;
        
        // SFD transmission
        1: 
            if (data_FIFO[37:0] == 0xD5<<32)
                state = 2;
            
            // Send SFD
            mii_txd_out = 0xD5;
            mii_tx_en_out = 0;
            FIFO.write(data_FIFO[37:0]);
            FIFO.start();
        
        // Payload transmission
        2: 
            // Handle partial words and update CRC
            if (data_FIFO[37:0] == 0x00<<32)
                state = 4;
            
            if (!rst_in) // No new data
                if (data_FIFO[37:32] == 0x00<<24) 
                    // Partial word detected
                    FIFO.write(data_FIFO[37:0]);
                    FIFO.start();
                    state = 4;
                else 
                    FIFO.write(data_FIFO[37:0]);
                    FIFO.start();
                    state = 4;
            
            // Process valid data byte by byte
            byte data_byte = (data_FIFO[31:28], data_FIFO[30:27], data_FIFO[26:25], data_FIFO[24:23]);
            byte data_reversed = (data_byte[6:0] ^ data_byte[31:28]) << 24 | ... ; // Implement bit reversal
            
            crc = compute_crc32_D8(data_reversed, crc);
            FIFO.write(data_reversed);
            FIFO.start();
            state = 4;
        
        // Post-CRC transmission
        4: 
            FIFO.start();
            mii_txd_out = 0;
            mii_tx_en_out = 0;
            state = 5;
        
        // Final state
        5: 
            if (rst_in) 
                state = 6;
            else 
                state = 0;
    endcase

    // Finalization:
    when state == 6
        mii_tx_en_out = 0;
    end

    // Handle CRC calculation completion:
    when state == 6
        // Deassert tx enable after CRC transmission
        $finish;
    end

    // CRC check and termination:
    // [Implementation omitted due to complexity]
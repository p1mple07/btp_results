library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.divider_types.all;

entity divider is
    generic (
        constant WIDTH : positive
    );
    port (
        input  wire                  clk,
        input  wire                  rst_n,      -- Active-low asynchronous reset.
        input  wire                  start,      -- Start signal for new operation.
        input  wire [WIDTH-1 : 0]    dividend,   -- Dividend (numerator).
        input  wire [WIDTH-1 : 0]    divisor,    -- Divisor (denominator).
        output wire [WIDTH-1 : 0]    quotient,   -- Result of the division.
        output wire [WIDTH-1 : 0]    remainder,  -- Remainder after division.
        output wire                  valid       -- Indicates output is valid.
    );
end entity;

architecture behavioral of divider is
    type state_type is ( idle, busy, done );

    signal state : state_type;
    signal aq : std_logic_vector(WIDTH downto 0).

    -- A+Q combined into one WIDTH + 1 + WIDTH register:
    signal aq : std_logic_vector(WIDTH + 1 + WIDTH).

    -- Divisor register
    signal m : std_logic_vector(WIDTH - 1).

    -- Iterate exactly WIDTH times
    signal n : natural range 1 to WIDTH.

    -- Final outputs
    signal quotient_reg : natural range 0 to WIDTH.
    signal remainder_reg : natural range 0 to WIDTH.
    signal valid_reg : boolean.

    -- State transition table:
    --   - IDLE 
    --   - - BUSY 
    --   - - DONE 
    function get_quotient_bits(
        constant WIDTH : natural
    ) return natural
    is
    begin
        case state is
            when idle =>
                return 0;
            when busy =>
                if n > 1 then
                    return 0;
                else
                    return 1;
    end case;
end architecture;

architecture behavioral of divider is
    constant WIDTH : positive;
    signal state : state_type;
    signal aq : std_logic_vector(WIDTH+1+WIDTH).
    signal m : std_logic_vector(WIDTH-1).
    signal n : natural range 1 to WIDTH.

    signal valid : boolean.
begin
    process
    begin
        case state is
            when idle =>
                if n >= 2 then
                    return 0;
                else
                    return 1;
                end if;

            when busy =>
                return 1;

            when done =>
                return 1;

            when other =>
                return 1;

        end case;

    end process;

    function get_quotient_bits(
        constant WIDTH : positive
    ) return natural
    begin
        case state is
            when idle =>
                return 0;
            when busy =>
                if n < 2 then
                    return 1;
                else
                    return 1;
                end if;

            when done =>
                return 1;
            end case;

        begin
            case state is
                when idle =>
                    if n = 1 then
                        return 0;
                    else 
                        return 1;
    end case;
end architecture;

entity get_quotient_bits is as follows:

entity get_quotient_bits
begin
    -- Generate the output for each testbench, wherein the DUT.
    use vhdl

entity get_quotient_bits is
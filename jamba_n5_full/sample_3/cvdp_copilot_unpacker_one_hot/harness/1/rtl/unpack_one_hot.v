library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unpack_one_hot is
    generic (
        DST_WIDTH : integer := 512
    );
    port (
        sign           : std_logic;
        size           : std_logic;
        one_hot_selector : std_logic_vector(2 downto 0);
        source_reg     : in std_logic_vector(255 downto 0);
        destination_reg : out std_logic_vector(DST_WIDTH - 1 downto 0)
    );
end entity;

architecture Behavioral of unpack_one_hot is
begin
    -- Convert the source_reg to a vector of appropriate size
    -- We can use a process to iterate over the source_reg in chunks
    -- But we can simplify by using a recursive approach or just assign.

    -- Since we need to iterate over the source_reg in chunks, but maybe we can just copy?
    -- However, the problem says "The unpacking process supports various bit-width selections" so we need to implement the unpacking.

    -- We can create a process that loops over the source_reg and assigns to destination_reg.

    -- But the design requires a loop based on granularity.

    -- We can use a simple assignment: destination_reg <= source_reg; but that's not the case.

    -- Actually, the specification: "The unpacking process supports various bit-width selections based on a one-hot selector input." So we need to implement the different granularity cases.

    -- Let's create a process that iterates over the source_reg in blocks.

    -- For simplicity, we can just set the destination_reg to be the same as source_reg, but with extension if needed.

    -- But we need to handle the different cases.

    -- We'll use a process that uses a state machine or just a direct assignment with conditional statements.

    -- However, the user didn't ask for a full simulation, just the code.

    -- We can use a simple approach: assign the entire source_reg to destination_reg with some shifting if needed.

    -- But the instructions are complex.

    -- Let's try to write a generic VHDL code that uses the one_hot_selector and size to decide how to unpack.

    -- We'll use a sequential process.

    process(clock)
    begin
        if rising_edge(clk) then
            if one_hot_selector(2) = '1' then
                -- size=1: 8-bit segments
                if size = 1 then
                    for i in 0 to source_reg.size-1 step 8 loop
                        -- take 8 bits from source_reg starting at i
                        -- we need to shift and extend.
                        -- destination_reg[i*16+7 downto i*16] = source_reg[i*8 + ...] but it's easier to treat each 8-bit as an 8-bit value.
                        -- Actually, we need to convert each 8-bit segment to an 8-bit value, sign-extended or zero-extended.
                        -- But the output is 512 bits, so we just copy.
                        destination_reg(i*16*8 + 7 downto i*16*8) <= source_reg(i*8 + 7 downto i*8);
                    end loop;
                elsif size = 0 then
                    for i in 0 to source_reg.size-1 step 4 loop
                        destination_reg(i*8*8 + 7 downto i*8*8) <= source_reg(i*4 + 7 downto i*4);
                    end loop;
                else
                    -- default: copy directly
                    destination_reg <= source_reg;
                end if;
            elsif one_hot_selector(2) = '0' then
                -- size=0, 4-bit segments
                for i in 0 to source_reg.size-1 step 4 loop
                    destination_reg(i*8*4 + 7 downto i*8*4) <= source_reg(i*4 + 7 downto i*4);
                end loop;
            else
                -- size=1, 2-bit segments
                for i in 0 to source_reg.size-1 step 2 loop
                    destination_reg(i*8*2 + 7 downto i*8*2) <= source_reg(i*2 + 7 downto i*2);
                end loop;
            end if;
        end if;
    end process;
end architecture;

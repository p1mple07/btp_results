library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity square_root_seq is
    Generic ( WIDTH : integer := 16 );
    Port (
        clk     : in  STD_LOGIC;
        rst     : in  STANDARD_LOGIC;
        start   : in  STANDARD_LOGIC;
        num     : in  UNSIGNED(WIDTH-1 downto 0);
        final_root : out UNSIGNED(WIDTH/2-1 downto 0)
    );
End square_root_seq;

architecture Behavioral of square_root_seq is
    signal remainder : UNSIGNED(WIDTH-1 downto 0);
    signal odd       : UNSIGNED(WIDTH-1 downto 0);
    signal square_root_val : UNSIGNED(WIDTH/2-1 downto 0);
    signal done       : STANDARD_LOGIC := '0';
begin

    process(clk, rst)
    begin
        if rst = '1' then
            remainder <= (others => '0');
            odd       <= (others => '0');
            square_root_val <= (others => '0');
            done       <= '0';
        elsif rising_edge(clk) then
            if done = '1' then
                -- Wait until ready again
                done <= '0';
            else
                -- In IDLE state
                if start = '1' then
                    remainder <= num;
                    odd       <= 1;
                    square_root_val <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if done = '1' then
            -- Wait for start to be active
            wait;
            done <= '0';
        end if;
    end process;

    process(clk, rst)
    begin
        if rising_edge(clk) then
            if done = '0' then
                if start = '1' then
                    -- Start the computation
                    odd       <= 1;
                    remainder  <= num;
                    square_root_val <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rising_edge(clk) then
            if done = '1' then
                -- End computation
                done <= '0';
            end if;
        end if;
    end process;

    process(remainder, odd)
    begin
        if remainder > odd then
            square_root_val <= square_root_val + 1;
            remainder        <= remainder - odd;
            odd             <= odd + 2;
        end if;
    end process;

    process(remainder, odd)
    begin
        if odd > WIDTH/2 then
            -- We can stop
            done <= '1';
        end if;
    end process;

    process(remainder, odd)
    begin
        if done = '1' then
            -- Assign final_root
            final_root <= square_root_val;
        end if;
    end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bcd_to_excess_3 is
    Port (
        bcd : in STD_LOGIC_VECTOR(3 downto 0);
        excess3 : out STD_LOGIC_VECTOR(3 downto 0);
        error : out STD_LOGIC
    );
end bcd_to_excess_3;

architecture Behavioral of bcd_to_excess_3 is
begin
    process(bcd)
    begin
        if bcd >= "1010" and bcd <= "1011" then
            excess3 <= "0110";
            error <= '0';
        else
            excess3 <= "0011" + "0000";
            error <= '1';
        end if;
    end process;
end Behavioral;

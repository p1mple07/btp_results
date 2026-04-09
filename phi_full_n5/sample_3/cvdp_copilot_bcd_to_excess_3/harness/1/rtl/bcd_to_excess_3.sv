library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bcd_to_excess_3 is
    Port (
        bcd : in std_logic_vector(3 downto 0);
        excess3 : out std_logic_vector(3 downto 0);
        error : out std_logic
    );
end bcd_to_excess_3;

architecture Behavioral of bcd_to_excess_3 is
begin
    process(bcd)
    begin
        case bcd is
            when "0000" =>
                excess3 <= "0110";
                error <= '0';
            when "0001" =>
                excess3 <= "0111";
                error <= '0';
            when "0010" =>
                excess3 <= "1000";
                error <= '0';
            when "0011" =>
                excess3 <= "1001";
                error <= '0';
            when "0100" =>
                excess3 <= "1010";
                error <= '0';
            when "0101" =>
                excess3 <= "1011";
                error <= '0';
            when "0110" =>
                excess3 <= "1100";
                error <= '0';
            when "0111" =>
                excess3 <= "1101";
                error <= '0';
            when "1000" =>
                excess3 <= "1110";
                error <= '0';
            when "1001" =>
                excess3 <= "1111";
                error <= '0';
            when "1010" =>
                excess3 <= "0000";
                error <= '1';
            when "1011" =>
                excess3 <= "0001";
                error <= '1';
            when "1100" =>
                excess3 <= "0010";
                error <= '1';
            when "1101" =>
                excess3 <= "0011";
                error <= '1';
            when others =>
                excess3 <= "0000";
                error <= '1';
        end case;
    end process;
end Behavioral;

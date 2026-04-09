library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dice_roller is
    Port (
        clk : in STD_LOGIC;
        reset_n : in STANDARD_LOGIC;
        button : in STD_LOGIC;
        dice_value : out STD_LOGIC_VECTOR(2 downto 0)
    );
end dice_roller;

architecture Behavioral of dice_roller is
    type state_type is (IDLE, ROLLING);
    signal state : state_type := IDLE;
    signal counter : unsigned(2 downto 0) := (others => '0');
    signal last_value : STD_LOGIC_VECTOR(2 downto 0) := ("000");
begin

    process(clk, reset_n)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                state <= IDLE;
            else
                case state is
                when IDLE =>
                    if button = '1' then
                        state <= ROLLING;
                    end if;
                when ROLLING =>
                    if button = '1' then
                        counter <= counter + 1;
                        if counter > 6 then
                            counter <= 1;
                        end if;
                    elsif button = '0' then
                        last_value <= std_logic_vector(counter);
                        state <= IDLE;
                    end if;
                end case;
                end if;
            end if;
        end if;
    end process;

    process(state)
    begin
        if state = ROLLING then
            dice_value <= std_logic_vector(unsigned(counter));
        end if;
    end process;

end architecture Behavioral;

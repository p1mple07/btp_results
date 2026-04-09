entity unpack_one_hot is
  port (
    sign    : std_logic;
    size    : std_logic;
    one_hot_selector : std_ulogic_vector(2 downto 0);
    source_reg : in  std_logic_vector(255 downto 0);
    destination_reg : out std_logic_vector(511 downto 0);
  );
end entity;

architecture Behavioral of unpack_one_hot is
  signal i : integer range 0 to 255;
begin
  for i in 0 to 255 loop
    case one_hot_selector[2] is
      when "001" =>
        if i < 256 then
          let idx := i * 8;
          let val := unsigned(source_reg(idx downto idx + 7));
          if sign = '1' then
            destination_reg(idx*8+7 downto idx*8) <= val - 128;
          else
            destination_reg(idx*8+7 downto idx*8) <= val;
          end if;
        end if;
      when "010" =>
        if i < 256 then
          let idx := i * 8;
          let val := unsigned(source_reg(idx downto idx + 7));
          if sign = '1' then
            destination_reg(idx*8+7 downto idx*8) <= val - 16;
          else
            destination_reg(idx*8+7 downto idx*8) <= val;
          end if;
        end if;
      when "100" when size = '1' =>
        if i < 256 then
          let idx := i * 8;
          let val := unsigned(source_reg(idx downto idx + 7));
          if sign = '1' then
            destination_reg(idx*8+7 downto idx*8) <= val - 128;
          else
            destination_reg(idx*8+7 downto idx*8) <= val;
          end if;
        end if;
      when "100" when size = '0' =>
        if i < 256 then
          let idx := i * 8;
          let val := unsigned(source_reg(idx downto idx + 7));
          if sign = '1' then
            destination_reg(idx*8+7 downto idx*8) <= val - 16;
          else
            destination_reg(idx*8+7 downto idx*8) <= val;
          end if;
        end if;
      when "001" and "010" =>
        if i < 256 then
          let idx := i * 8;
          let val := unsigned(source_reg(idx downto idx + 7));
          if sign = '1' then
            destination_reg(idx*8+7 downto idx*8) <= val - 128;
          else
            destination_reg(idx*8+7 downto idx*8) <= val;
          end if;
        end if;
      when default =>
        if i < 256 then
          let idx := i * 8;
          let val := unsigned(source_reg(idx downto idx + 7));
          destination_reg(idx*8+7 downto idx*8) <= val;
        end if;
    end case;
  end loop;
end architecture;

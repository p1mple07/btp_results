entity axis_upscale is
    Port (
        clk : in  std_logic;
        resetn : in  std_logic;
        dfmt_enable : in  std_logic;
        dfmt_type : in  std_logic;
        dfmt_se : in  std_logic;
        s_axis_valid : in  std_logic;
        s_axis_data : in  unsigned(23 downto 0);
        m_axis_ready : in  std_logic;

        s_axis_ready : out  std_logic;
        m_axis_valid : out  std_logic;
        m_axis_data : out  unsigned(31 downto 0)
    );
end entity;

architecture Behavioral of axis_upscale is
    signal s_ready : std_logic;
    signal m_valid : std_logic;
    signal m_data : unsigned(31 downto 0);
begin

    process(clk, resetn)
    begin
        if resetn = '1' then
            s_ready <= '0';
            m_valid <= '0';
            m_data <= (others => '0');
            wait until 'high'(clk);
            resetn <= '0';
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                s_ready <= '1';
                m_valid <= '1';
                m_data <= "0" & s_axis_data(23 downto 0);
            else
                s_ready <= '0';
                m_valid <= '1';
                m_data <= "0" & s_axis_data(23 downto 0);
            end if;
        end if;
    end process;

    m_axis_data <= m_data;
    m_axis_valid <= '1';
    m_axis_ready <= '1';

end Behavioral;

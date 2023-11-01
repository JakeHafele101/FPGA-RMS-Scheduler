-------------------------------------------------------------------------
-- Thomas Gaul
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- adder_subber.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a task state register
-- for a single task for a RMS hardware Scheduler
--
-- 
-- Created 10/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TaskStateReg is
    generic (
        INITIAL_PC : std_logic_vector(32 - 1 downto 0) := X"00000000";
        FINAL_PC   : std_logic_vector(32 - 1 downto 0) := X"00000000");
    port (
        i_CLK          : in std_logic;
        i_Asynch_RST   : in std_logic;
        i_next_PC      : in std_logic_vector(32 - 1 downto 0);
        i_next_PC_WE   : in std_logic;
        i_Period_Clear : in std_logic;
        o_current_PC   : out std_logic_vector(32 - 1 downto 0);
        o_isComplete   : out std_logic);
end TaskStateReg;

architecture mixed of TaskStateReg is
    -- Internal signals
    signal s_current_PC : std_logic_vector(32 - 1 downto 0);

begin
    process (i_CLK, i_Asynch_RST)
    begin
        if (i_Asynch_RST = '1') then
            s_current_PC <= INITIAL_PC;
        elsif (rising_edge(i_CLK)) then
            if (i_next_PC_WE = '1') then
                if (i_Period_Clear = '1') then
                    s_current_PC <= INITIAL_PC;
                else
                    s_current_PC <= i_next_PC;
                end if;
            elsif (i_Period_Clear = '1') then
                s_current_PC <= INITIAL_PC;
            end if;
        end if;
    end process;

    o_current_PC <= s_current_PC;

    process (s_current_PC)
    begin
        if (s_current_PC >= FINAL_PC) then
            o_isComplete <= '1';
        else
            o_isComplete <= '0';
        end if;
    end process;

end mixed;
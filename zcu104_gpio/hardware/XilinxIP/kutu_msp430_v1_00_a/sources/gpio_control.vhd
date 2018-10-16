--------------------------------------------------------------
--
-- (C) Copyright Kutu Pty. Ltd. 2014.
--
-- file: gpio_control.vhd
--
-- author: Greg Smart
--
--------------------------------------------------------------
--------------------------------------------------------------
--
-- This module is a simple gpio interface.
--
--------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- synopsys translate_off
library unisim;
use unisim.vcomponents.all;
-- synopsys translate_on

entity gpio_control is
   port (
      resetn               : in std_logic;
      clk                  : in std_logic;

      -- write interface from system
      sys_wraddr           : in std_logic_vector(12 downto 2);                      -- address for reads/writes
      sys_wrdata           : in std_logic_vector(31 downto 0);                      -- data/no. bytes
      sys_wr_cmd           : in std_logic;                                          -- write strobe

      sys_rdaddr           : in std_logic_vector(12 downto 2);                      -- address for reads/writes
      sys_rddata           : out std_logic_vector(31 downto 0);                     -- input data port for read operation
      sys_rd_cmd           : in std_logic;                                          -- read strobe
      sys_rd_endcmd        : out std_logic;                                         -- input read strobe

      -- output
      msp_nrst             : inout std_logic;
      msp_test             : inout std_logic
   );
end gpio_control;


architecture RTL of gpio_control is

   constant NUM_GPIO       : integer := 2;

   signal   gpio_output    : std_logic_vector(NUM_GPIO-1 downto 0);
   signal   gpio_input     : std_logic_vector(NUM_GPIO-1 downto 0);
   signal   gpio_tri       : std_logic_vector(NUM_GPIO-1 downto 0);
   signal   sys_rd_end     : std_logic;

   component IOBUF is
      port
      (
         I : in STD_LOGIC;
         O : out STD_LOGIC;
         T : in STD_LOGIC;
         IO : inout STD_LOGIC
      );
   end component;

begin

   sys_rd_endcmd  <= sys_rd_end and sys_rd_cmd;

   nrst_iobuf_0: component IOBUF
   port map
   (
      I => gpio_output(0),
      IO => msp_nrst,
      O => gpio_input(0),
      T => gpio_tri(0)
   );

   test_iobuf_0: component IOBUF
   port map
   (
      I => gpio_output(1),
      IO => msp_test,
      O => gpio_input(1),
      T => gpio_tri(1)
   );

   sys_rddata(31 downto NUM_GPIO) <= (others => '0');

   process (clk)
   begin
      if rising_edge(clk) then
         if resetn = '0' then
            sys_rddata(NUM_GPIO-1 downto 0)  <= (others => '0');
            sys_rd_end                       <= '0';
            gpio_output                      <= (others => '0');
            gpio_tri                         <= (others => '1');
         else
            if sys_wr_cmd = '1' and sys_wraddr(12 downto 4) = "000000000" then
               if sys_wraddr(3 downto 2) = "00" then
                  gpio_output <= sys_wrdata(NUM_GPIO-1 downto 0);
               elsif sys_wraddr(3 downto 2) = "01" then
                  gpio_tri    <= sys_wrdata(NUM_GPIO-1 downto 0);
               end if;
            end if;

            if sys_rdaddr(3 downto 2) = "00" then
               sys_rddata(NUM_GPIO-1 downto 0) <= gpio_input;
            elsif sys_rdaddr(3 downto 2) = "01" then
               sys_rddata(NUM_GPIO-1 downto 0) <= gpio_tri;
            else
               sys_rddata(NUM_GPIO-1 downto 0) <= gpio_output;
            end if;

            -- Control read strobe
            if sys_rd_cmd = '1' then
               sys_rd_end <= '1';
            elsif sys_rd_cmd = '0' then
               sys_rd_end <= '0';
            end if;

         end if;
      end if;
   end process;

end RTL;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package my_lib is

    function f_log2 (
        x : integer) 
    return natural;

end package;


package body my_lib is

    function f_log2 (x : integer) return natural is
        variable i : natural;
    begin
        i := 0;

        while (2**i <= x) and i < 31 loop
            i := i + 1;
        end loop;

        return i;
    end function;


end package body;
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Konstantin Kurenkov (79163962498@ya.ru)
// Create date: 28/09/2020
// Project Name:
// Module Name: UART
// Target Devices:
// Tool Versions: 
// Description:
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
/////////////////////////////////////////////////////////////////////////////////

`include "uvm_macros.svh"
`include "uart_pkg.sv"

module uart_tb_top();
  import uvm_pkg::*;
  import uart_pkg::*;

  uart_main_if uart_main_intf();

  assign uart_main_intf.uart_ag_1_intf.rx = uart_main_intf.uart_ag_2_intf.tx;
  assign uart_main_intf.uart_ag_2_intf.rx = uart_main_intf.uart_ag_1_intf.tx;

  initial
    uvm_config_db#(virtual uart_main_if)::set(uvm_root::get(), "uvm_test_top", "vif", uart_main_intf);
    

  initial begin
    run_test("uart_run_test");
  end
  
  initial begin
    $dumpvars;
    $dumpfile("dump.vcd");
  end
endmodule
`ifndef INC_UART_PKG
`define INC_UART_PKG

   `include "uart_if.sv"

package uart_pkg;
  import uvm_pkg::*;
  
  `include "uart_agent_cfg.sv"
  `include "uart_item.sv"
  `include "uart_driver.sv"
  `include "uart_monitor.sv"


  `include "uart_reg_frontdoor_seq.sv"
  `include "uart_registers.sv"

	typedef uvm_reg_predictor#(uart_item) uart_reg_predictor;
  `include "uart_reg_adapter.sv"


  typedef uvm_sequencer #(uart_item) uart_sequencer;

  `include "uart_agent.sv"
  `include "uart_env_cfg.sv"
  `include "uart_env.sv"
  `include "uart_seq_lib.sv"
  `include "uart_test.sv"
endpackage

`endif
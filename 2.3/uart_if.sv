`ifndef INC_UART_IF
`define INC_UART_IF

interface uart_if ();
  logic         rst;
  logic         rx;
  logic         tx;
endinterface

interface uart_main_if ();
  uart_if uart_ag_1_intf();
  uart_if uart_ag_2_intf();
  logic rst;

  // always_comb begin
    
  //   uart_ag_1_intf.rst = rst;
  //   uart_ag_2_intf.rst = rst;
  // end

  assign uart_ag_1_intf.rst = rst;
  assign uart_ag_2_intf.rst = rst;

endinterface

`endif
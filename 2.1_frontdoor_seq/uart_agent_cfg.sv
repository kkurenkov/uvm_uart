`ifndef INC_UART_AGENT_CFG
`define INC_UART_AGENT_CFG

class uart_agent_cfg extends uvm_object;
  `uvm_object_utils(uart_agent_cfg)

  virtual uart_if vif;

  int uart_ratio;
  bit is_active = 0;

  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------

  function new(string name ="uart_agent_cfg" );
    super.new(name);
  endfunction

  // ----------------------------------------------------------------------------
  // function set_vif
  // ----------------------------------------------------------------------------

  function void set_vif(virtual uart_if _vif);
    vif_ref_is_not_null: assert(_vif != null)
    else
      `uvm_fatal(get_full_name(), $sformatf("arg ref passed to %s via 'set_vif' is null", get_full_name()))
    vif = _vif;
  endfunction

  // ----------------------------------------------------------------------------
  // function set_uart_ratio
  // ----------------------------------------------------------------------------

  function void set_uart_ratio(int ratio = 19200);
    this.uart_ratio = ratio;

    c_uart_ratio: assert((uart_ratio == 19200) || (uart_ratio == 115200))
    else `uvm_fatal(get_full_name(), $sformatf("uart_ratio must be 19200 or 115200 bit/sec. You set uart_ratio = %0d bit/sec", ratio))

    `uvm_info(get_full_name(), $sformatf("uart ratio == %0d bit/sec", uart_ratio), UVM_MEDIUM)

  endfunction

endclass
`endif
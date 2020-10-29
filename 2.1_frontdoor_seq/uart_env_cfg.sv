`ifndef INC_UART_ENV_CFG
`define INC_UART_ENV_CFG

class uart_env_cfg extends uvm_object;

  protected int uart_ratio;
  bit is_active;
  uart_agent_cfg  uart_ag_cfg;
  bit has_uart_agent;
  uart_reg_block reg_model;

  `uvm_object_utils(uart_env_cfg)

  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------

  function new(string name = "uart_env_cfg");
    super.new(name);
  endfunction

  // ----------------------------------------------------------------------------
  // function void set_uart_ratio
  // ----------------------------------------------------------------------------

  function void set_uart_ratio(int ratio=19200);
    this.uart_ratio = ratio;

    c_uart_ratio: assert((uart_ratio == 19200 ) || (uart_ratio == 115200))
    else `uvm_fatal(get_full_name(), $sformatf("uart_ratio must be 19200 or 115200 bit/sec. You set uart_ratio = %0d bit/sec", ratio))

  endfunction

  // ----------------------------------------------------------------------------
  // function void build
  // ----------------------------------------------------------------------------

  function void build();
    uart_ag_cfg = uart_agent_cfg::type_id::create("uart_ag_cfg");
    uart_ag_cfg.set_uart_ratio(this.uart_ratio);
    uart_ag_cfg.is_active = this.is_active;

    if (reg_model == null) begin
      reg_model = uart_reg_block::type_id::create("reg_model");
      reg_model.build();
      reg_model.reset();
    end

  endfunction

  endclass

`endif
`ifndef INC_UART_ENV_CFG
`define INC_UART_ENV_CFG

class uart_env_cfg extends uvm_object;
  virtual uart_main_if vif;

  protected int uart_ratio;
  bit is_active;
  uart_agent_cfg  uart_ag_cfg_1;
  uart_agent_cfg  uart_ag_cfg_2;
  bit has_uart_agent;
  uart_reg_block reg_model_1;
  uart_reg_block reg_model_2;

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
    uart_ag_cfg_1 = uart_agent_cfg::type_id::create("uart_ag_cfg_1");
    uart_ag_cfg_1.set_uart_ratio(this.uart_ratio);
    uart_ag_cfg_1.set_vif(vif.uart_ag_1_intf);
    uart_ag_cfg_1.is_active = this.is_active;

    if (reg_model_1 == null) begin
      reg_model_1 = uart_reg_block::type_id::create("reg_model_1");
      reg_model_1.build();
      reg_model_1.reset();
    end

    uart_ag_cfg_2 = uart_agent_cfg::type_id::create("uart_ag_cfg_2");
    uart_ag_cfg_2.set_uart_ratio(this.uart_ratio);
    uart_ag_cfg_2.set_vif(vif.uart_ag_2_intf);
    uart_ag_cfg_2.is_active = this.is_active;

    if (reg_model_2 == null) begin
      reg_model_2 = uart_reg_block::type_id::create("reg_model_2");
      reg_model_2.build();
      reg_model_2.reset();
    end

  endfunction

  // ----------------------------------------------------------------------------
  // function void set_vif
  // ----------------------------------------------------------------------------

  function void set_vif(virtual uart_main_if _vif);
    if(_vif == null) `uvm_fatal(get_full_name(), $sformatf("arg ref passed to %s is null", get_full_name()))
    vif = _vif;
  endfunction

  endclass

`endif
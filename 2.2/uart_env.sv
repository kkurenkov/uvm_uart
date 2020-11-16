`ifndef INC_UART_ENV
`define INC_UART_ENV

class uart_env extends uvm_env;
  uart_env_cfg cfg;
  uart_agent agent_1;
  uart_agent agent_2;

  `uvm_component_utils(uart_env)

  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------

  function new(string name = "uart_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // ----------------------------------------------------------------------------
  // function void build_phase
  // ----------------------------------------------------------------------------

  function void build_phase(uvm_phase phase);
    cfg_is_not_null: assert(uvm_config_db#(uart_env_cfg)::get(this, "", "cfg", cfg))
    else `uvm_fatal(get_full_name(), $sformatf("cfg is null: %s.cfg", get_full_name()))

    agent_1 = uart_agent::type_id::create("agent_1", this);
    agent_1.set_cfg(cfg.uart_ag_cfg_1);

    agent_2 = uart_agent::type_id::create("agent_2", this);
    agent_2.set_cfg(cfg.uart_ag_cfg_2);
  endfunction

  function void connect_phase(uvm_phase phase);
  endfunction

endclass

`endif

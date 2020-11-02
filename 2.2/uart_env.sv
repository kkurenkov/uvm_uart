`ifndef INC_UART_ENV
`define INC_UART_ENV

class uart_env extends uvm_env;
  uart_env_cfg cfg;
  uart_agent agent_1;
  uart_agent agent_2;
  uart_reg_adapter reg_adapter_1;
  uart_reg_adapter reg_adapter_2;
  uart_reg_predictor reg_predictor_1;
  uart_reg_predictor reg_predictor_2;

  high_reg_uart_layering reg_uart_layering_1;
  high_reg_uart_layering reg_uart_layering_2;
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
    reg_predictor_1 = uart_reg_predictor::type_id::create(.name("reg_predictor_1"), .parent(this));
    reg_adapter_1 = uart_reg_adapter::type_id::create(.name("reg_adapter_1")); 
    reg_uart_layering_1 = high_reg_uart_layering::type_id::create("reg_uart_layering_1", .parent(this));



    agent_2 = uart_agent::type_id::create("agent_2", this);
    agent_2.set_cfg(cfg.uart_ag_cfg_2);
    reg_predictor_2 = uart_reg_predictor::type_id::create(.name("reg_predictor_2"), .parent(this));
    reg_adapter_2 = uart_reg_adapter::type_id::create(.name("reg_adapter_2")); 
    reg_uart_layering_2 = high_reg_uart_layering::type_id::create("reg_uart_layering_2", .parent(this));
  endfunction

  function void connect_phase(uvm_phase phase);
    cfg.reg_model_1.map.set_sequencer( .sequencer(reg_uart_layering_1.high_reg_sequencer), .adapter( reg_adapter_1 ) );
    reg_predictor_1.map = cfg.reg_model_1.default_map;
    reg_predictor_1.adapter = reg_adapter_1;
    reg_uart_layering_1.uart_2_high_reg_mon.item_collected_port.connect(reg_predictor_1.bus_in);
    reg_uart_layering_1.uart_connect_to_agent(agent_1);

    cfg.reg_model_2.map.set_sequencer( .sequencer(reg_uart_layering_2.high_reg_sequencer), .adapter( reg_adapter_2 ) );
    reg_predictor_2.map = cfg.reg_model_2.default_map;
    reg_predictor_2.adapter = reg_adapter_2;
    reg_uart_layering_2.uart_2_high_reg_mon.item_collected_port.connect(reg_predictor_2.bus_in);
    reg_uart_layering_2.uart_connect_to_agent(agent_2);
  endfunction

endclass

`endif

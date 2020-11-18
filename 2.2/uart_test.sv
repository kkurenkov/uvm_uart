
`ifndef INC_UART_TEST
`define INC_UART_TEST

class uart_base_test extends uvm_test;
   uart_env_cfg env_cfg;
   uart_env env;
   uvm_status_e   status;
   uvm_reg_data_t  value;
  `uvm_component_utils(uart_base_test)

  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------
  
  function new(string name = "uart_base_test", uvm_component parent = null);
    super.new(name,parent);
  endfunction

  // ----------------------------------------------------------------------------
  // function void build_phase
  // ----------------------------------------------------------------------------
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    env = uart_env::type_id::create("env", this);
    env_cfg = uart_env_cfg::type_id::create("env_cfg");

    env_cfg.is_active = 1;
    env_cfg.set_uart_ratio(19200); // 19200 bit/sec;
    // env_cfg.set_uart_ratio(115200); // 19200 bit/sec;

    uvm_config_db#(uart_env_cfg)::set(this, "env", "cfg", env_cfg);

    // Get virtual interface from tb_top
    if (!uvm_config_db #(virtual uart_main_if)::get(this, "", "vif", env_cfg.vif))
        `uvm_fatal(get_type_name(), $sformatf("[cfg] Did not find uart_if in config_db"))

    env_cfg.build();

  endfunction

  // ----------------------------------------------------------------------------
  // virtual task  main_phase
  // ----------------------------------------------------------------------------
  
  task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask

  // ----------------------------------------------------------------------------
  // function void end_of_elaboration_phase
  // ----------------------------------------------------------------------------
  
  function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Hierarchy of the test environment: \n%s", this.sprint()), UVM_MEDIUM)
  endfunction

endclass

class uart_run_test extends uart_base_test;
  uart_high_seq seq_high_ag1; 
  uart_high_seq seq_high_ag2; 
  
  `uvm_component_utils(uart_run_test)

  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------

  function new(string name = "uart_run_test", uvm_component parent = null);
    super.new(name,parent);
  endfunction

  // ----------------------------------------------------------------------------
  // function void build_phase
  // ----------------------------------------------------------------------------

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    seq_high_ag1 = uart_high_seq::type_id::create("seq_high_ag1");
    seq_high_ag2 = uart_high_seq::type_id::create("seq_high_ag2");
    seq_high_ag1.number_transaction=3;
    seq_high_ag2.number_transaction=3;
  endfunction


  // ----------------------------------------------------------------------------
  // virtual task  main_phase
  // ----------------------------------------------------------------------------
  
  task main_phase(uvm_phase phase);
    uvm_status_e      status;
    int data_for_write_1;
    int data_for_write_2;
    super.main_phase(phase);
    
    phase.raise_objection(this);

    #100;
    env.cfg.vif.rst = 0;
    #100
    env.cfg.vif.rst = 1;
    #100
    env.cfg.vif.rst = 0;
    #100;

  fork
    seq_high_ag1.start(env.high_agent_1.high_reg_sequencer);
    seq_high_ag2.start(env.high_agent_2.high_reg_sequencer);
  join

  #1000;
    phase.drop_objection(this);
  endtask

  // ----------------------------------------------------------------------------
  // function void end_of_elaboration_phase
  // ----------------------------------------------------------------------------
  
  function void end_of_elaboration_phase(uvm_phase phase);
    if ($test$plusargs("print_env_hier"))
      `uvm_info(get_type_name(), $sformatf("Hierarchy of the test environment: \n%s", this.sprint()), UVM_MEDIUM)
  endfunction

endclass
`endif
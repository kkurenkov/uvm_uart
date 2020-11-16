
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
  uart_reg_block    ral_model_1;
  uart_reg_block    ral_model_2;
  
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
  endfunction


  // ----------------------------------------------------------------------------
  // virtual task  main_phase
  // ----------------------------------------------------------------------------
  
  task main_phase(uvm_phase phase);
    uvm_status_e      status;
    int data_for_write_1;
    int data_for_write_2;
    super.main_phase(phase);
    
    ral_model_1 = uart_reg_block::type_id::create("ral_model_1");
    ral_model_1 = env_cfg.reg_model_1;

    ral_model_2 = uart_reg_block::type_id::create("ral_model_2");
    ral_model_2 = env_cfg.reg_model_2;
    phase.raise_objection(this);

    #100;
    env.cfg.vif.rst = 0;
    #100
    env.cfg.vif.rst = 1;
    #100
    env.cfg.vif.rst = 0;

    #100;

    repeat(3) begin
      data_for_write_1 = $urandom()&'hFF;
      data_for_write_2 = $urandom()&'hFF;
      fork
        ral_model_1.r1.write (status,data_for_write_1);
        ral_model_2.r1.write (status,data_for_write_2);
      join
      // #200;
      //   ral_model_1.r1.write (status,$urandom()&'hFF);
      // #200;
        
      //   ral_model_1.r1.write (status,$urandom()&'hFF);

    #100;
      `uvm_info(get_name(), $sformatf("agent_1 tx -> == %0h ral_model_2.r1.get_mirrored_value(): %0h", data_for_write_1, ral_model_2.r1.get_mirrored_value()), UVM_MEDIUM);
      `uvm_info(get_name(), $sformatf("agent_2 tx -> == %0h ral_model_1.r1.get_mirrored_value(): %0h", data_for_write_2, ral_model_1.r1.get_mirrored_value()), UVM_MEDIUM);

    end
    #100;

    // `uvm_info(get_name(), $sformatf("data_for_write_r2 == %0h ral_model.r2.get_mirrored_value(): %0h", data_for_write_r2, ral_model.r2.get_mirrored_value()), UVM_MEDIUM);
    // `uvm_info(get_name(), $sformatf("data_for_write_r1 == %0h ral_model.r1.get_mirrored_value(): %0h", data_for_write_r1, ral_model.r1.get_mirrored_value()), UVM_MEDIUM);

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
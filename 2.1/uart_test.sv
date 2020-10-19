
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
    // env_cfg.uart_ratio = 115200; // 115200 bit/sec;
    env_cfg.build();

    // Get virtual interface from tb_top
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "vif", env_cfg.uart_ag_cfg.vif))
        `uvm_fatal(get_type_name(), $sformatf("[cfg] Did not find uart_if in config_db"))

    uvm_config_db#(uart_env_cfg)::set(this, "env", "cfg", env_cfg);
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

endclass // uart_base_test

class uart_run_test extends uart_base_test;
  uart_reg_block    ral_model;
  
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
    uart_reg_block    ral_model;
    uvm_status_e      status;
    byte data_for_write_r2;
    byte data_for_write_r1;
    super.main_phase(phase);

    
    ral_model = uart_reg_block::type_id::create("ral_model");
    ral_model = env_cfg.reg_model;
    phase.raise_objection(this);
        #100;
        env.cfg.uart_ag_cfg.vif.rst = 0;
        #100
        env.cfg.uart_ag_cfg.vif.rst = 1;
        #100
        env.cfg.uart_ag_cfg.vif.rst = 0;

         
        // repeat(4) begin

         data_for_write_r1 = $urandom();
         ral_model.r1.write (status, data_for_write_r1);
         
         #100;
         `uvm_info(get_name(), $sformatf("data_for_write_r1 == %0h ral_model.r1.get_mirrored_value(): %0h", data_for_write_r1, ral_model.r1.get_mirrored_value()), UVM_MEDIUM);

         assert_eq_data_and_reg1_mirrored_value: assert (data_for_write_r1 == ral_model.r1.get_mirrored_value())
         else 
        `uvm_fatal(get_name(), $sformatf("data_for_write_r1 %0h  != ral_model.r1.get_mirrored_value() %0h", data_for_write_r1, ral_model.r1.get_mirrored_value()));

         data_for_write_r2 = $urandom();
         ral_model.r2.write (status, data_for_write_r2);

         #100;
         assert_eq_data_and_reg2_mirrored_value: assert (data_for_write_r2 == ral_model.r2.get_mirrored_value())
         else 
        `uvm_fatal(get_name(), $sformatf("data_for_write_r2 %0h != ral_model.r2.get_mirrored_value() %0h", data_for_write_r2, ral_model.r2.get_mirrored_value()));
       


        `uvm_info(get_name(), $sformatf("data_for_write_r2 == %0h ral_model.r2.get_mirrored_value(): %0h", data_for_write_r2, ral_model.r2.get_mirrored_value()), UVM_MEDIUM);
        `uvm_info(get_name(), $sformatf("data_for_write_r1 == %0h ral_model.r1.get_mirrored_value(): %0h", data_for_write_r1, ral_model.r1.get_mirrored_value()), UVM_MEDIUM);

        // end

    phase.drop_objection(this);
  endtask

// ----------------------------------------------------------------------------
// function void end_of_elaboration_phase
// ----------------------------------------------------------------------------
function void end_of_elaboration_phase(uvm_phase phase);
  if ($test$plusargs("print_env_hier"))
    `uvm_info(get_type_name(), $sformatf("Hierarchy of the test environment: \n%s", this.sprint()), UVM_MEDIUM)
endfunction

endclass // uart_run_test
`endif
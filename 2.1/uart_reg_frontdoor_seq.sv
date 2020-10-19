`ifndef INC_REG_FRONTDOOR_SEQ
`define INC_REG_FRONTDOOR_SEQ



// ----------------------------------------------------------------------------
// class uart_reg_frontdoor_seq
// ----------------------------------------------------------------------------

class uart_reg_frontdoor_seq extends uvm_reg_frontdoor;
  `uvm_object_utils(uart_reg_frontdoor_seq)

// ----------------------------------------------------------------------------
// function new
// ----------------------------------------------------------------------------
  function new(string name ="uart_reg_frontdoor_seq");
    super.new(name);
  endfunction

// ----------------------------------------------------------------------------
// task pre_body
// ----------------------------------------------------------------------------
task pre_body();
  uvm_phase phase;

  `ifdef UVM_1_2
    phase = get_starting_phase();
  `else
    phase = starting_phase;
  `endif

  if(phase != null)
    phase.raise_objection(this, {"Running sequence '", get_full_name(), "'"});
endtask

// ----------------------------------------------------------------------------
// task post_body
// ----------------------------------------------------------------------------
task post_body();
  uvm_phase phase;

  `ifdef UVM_1_2
    phase = get_starting_phase();
  `else
    phase = starting_phase;
  `endif

  if(phase != null)
    phase.drop_objection(this);
endtask

// ----------------------------------------------------------------------------
// task body
// ----------------------------------------------------------------------------
  task body();
    uvm_reg the_reg;
    bit            cmd;
    uart_item req;
    uart_item rsp;
    uvm_reg_addr_t addr;
    uvm_reg_data_t data;
    uvm_sequence_item item;
    bit parity_bit;

    $cast(the_reg, rw_info.element);  
    cmd  = (rw_info.kind == UVM_WRITE);
    addr = the_reg.get_offset();
    data = rw_info.value[0];
    
    case (rw_info.kind )
        UVM_WRITE: begin
                parity_bit = ^cmd;
            `uvm_create(req)
                  rand_RX_TX: assert(req.randomize()
                     with {
                      req.start_bit==0;
                      req.data == cmd;
                      req.parity_bit == parity_bit;
                      req.end_bit==1;
                    })
                    else
                      `uvm_fatal(get_full_name(), "Randomization failed!")
               `uvm_send(req)

                parity_bit = ^the_reg.get_offset();
            `uvm_create(req)
                  rand_data: assert(req.randomize()
                     with {
                      req.start_bit==0;
                      req.data==the_reg.get_offset();
                      req.parity_bit == parity_bit;
                      req.end_bit==1;
                    })
                    else
                      `uvm_fatal(get_full_name(), "Randomization failed!")
               `uvm_send(req)

                parity_bit = ^rw_info.value[0];
              `uvm_create(req)
                  rand_addr: assert(req.randomize()
                     with {
                      req.start_bit==0;
                      req.data==rw_info.value[0];
                      req.parity_bit == parity_bit;
                      req.end_bit==1;
                    })
                    else
                      `uvm_fatal(get_full_name(), "Randomization failed!")
               `uvm_send(req)
        end
    endcase

  endtask
endclass // uart_reg_frontdoor_seq

`endif
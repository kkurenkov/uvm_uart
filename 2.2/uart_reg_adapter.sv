`ifndef INC_UART_REG_ADAPTER
`define INC_UART_REG_ADAPTER

typedef uvm_reg_predictor#(high_reg_item) uart_reg_predictor;

class uart_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(uart_reg_adapter)
  int tx_addr;
  int tx_data;

  bit second_step = 0 ;
  bit first_step = 0;

  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------

  function new(string name = "uart_reg_adapter");
    super.new(name);
  endfunction

  // ----------------------------------------------------------------------------
  // function reg2bus
  // ----------------------------------------------------------------------------

  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    high_reg_item bus_item;
    bus_item = high_reg_item::type_id::create("bus_item");
    bus_item.kind = rw.kind;
    bus_item.addr = rw.addr;
    bus_item.data = rw.data;

    return bus_item;
  endfunction

  // ----------------------------------------------------------------------------
  // function bus2reg
  // ----------------------------------------------------------------------------

  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    high_reg_item uart_item_reg;

    if(!$cast(uart_item_reg, bus_item))
    `uvm_fatal(get_name(), "$cast is failed")

    rw.addr = uart_item_reg.addr;
    rw.kind = (uart_item_reg.kind) ? UVM_WRITE : UVM_READ;
    rw.data = uart_item_reg.data;
    rw.status = UVM_IS_OK;

  endfunction

endclass

`endif
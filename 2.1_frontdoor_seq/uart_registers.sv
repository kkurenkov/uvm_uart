`ifndef INC_UART_REG
`define INC_UART_REG

class r1_reg extends uvm_reg; 
  `uvm_object_utils(r1_reg)

  rand uvm_reg_field r1_f;

  function new( string name = "r1_reg" );
      super.new( .name( name ), .n_bits( 8 ), .has_coverage( UVM_NO_COVERAGE ) );
  endfunction

  function void build();
    r1_f = uvm_reg_field::type_id::create("r1_f");
    r1_f.configure( .parent                  ( this ),
                    .size                    ( 8    ),
                    .lsb_pos                 ( 0    ),
                    .access                  ( "RW" ),
                    .volatile                ( 0    ),
                    .reset                   ( 8'h00),
                    .has_reset               ( 1    ),
                    .is_rand                 ( 1    ),
                    .individually_accessible ( 0    ) );
  endfunction
endclass

class r2_reg extends uvm_reg; 
  `uvm_object_utils(r2_reg)

  rand uvm_reg_field r2_f;

  function new( string name = "r2_reg" );
      super.new( .name( name ), .n_bits( 8 ), .has_coverage( UVM_NO_COVERAGE ) );
  endfunction

  function void build();
    r2_f = uvm_reg_field::type_id::create("r2_f");
    r2_f.configure( .parent                  ( this ),
                    .size                    ( 8    ),
                    .lsb_pos                 ( 0    ),
                    .access                  ( "RO" ),
                    .volatile                ( 0    ),
                    .reset                   ( 8'h00),
                    .has_reset               ( 1    ),
                    .is_rand                 ( 1    ),
                    .individually_accessible ( 0    ) );
  endfunction
endclass


class uart_reg_block extends uvm_reg_block;
  bit use_default_frontdoor = 0;
  bit use_default_map = 1;

  uart_reg_frontdoor_seq seq_for_reg; 
  rand r1_reg            r1;
  rand r2_reg            r2;
  uvm_reg_map            map;

  `uvm_object_utils( uart_reg_block )

  // ----------------------------------------------------------------------------
  // function new
  // ----------------------------------------------------------------------------

  function new(string name = "uart_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  // ----------------------------------------------------------------------------
  // function build
  // ----------------------------------------------------------------------------

  function void build();
    seq_for_reg = uart_reg_frontdoor_seq::type_id::create("seq_for_reg");

    r1 = r1_reg::type_id::create("r1");
    r1.configure(this);
    r1.build();

    r2 = r2_reg::type_id::create("r2");
    r2.configure(this);
    r2.build();

    map = create_map("map", 0, 1, UVM_LITTLE_ENDIAN);
    mapping_regs(map, 'h0, use_default_frontdoor);

    lock_model();
  endfunction

  function void mapping_regs(uvm_reg_map map_, uvm_reg_addr_t offset, bit use_default_frontdoor_);
    if(map_ == null) `uvm_fatal(get_full_name(), "map is null!")

      map.add_reg(r1 , 'h0, "RW", 0, seq_for_reg); // reg, offset, access, unmapped, frontdoor
      map.add_reg(r2 , 'h1, "RO", 0, seq_for_reg);
  endfunction

endclass

`endif
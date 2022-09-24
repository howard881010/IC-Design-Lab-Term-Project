set TOP_DIR $TOPLEVEL
set RPT_DIR report
set NET_DIR netlist

sh rm -rf ./$TOP_DIR
sh rm -rf ./$RPT_DIR
sh rm -rf ./$NET_DIR
sh mkdir ./$TOP_DIR
sh mkdir ./$RPT_DIR
sh mkdir ./$NET_DIR

# define a lib path here
define_design_lib $TOPLEVEL -path ./$TOPLEVEL

# Read Design File (add your files here)
set HDL_DIR "../hdl"

analyze -library $TOPLEVEL -format verilog "$HDL_DIR/top_pipe.v \
                                            $HDL_DIR/add_v2.v \
                                            $HDL_DIR/comp.v \
                                            $HDL_DIR/cordic.v \
                                            $HDL_DIR/mul_mantissa.v \
                                            $HDL_DIR/mul.v \
                                            $HDL_DIR/div_mantissa.v \
                                            $HDL_DIR/div.v \
                                            $HDL_DIR/value_correct.v \
                                           "

# elaborate your design
elaborate $TOPLEVEL -architecture verilog -library $TOPLEVEL

# Solve Multiple Instance
set uniquify_naming_style "%s_mydesign_%d"
uniquify

# link the design
current_design $TOPLEVEL
link

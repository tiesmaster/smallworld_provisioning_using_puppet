#!/bin/bash

export LD_LIBRARY_PATH=$SMALLWORLD_GIS/3rd_party_libs/Linux.x86/lib

sw_magik_motif -image $SMALLWORLD_GIS/images/swaf.msf <<EOF
_block
  sw_module_dialog.open()
  _thisthread.sleep(500)
_endblock
$
EOF

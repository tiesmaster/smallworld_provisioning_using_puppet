#!/bin/bash

sw_magik_motif -image $SMALLWORLD_GIS/images/swaf.msf <<EOF
_block
  sw_module_dialog.open()
  _thisthread.sleep(500)
_endblock
$
EOF

(load "load_sw_defs")            ; Smallworld extra functionality.
(load "sw_defaults")             ; Some default customisations.
(electric-magik-mode)
(push "gis -i -a ${SMALLWORLD_GIS}/config/gis_aliases swaf"  gis-command-history)

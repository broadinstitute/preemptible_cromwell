# cromwell_preemptible

simple WDL script to demonstrate the use with preemptible machines

Run locally by typing:

> Cromwell run preemptible_counting.wdl -i parameters.json 

Run on the cloud by typing:

> cromshell submit preemptible_counting.wdl parameters.json 

THE CURRENT IMPLEMENTATION HAS BEEN TESTED WITH BOTH cromwell_server_47 and cromwell_server_51

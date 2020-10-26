# cromwell_preemptible

Simple WDL script to demonstrate the use with preemptible machines. \
The strategy is to periodically create ckpt files which are then copied to a remote bucket. \
If pre-emption occurs the remote ckpt is copied back to the new VM and execution resumes from where it was left off.

This strategy is summarized in the figure below:
![strategy.png](https://github.com/dalessioluca/preemptible_cromwell/blob/master/images/strategy.png?raw=true)

It is based on 4 functions:
1. create_local_ckpt
2. load_local_ckpt
3. local_to_remote_ckpt (which runs periodically and copy to remote bucket only if the local ckpt has changed)
4. remote_to_local_ckpt (which runs only once when VM starts)

The first two functions are task specific and the end-users need to write them explicitely in the task section of the WDL. \
The last two functions are completely generic and will be taken care automatically.

You need to:
1. make sure your docker image contain gsutil which are used to copy the files back and fort 
2. place the cromwell_monitor_ckpt_script.sh in google cloud storage and invoke it by adding 
   the following line to your cromwell workflow 
   options:
   "monitoring_script": "gs://bucket/path/to/cromwell_monitoring_script.sh"

To run the example type:

> cromshell submit preemptible_counting.wdl parameters.json option.json 

The two version of the ckpt script (cromwell_monitoring_script.sh, cromwell_monitoring_script2.sh) are based off the two corresponding version of the monitoring script. Use either one of them.

THE CURRENT IMPLEMENTATION HAS BEEN TESTED WITH BOTH cromwell_server_47 and cromwell_server_51

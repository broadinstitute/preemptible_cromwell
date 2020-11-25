version 1.0

task preemptible_couting {
    input {
        Int ckpt_frequency
    }

    command <<<

        # First thing is to select the name of the local_ckpt you want to use
        LOCAL_CKPT_FILE="ckpt.tar.gz"

        # Do not touch this block which is used for synchronization with the checkpoint script
        echo $LOCAL_CKPT_FILE > dummy_file.tmp
        iter=0
        while [ -f ./dummy_file.tmp -a "$iter" -lt 100 ]
        do
           sleep 2
           iter=$((iter+1))
        done


        # Load ckpt or start from scratch
        if [ -f "$LOCAL_CKPT_FILE" ]; then
           echo "initialize from local ckpt"
           # insert here your "load_local_ckpt" function
           n=$(cat $LOCAL_CKPT_FILE)
        else
           echo "initialize from scrath"
           # insert here your "start_from_scratch" function 
           n=0
        fi


        # Loop that simulate the real work and create a local ckpt
        while ((n < 100 )); do
          echo $n
          if [ $((n % ~{ckpt_frequency} )) -eq 0 ]; then
             # insert here your "save_local_ckpt" function
             echo $n > $LOCAL_CKPT_FILE
          fi
          sleep 2
          n=$((n+1))
        done

    >>>

    runtime {
        docker: "google/cloud-sdk"
        cpu: 1
        preemptible: 3
    }

    output {
        File std_out = stdout()
    }
}

workflow preemptible {

    input {
        Int ckpt_frequency
    }
    
    call preemptible_couting {
        input :
            ckpt_frequency = ckpt_frequency
    }

}


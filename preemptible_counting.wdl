version 1.0

task preemptible_couting {
    input {
        Int ckpt_frequency
    }

    command <<<
        
        # Trick to wait till startup script finishes execution
        TMP_FILE=./dummy_file.tmp  # do not change this name. Startup script depends on it 
        LOCAL_CKPT_FILE=./ckpt     # do not change this name. Startup script depends on it
        while [ ! -f "$TMP_FILE" ]  
        do
           sleep 2
        done

        # Load ckpt or start from scratch
        if [ -f "$LOCAL_CKPT_FILE" ]; then
           echo "initialize from local ckpt"
           # insert here your load from ckpt function
           n=$(cat $LOCAL_CKPT_FILE)
        else
           echo "initialize from scrath"
           # insert here your start from scratch function 
           n=0
        fi


        # Loop that simulate the real work and create a local ckpt
        while ((n < 100 )); do
          echo $n
          if [ $((n % ~{ckpt_frequency} )) -eq 0 ]; then
             # insert here your function which creates the local ckpt file
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


version 1.0

task preemptible_couting {
    input {
        Int ckpt_frequency
        File start_script
    }

    command <<<

        # Prepare the local and remote ckpt directory
        chmod +x ~{start_script}
        ./~{start_script}
        if [ $? == 0 ]; then 
           echo "initialize from local ckpt"
           n=$(cat ./ckpt)
        else
           echo "initialize from scrath"
           n=0
        fi

        # Loop that simulate the real work and create a local ckpt 
        while ((n < 100 )); do
          echo $n
          if [ $((n % ~{ckpt_frequency} )) -eq 0 ]; then
             echo $n > ./ckpt
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
        File start_script
    }
    
    call preemptible_couting {
        input :
            start_script = start_script,
            ckpt_frequency = ckpt_frequency
    }

}


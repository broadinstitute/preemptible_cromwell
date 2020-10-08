version 1.0

task preemptible_couting {
    input {
        Int ckpt_frequency
    }

    command <<<

        # Prepare the local and remote ckpt directory
        
        mkdir -p local_ckpt_dir
        local_ckpt_file=./local_ckpt_dir/ckpt
        remote_ckpt_dir=$(cat gcs_delocalization.sh | grep -o 'gs:\/\/.*stdout"' | grep -o 'gs:\/\/.*\/call[^\/]*')
        remote_ckpt_file=$remote_ckpt_dir/ckpt
        echo $local_ckpt_file
        echo $remote_ckpt_file

        # At the beginning copy from remote to local (if exists)
        export GCS_OAUTH_TOKEN='gcloud auth application-default print-access-token'
        return_code=$(gsutil -q stat $remote_ckpt_file; echo $?)  # 0=exist, 1=does not exists
        if [ $return_code == '0' ]; then
            echo "remote_ckpt EXISTS"
            gsutil cp $remote_ckpt_file $local_ckpt_file
            n=$(cat $local_ckpt_file)
        else
            echo "remote_ckpt DOES NOT EXIST"
            n=0
        fi

        # Loop that simulat the real work and the copying from local to remote
        while ((n < 100 )); do
          echo $n
          if [ $((n % ~{ckpt_frequency} )) -eq 0 ]; then
             echo $n > $local_ckpt_file
             gsutil -m cp $local_ckpt_file $remote_ckpt_file
          fi
          sleep 6
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


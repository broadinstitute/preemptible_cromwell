version 1.0

task preemptible_couting {
    input {
        String remote_ckpt_location
    }

    command <<<

        # Prepare the local ckpt directory
        random=$(cat script | grep mkfifo | grep -o '[a-z0-9]*\"$' | sed 's/"$//' | sed 's/err//')
        echo $random
        mkdir -p local_ckpt_dir
        local_ckpt_file=./local_ckpt_dir/$random.ckpt
        remote_ckpt_file=~{remote_ckpt_location}/$random.ckpt
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
          echo $n > $local_ckpt_file
          gsutil -m cp $local_ckpt_file $remote_ckpt_file
          sleep 5
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
        String remote_ckpt_location
    }
    
    call preemptible_couting {
        input :
            remote_ckpt_location = remote_ckpt_location 
    }

}


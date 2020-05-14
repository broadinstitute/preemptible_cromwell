version 1.0

task generate_hash {
    input {
        File input_json
    }

    command <<<
        python <<CODE
        import uuid
        hash_str = uuid.uuid4().hex
        print(hash_str)
        CODE
    >>>

    runtime {
        docker: "python"
        cpu: 1
        preemptible: 3
    }

    output {
        String hash = stdout()
    }
}

task preemptible_couting {
    input {
        String random_hash
    }

    command <<<

        #----------------------------------------
        # Localization from bucket to local dir.
        # Ideally cromwell will handle this for us.
        #------------------------------------------

        # Prepare the local ckpt directory
        mkdir -p local_ckpt_dir
        local_ckpt_file=./local_ckpt_dir/~{random_hash}_ckpt.json
        remote_ckpt_file=gs://ld-tmp-storage/Cromwell_CKPT/~{random_hash}_ckpt.json
        # echo $local_ckpt_file
        # echo $remote_ckpt_file

        # At the beginning copy from remote to local
        return_code=$(gsutil -q stat  $remote_ckpt_file; echo $?)  # 1=exist, 0=does not exists
        echo "return_code ->" $return_code
        if [ $return_code == '1' ]; then
            echo "remote_exists"
            gsutil cp $remote_ckpt_file $local_ckpt_file
        fi
        #-------------------------------


        #---------------------------------------
        # This pythion script simulates the actual task which takes time to complete
        #---------------------------------------

        python <<CODE
        import json
        import time
        import os.path

        # Reload the local_ckpt if exist
        if os.path.exists("$local_ckpt_file"):
            with open("$local_ckpt_file", 'rb') as f:
                ckpt = json.load(f)
            n_last = ckpt["n_last"]
        else:
            n_last = -1
        print("n_last",n_last)

        # run task and save ckpt both locally and remotely
        for n in range(n_last+1,10):
            print("in loop",n)
            ckpt = {"n_last" : n}
            with open("$local_ckpt_file", 'w') as f:
                json.dump(ckpt, f)
            # gsutil cp $local_ckpt_file $remote_ckpt_file  # this line should go into shut-down script
            time.sleep(10)
        CODE

    >>>

    runtime {
        docker: "google/cloud-sdk"
        cpu: 1
        preemptible: 0
        maxRetries: 0
        preemptible_tries: 0
        bootDiskSizeGb: 10
        memory: "2G"
    }

    output {
        File std_out = stdout()
    }
}

workflow preemptible {

    input {
        String random_hash
    }
    call preemptible_couting {
        input :
            random_hash = random_hash
    }

    #input {
    #    File parameters_json
    #}
    #call generate_hash {
    #    input :
    #        input_json = parameters_json
    #}
    #call preemptible_couting {
    #    input :
    #        random_hash = generate_hash.hash
    #}

}


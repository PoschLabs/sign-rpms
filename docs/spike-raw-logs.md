
# Step 1
## In spike-caller, add .github/workflows/call.yml (on workflow_dispatch) calling PoschLabs/spike-signer/.github/workflows/sign.yml@v0.0.1. Run it.
Works and is running

## In spike-caller, add .github/workflows/plain.yml with a plain job using runs-on: { group: spike-signing, labels: [rpm-signer] }. Run it.

Never gets executed, is waiting for an agent.

## Try wildcard patterns, one at a time, re-running call.yml after each, and record which are accepted by the API and which actually match:
* `...sign.yml@refs/tags/v*`: Error: Specified ref, tag, or SHA "refs/tags/v*" was not found for workflow "PoschLabs/spike-signer/.github/workflows/sign.yml@refs/tags/v*".
* `...sign.yml@refs/tags/*`: Error: Specified ref, tag, or SHA "refs/tags/*" was not found for workflow "PoschLabs/spike-signer/.github/workflows/sign.yml@refs/tags/*".
* `...sign.yml (no ref)`: Workflow "PoschLabs/spike-signer/.github/workflows/sign.yml" must be pinned to a ref, tag, or full SHA.

# Step 2

## spike caller
2026-11-03T20:47:52.8562359Z Current runner version: '2.338.2'
2026-11-03T20:47:52.8578681Z Runner name: 'lysithea'
2026-11-03T20:47:52.8580779Z Runner group name: 'spike-signing'
2026-11-03T20:47:52.8582873Z Machine name: 'lysithea'
2026-11-03T20:47:52.8591475Z ##[group]GITHUB_TOKEN Permissions
2026-11-03T20:47:52.8596595Z Metadata: read
2026-11-03T20:47:52.8598399Z ##[endgroup]
2026-11-03T20:47:52.8603617Z Secret source: Actions
2026-11-03T20:47:52.8606147Z Cache mode: write
2026-11-03T20:47:52.8608688Z Prepare workflow directory
2026-11-03T20:47:52.9431262Z Prepare all required actions
2026-11-03T20:47:53.0092365Z Uses: PoschLabs/spike-signer/.github/workflows/sign.yml@refs/tags/v0.0.1 (39c629d1bb31711199aa9b2a1ad8185d578300ab)
2026-11-03T20:47:53.0104352Z Complete job name: sign / sign
2026-11-03T20:47:53.3512313Z ##[group]Run echo "PROBE=caller-env"
2026-11-03T20:47:53.3513432Z [36;1mecho "PROBE=caller-env"[0m
2026-11-03T20:47:53.3585897Z shell: /usr/bin/bash -e {0}
2026-11-03T20:47:53.3587385Z ##[endgroup]
2026-11-03T20:47:53.3998370Z PROBE=caller-env
2026-11-03T20:47:53.4491345Z Cleaning up orphan processes

## spike other
2026-11-03T20:53:19.4971549Z Current runner version: '2.338.2'
2026-11-03T20:53:19.4994870Z Runner name: 'lysithea'
2026-11-03T20:53:19.4997759Z Runner group name: 'spike-signing'
2026-11-03T20:53:19.5001730Z Machine name: 'lysithea'
2026-11-03T20:53:19.5012428Z ##[group]GITHUB_TOKEN Permissions
2026-11-03T20:53:19.5020144Z Metadata: read
2026-11-03T20:53:19.5023017Z ##[endgroup]
2026-11-03T20:53:19.5030235Z Secret source: Actions
2026-11-03T20:53:19.5034145Z Cache mode: write
2026-11-03T20:53:19.5036925Z Prepare workflow directory
2026-11-03T20:53:19.6202736Z Prepare all required actions
2026-11-03T20:53:19.7147912Z Uses: PoschLabs/spike-signer/.github/workflows/sign.yml@refs/tags/v0.0.1 (39c629d1bb31711199aa9b2a1ad8185d578300ab)
2026-11-03T20:53:19.7169633Z Complete job name: sign / sign
2026-11-03T20:53:20.1414813Z ##[group]Run echo "PROBE="
2026-11-03T20:53:20.1416098Z [36;1mecho "PROBE="[0m
2026-11-03T20:53:20.1507671Z shell: /usr/bin/bash -e {0}
2026-11-03T20:53:20.1509844Z ##[endgroup]
2026-11-03T20:53:20.1965261Z PROBE=
2026-11-03T20:53:20.2407777Z Cleaning up orphan processes

# Step 3
2026-11-03T21:11:01.9607064Z Current runner version: '2.338.2'
2026-11-03T21:11:01.9621416Z Runner name: 'lysithea'
2026-11-03T21:11:01.9623476Z Runner group name: 'spike-signing'
2026-11-03T21:11:01.9625487Z Machine name: 'lysithea'
2026-11-03T21:11:01.9632206Z ##[group]GITHUB_TOKEN Permissions
2026-11-03T21:11:01.9636871Z Contents: read
2026-11-03T21:11:01.9638796Z Metadata: read
2026-11-03T21:11:01.9640139Z ##[endgroup]
2026-11-03T21:11:01.9644734Z Secret source: Actions
2026-11-03T21:11:01.9647311Z Cache mode: write
2026-11-03T21:11:01.9649427Z Prepare workflow directory
2026-11-03T21:11:02.0548463Z Prepare all required actions
2026-11-03T21:11:02.0646715Z Getting action download info
2026-11-03T21:11:02.7694492Z Download action repository 'actions/download-artifact@v8' (SHA:9000827ccba6bdab643e8b6fd33ac0654aef8333)
2026-11-03T21:11:03.7960282Z Download action repository 'actions/upload-artifact@v7' (SHA:cf430e030ddbb5b0abf93d22962f4752f3646cd9)
2026-11-03T21:11:05.3785690Z Uses: PoschLabs/spike-signer/.github/workflows/sign.yml@refs/tags/v0.0.2 (8cdf3c1a65e5d6258a9e78360ca080d09ab4234e)
2026-11-03T21:11:05.3798783Z Complete job name: sign / sign
2026-11-03T21:11:05.5462623Z ##[group]Checking docker version
2026-11-03T21:11:05.5492996Z ##[command]/usr/bin/docker version --format '{{.Server.APIVersion}}'
2026-11-03T21:11:05.7857033Z '1.56'
2026-11-03T21:11:05.7919033Z Docker daemon API version: '1.56'
2026-11-03T21:11:05.7921072Z ##[command]/usr/bin/docker version --format '{{.Client.APIVersion}}'
2026-11-03T21:11:05.8705721Z '1.56'
2026-11-03T21:11:05.8781767Z Docker client API version: '1.56'
2026-11-03T21:11:05.8810951Z ##[endgroup]
2026-11-03T21:11:05.8817300Z ##[group]Clean up resources from previous jobs
2026-11-03T21:11:05.8826389Z ##[command]/usr/bin/docker ps --all --quiet --no-trunc --filter "label=7bf83b"
2026-11-03T21:11:05.9287872Z ##[command]/usr/bin/docker network prune --force --filter "label=7bf83b"
2026-11-03T21:11:06.0060690Z ##[endgroup]
2026-11-03T21:11:06.0062026Z ##[group]Create local container network
2026-11-03T21:11:06.0079582Z ##[command]/usr/bin/docker network create --label 7bf83b github_network_88c739ca79d14cb28f0a11babaea2ccf
2026-11-03T21:11:06.2138917Z 079bb50f270ed62ab1e42ae052fa321595eea5dd16f09e61903d1729c769708b
2026-11-03T21:11:06.2243679Z ##[endgroup]
2026-11-03T21:11:06.2312158Z ##[group]Starting job container
2026-11-03T21:11:06.2373473Z ##[command]/usr/bin/docker pull ubuntu:24.04
2026-11-03T21:11:07.6399618Z 24.04: Pulling from library/ubuntu
2026-11-03T21:11:08.2782517Z 7a48b8f0e5c7: Pulling fs layer
2026-11-03T21:11:09.2097884Z 98144013299c: Download complete
2026-11-03T21:11:10.2057471Z 7a48b8f0e5c7: Download complete
2026-11-03T21:11:13.2810833Z 7a48b8f0e5c7: Pull complete
2026-11-03T21:11:13.2816009Z Digest: sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852
2026-11-03T21:11:13.2823871Z Status: Downloaded newer image for ubuntu:24.04
2026-11-03T21:11:13.2849012Z docker.io/library/ubuntu:24.04
2026-11-03T21:11:13.3307873Z ##[command]/usr/bin/docker create --name bed0ae72c7e94b7b9a20a9b46a91e87f_ubuntu2404_c5940e --label 7bf83b --workdir /__w/spike-caller/spike-caller --network github_network_88c739ca79d14cb28f0a11babaea2ccf --user 1001 --cap-drop=ALL --security-opt=no-new-privileges --read-only --tmpfs /tmp --tmpfs /run/sign:mode=0700,uid=1001 -e "HOME=/github/home" -e GITHUB_ACTIONS=true -e CI=true -v "/var/run/docker.sock":"/var/run/docker.sock" -v "/home/github-runner/actions-runner/_work":"/__w" -v "/home/github-runner/actions-runner/externals":"/__e":ro -v "/home/github-runner/actions-runner/_work/_temp":"/__w/_temp" -v "/home/github-runner/actions-runner/_work/_actions":"/__w/_actions" -v "/home/github-runner/actions-runner/_work/_tool":"/__w/_tool" -v "/home/github-runner/actions-runner/_work/_temp/_github_home":"/github/home" -v "/home/github-runner/actions-runner/_work/_temp/_github_workflow":"/github/workflow" --entrypoint "tail" ubuntu:24.04 "-f" "/dev/null"
2026-11-03T21:11:13.8877883Z f82d299578ffd0a986973a1d4377a5a9660c40d5ead0faf6aabab0d29ceb7c8f
2026-11-03T21:11:13.9057410Z ##[command]/usr/bin/docker start f82d299578ffd0a986973a1d4377a5a9660c40d5ead0faf6aabab0d29ceb7c8f
2026-11-03T21:11:14.6562117Z f82d299578ffd0a986973a1d4377a5a9660c40d5ead0faf6aabab0d29ceb7c8f
2026-11-03T21:11:14.6659336Z ##[command]/usr/bin/docker ps --all --filter id=f82d299578ffd0a986973a1d4377a5a9660c40d5ead0faf6aabab0d29ceb7c8f --filter status=running --no-trunc --format "{{.ID}} {{.Status}}"
2026-11-03T21:11:14.7711383Z f82d299578ffd0a986973a1d4377a5a9660c40d5ead0faf6aabab0d29ceb7c8f Up Less than a second
2026-11-03T21:11:14.7821423Z ##[command]/usr/bin/docker inspect --format "{{range .Config.Env}}{{println .}}{{end}}" f82d299578ffd0a986973a1d4377a5a9660c40d5ead0faf6aabab0d29ceb7c8f
2026-11-03T21:11:14.8652194Z CI=true
2026-11-03T21:11:14.8656426Z HOME=/github/home
2026-11-03T21:11:14.8677925Z GITHUB_ACTIONS=true
2026-11-03T21:11:14.8680485Z PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
2026-11-03T21:11:14.8785659Z ##[endgroup]
2026-11-03T21:11:14.8822678Z ##[group]Waiting for all services to be ready
2026-11-03T21:11:14.9110538Z ##[endgroup]
2026-11-03T21:11:14.9804365Z ##[group]Run id; touch /should-fail || echo "root fs read-only ok"; touch /run/sign/x && echo "tmpfs ok"
2026-11-03T21:11:14.9806727Z [36;1mid; touch /should-fail || echo "root fs read-only ok"; touch /run/sign/x && echo "tmpfs ok"[0m
2026-11-03T21:11:14.9819929Z shell: sh -e {0}
2026-11-03T21:11:14.9821672Z ##[endgroup]
2026-11-03T21:11:15.2658923Z uid=1001 gid=0(root) groups=0(root)
2026-11-03T21:11:15.2709366Z touch: cannot touch '/should-fail': Read-only file system
2026-11-03T21:11:15.2746839Z root fs read-only ok
2026-11-03T21:11:15.2751778Z tmpfs ok
2026-11-03T21:11:15.3425713Z ##[group]Run actions/download-artifact@v8
2026-11-03T21:11:15.3426811Z with:
2026-11-03T21:11:15.3427504Z   name: spike-in
2026-11-03T21:11:15.3428535Z   path: in
2026-11-03T21:11:15.3429258Z   merge-multiple: false
2026-11-03T21:11:15.3430115Z   repository: PoschLabs/spike-caller
2026-11-03T21:11:15.3431041Z   run-id: 41719401343
2026-11-03T21:11:15.3431870Z   skip-decompress: false
2026-11-03T21:11:15.3432695Z   digest-mismatch: error
2026-11-03T21:11:15.3433499Z ##[endgroup]
2026-11-03T21:11:15.3572088Z ##[command]/usr/bin/docker exec  f82d299578ffd0a986973a1d4377a5a9660c40d5ead0faf6aabab0d29ceb7c8f sh -c "cat /etc/*release | grep ^ID"
2026-11-03T21:11:16.5144509Z Downloading single artifact
2026-11-03T21:11:17.0862825Z Preparing to download the following artifacts:
2026-11-03T21:11:17.0866149Z - spike-in (ID: 13271645532, Size: 156, Expected Digest: sha256:989b85b3a6407ffbdbd55e3cf061ea7df86ab64d75b759db3764fc89c9cf82b7)
2026-11-03T21:11:18.1017811Z Redirecting to blob download url: https://productionresultssa16.blob.core.windows.net/actions-results/9a105d16-3e26-4720-950c-6d4ba87bc2eb/workflow-job-run-3e5b2db8-651a-5457-aec8-77c8f108c9a8/artifacts/adceddcc955c86b4aa3f062e2d57e34928791f45e1088d417663bfa255c62065.zip
2026-11-03T21:11:18.1023591Z Starting download of artifact to: /__w/spike-caller/spike-caller/in
2026-11-03T21:11:18.7299664Z (node:25) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
2026-11-03T21:11:18.7305151Z (Use `node --trace-deprecation ...` to show where the warning was created)
2026-11-03T21:11:18.7436495Z SHA256 digest of downloaded artifact is 989b85b3a6407ffbdbd55e3cf061ea7df86ab64d75b759db3764fc89c9cf82b7
2026-11-03T21:11:18.7444151Z Artifact download completed successfully.
2026-11-03T21:11:18.7464019Z Total of 1 artifact(s) downloaded
2026-11-03T21:11:18.7465307Z Download artifact has finished successfully
2026-11-03T21:11:18.8202773Z ##[group]Run mkdir out && cp -r in/. out/ && ls -laR out
2026-11-03T21:11:18.8204205Z [36;1mmkdir out && cp -r in/. out/ && ls -laR out[0m
2026-11-03T21:11:18.8205375Z shell: sh -e {0}
2026-11-03T21:11:18.8206272Z ##[endgroup]
2026-11-03T21:11:19.1098050Z out:
2026-11-03T21:11:19.1099853Z total 12
2026-11-03T21:11:19.1101477Z drwxr-xr-x 2 1001 root 4096 Nov  3 21:11 .
2026-11-03T21:11:19.1104271Z drwxr-xr-x 4 1001 1001 4096 Nov  3 21:11 ..
2026-11-03T21:11:19.1108431Z -rw-r--r-- 1 1001 root   24 Nov  3 21:11 test.txt
2026-11-03T21:11:19.1510435Z ##[group]Run actions/upload-artifact@v7
2026-11-03T21:11:19.1511457Z with:
2026-11-03T21:11:19.1512111Z   name: spike-out
2026-11-03T21:11:19.1512802Z   path: out
2026-11-03T21:11:19.1513481Z   if-no-files-found: warn
2026-11-03T21:11:19.1514317Z   compression-level: 6
2026-11-03T21:11:19.1515070Z   overwrite: false
2026-11-03T21:11:19.1515816Z   include-hidden-files: false
2026-11-03T21:11:19.1516628Z   archive: true
2026-11-03T21:11:19.1517371Z ##[endgroup]
2026-11-03T21:11:19.1530463Z ##[command]/usr/bin/docker exec  f82d299578ffd0a986973a1d4377a5a9660c40d5ead0faf6aabab0d29ceb7c8f sh -c "cat /etc/*release | grep ^ID"
2026-11-03T21:11:20.1709137Z With the provided path, there will be 1 file uploaded
2026-11-03T21:11:20.1742991Z Artifact name is valid!
2026-11-03T21:11:20.1759000Z Root directory input is valid!
2026-11-03T21:11:20.8845348Z Uploading artifact: spike-out.zip
2026-11-03T21:11:20.8974903Z Beginning upload of artifact content to blob storage
2026-11-03T21:11:21.6279875Z Uploaded bytes 156
2026-11-03T21:11:21.7875734Z Finished uploading artifact content to blob storage!
2026-11-03T21:11:21.7885554Z SHA256 digest of uploaded artifact is 22ff45dfd44852cd91c58d46b34ab93fd563671eed20bbb2f753ed6b105ab60b
2026-11-03T21:11:21.7892073Z Finalizing artifact upload
2026-11-03T21:11:22.6651009Z Artifact spike-out successfully finalized. Artifact ID 13271710557
2026-11-03T21:11:22.6653893Z Artifact spike-out has been successfully uploaded! Final size is 156 bytes. Artifact ID is 13271710557
2026-11-03T21:11:22.6657775Z Artifact download URL: https://github.com/PoschLabs/spike-caller/actions/runs/41719401343/artifacts/13271710557
2026-11-03T21:11:22.7425978Z Stop and remove container: bed0ae72c7e94b7b9a20a9b46a91e87f_ubuntu2404_c5940e
2026-11-03T21:11:22.7440972Z ##[command]/usr/bin/docker rm --force f82d299578ffd0a986973a1d4377a5a9660c40d5ead0faf6aabab0d29ceb7c8f
2026-11-03T21:11:23.1544913Z f82d299578ffd0a986973a1d4377a5a9660c40d5ead0faf6aabab0d29ceb7c8f
2026-11-03T21:11:23.1757231Z Remove container network: github_network_88c739ca79d14cb28f0a11babaea2ccf
2026-11-03T21:11:23.1771662Z ##[command]/usr/bin/docker network rm github_network_88c739ca79d14cb28f0a11babaea2ccf
2026-11-03T21:11:23.4313153Z github_network_88c739ca79d14cb28f0a11babaea2ccf
2026-11-03T21:11:23.4615873Z Cleaning up orphan processes

spike-out File OK, matches content

## 2nd run:
2026-11-03T21:23:04.1901577Z Current runner version: '2.338.2'
2026-11-03T21:23:04.1925145Z Runner name: 'lysithea'
2026-11-03T21:23:04.1928033Z Runner group name: 'spike-signing'
2026-11-03T21:23:04.1932001Z Machine name: 'lysithea'
2026-11-03T21:23:04.1944567Z ##[group]GITHUB_TOKEN Permissions
2026-11-03T21:23:04.1952001Z Contents: read
2026-11-03T21:23:04.1954874Z Metadata: read
2026-11-03T21:23:04.1957664Z ##[endgroup]
2026-11-03T21:23:04.1964754Z Secret source: Actions
2026-11-03T21:23:04.1968784Z Cache mode: write
2026-11-03T21:23:04.1971379Z Prepare workflow directory
2026-11-03T21:23:04.3693475Z Prepare all required actions
2026-11-03T21:23:04.3869117Z Getting action download info
2026-11-03T21:23:05.0494757Z Download action repository 'actions/download-artifact@v8' (SHA:9000827ccba6bdab643e8b6fd33ac0654aef8333)
2026-11-03T21:23:06.3816736Z Download action repository 'actions/upload-artifact@v7' (SHA:cf430e030ddbb5b0abf93d22962f4752f3646cd9)
2026-11-03T21:23:07.9042621Z Uses: PoschLabs/spike-signer/.github/workflows/sign.yml@refs/tags/v0.0.2 (edc447ea4a234cc32212dbe078ee31686b28dc91)
2026-11-03T21:23:07.9057037Z Complete job name: sign / sign
2026-11-03T21:23:08.1281912Z ##[group]Checking docker version
2026-11-03T21:23:08.1312354Z ##[command]/usr/bin/docker version --format '{{.Server.APIVersion}}'
2026-11-03T21:23:08.2325157Z '1.56'
2026-11-03T21:23:08.2417527Z Docker daemon API version: '1.56'
2026-11-03T21:23:08.2419105Z ##[command]/usr/bin/docker version --format '{{.Client.APIVersion}}'
2026-11-03T21:23:08.3317933Z '1.56'
2026-11-03T21:23:08.3429868Z Docker client API version: '1.56'
2026-11-03T21:23:08.3445518Z ##[endgroup]
2026-11-03T21:23:08.3458664Z ##[group]Clean up resources from previous jobs
2026-11-03T21:23:08.3475063Z ##[command]/usr/bin/docker ps --all --quiet --no-trunc --filter "label=7bf83b"
2026-11-03T21:23:08.4065495Z ##[command]/usr/bin/docker network prune --force --filter "label=7bf83b"
2026-11-03T21:23:08.4915543Z ##[endgroup]
2026-11-03T21:23:08.4916900Z ##[group]Create local container network
2026-11-03T21:23:08.4952003Z ##[command]/usr/bin/docker network create --label 7bf83b github_network_8effdd039fdd46f6b63e4df59714dc43
2026-11-03T21:23:08.7128706Z 4978c5d07098f65ce291dbe5b4065be399079ba3e046bda058b2d94f5ca42afa
2026-11-03T21:23:08.7209821Z ##[endgroup]
2026-11-03T21:23:08.7262232Z ##[group]Starting job container
2026-11-03T21:23:08.7311256Z ##[command]/usr/bin/docker pull ubuntu:24.04
2026-11-03T21:23:09.8659817Z 24.04: Pulling from library/ubuntu
2026-11-03T21:23:10.1186380Z Digest: sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852
2026-11-03T21:23:10.1190252Z Status: Image is up to date for ubuntu:24.04
2026-11-03T21:23:10.1199559Z docker.io/library/ubuntu:24.04
2026-11-03T21:23:10.1907030Z ##[command]/usr/bin/docker create --name c3c1a4862ed543eeb7eba14cd3214895_ubuntu2404_ed6669 --label 7bf83b --workdir /__w/spike-caller/spike-caller --network github_network_8effdd039fdd46f6b63e4df59714dc43 --user 1001 --cap-drop=ALL --security-opt=no-new-privileges --read-only --tmpfs /tmp --tmpfs /run/sign:mode=0700,uid=1001 --volume /etc/spike-ca.pem:/etc/ssl/certs/spike-ca.pem:ro -e "HOME=/github/home" -e GITHUB_ACTIONS=true -e CI=true -v "/var/run/docker.sock":"/var/run/docker.sock" -v "/home/github-runner/actions-runner/_work":"/__w" -v "/home/github-runner/actions-runner/externals":"/__e":ro -v "/home/github-runner/actions-runner/_work/_temp":"/__w/_temp" -v "/home/github-runner/actions-runner/_work/_actions":"/__w/_actions" -v "/home/github-runner/actions-runner/_work/_tool":"/__w/_tool" -v "/home/github-runner/actions-runner/_work/_temp/_github_home":"/github/home" -v "/home/github-runner/actions-runner/_work/_temp/_github_workflow":"/github/workflow" --entrypoint "tail" ubuntu:24.04 "-f" "/dev/null"
2026-11-03T21:23:10.4626483Z 5cc234aa7324cb799c52543ac7b06b15c8c1082682ff47b7537773b831de9dcf
2026-11-03T21:23:10.4674287Z ##[command]/usr/bin/docker start 5cc234aa7324cb799c52543ac7b06b15c8c1082682ff47b7537773b831de9dcf
2026-11-03T21:23:11.1080064Z 5cc234aa7324cb799c52543ac7b06b15c8c1082682ff47b7537773b831de9dcf
2026-11-03T21:23:11.1197837Z ##[command]/usr/bin/docker ps --all --filter id=5cc234aa7324cb799c52543ac7b06b15c8c1082682ff47b7537773b831de9dcf --filter status=running --no-trunc --format "{{.ID}} {{.Status}}"
2026-11-03T21:23:11.1941561Z 5cc234aa7324cb799c52543ac7b06b15c8c1082682ff47b7537773b831de9dcf Up Less than a second
2026-11-03T21:23:11.2067793Z ##[command]/usr/bin/docker inspect --format "{{range .Config.Env}}{{println .}}{{end}}" 5cc234aa7324cb799c52543ac7b06b15c8c1082682ff47b7537773b831de9dcf
2026-11-03T21:23:11.2475752Z HOME=/github/home
2026-11-03T21:23:11.2477492Z GITHUB_ACTIONS=true
2026-11-03T21:23:11.2479850Z CI=true
2026-11-03T21:23:11.2481762Z PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
2026-11-03T21:23:11.2525774Z ##[endgroup]
2026-11-03T21:23:11.2541946Z ##[group]Waiting for all services to be ready
2026-11-03T21:23:11.2544541Z ##[endgroup]
2026-11-03T21:23:11.2883696Z ##[group]Run id; touch /should-fail || echo "root fs read-only ok"; touch /run/sign/x && echo "tmpfs ok"
2026-11-03T21:23:11.2884859Z [36;1mid; touch /should-fail || echo "root fs read-only ok"; touch /run/sign/x && echo "tmpfs ok"[0m
2026-11-03T21:23:11.2890490Z shell: sh -e {0}
2026-11-03T21:23:11.2891378Z ##[endgroup]
2026-11-03T21:23:11.4799279Z uid=1001 gid=0(root) groups=0(root)
2026-11-03T21:23:11.4800699Z touch: cannot touch '/should-fail': Read-only file system
2026-11-03T21:23:11.4801692Z root fs read-only ok
2026-11-03T21:23:11.4806790Z tmpfs ok
2026-11-03T21:23:11.5117835Z ##[group]Run actions/download-artifact@v8
2026-11-03T21:23:11.5118568Z with:
2026-11-03T21:23:11.5118930Z   name: spike-in
2026-11-03T21:23:11.5119299Z   path: in
2026-11-03T21:23:11.5119666Z   merge-multiple: false
2026-11-03T21:23:11.5120098Z   repository: PoschLabs/spike-caller
2026-11-03T21:23:11.5120554Z   run-id: 41721263405
2026-11-03T21:23:11.5120966Z   skip-decompress: false
2026-11-03T21:23:11.5121385Z   digest-mismatch: error
2026-11-03T21:23:11.5121786Z ##[endgroup]
2026-11-03T21:23:11.5181535Z ##[command]/usr/bin/docker exec  5cc234aa7324cb799c52543ac7b06b15c8c1082682ff47b7537773b831de9dcf sh -c "cat /etc/*release | grep ^ID"
2026-11-03T21:23:12.6112473Z Downloading single artifact
2026-11-03T21:23:13.1550342Z Preparing to download the following artifacts:
2026-11-03T21:23:13.1561152Z - spike-in (ID: 13273220796, Size: 156, Expected Digest: sha256:e4524c4fad6911252280d00022bb2de3ac66c3ced4471048354dce0891679cf2)
2026-11-03T21:23:14.1526001Z Redirecting to blob download url: https://productionresultssa8.blob.core.windows.net/actions-results/ca4fb601-1b42-4af7-b796-62f39e5ae5d5/workflow-job-run-c8929088-7552-5f69-b26d-166e78e3d47d/artifacts/adceddcc955c86b4aa3f062e2d57e34928791f45e1088d417663bfa255c62065.zip
2026-11-03T21:23:14.1530677Z Starting download of artifact to: /__w/spike-caller/spike-caller/in
2026-11-03T21:23:14.7682343Z (node:25) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
2026-11-03T21:23:14.7688829Z (Use `node --trace-deprecation ...` to show where the warning was created)
2026-11-03T21:23:14.7780659Z SHA256 digest of downloaded artifact is e4524c4fad6911252280d00022bb2de3ac66c3ced4471048354dce0891679cf2
2026-11-03T21:23:14.7783932Z Artifact download completed successfully.
2026-11-03T21:23:14.7785851Z Total of 1 artifact(s) downloaded
2026-11-03T21:23:14.7787257Z Download artifact has finished successfully
2026-11-03T21:23:14.8277904Z ##[group]Run mkdir out && cp -r in/. out/ && ls -laR out
2026-11-03T21:23:14.8279660Z [36;1mmkdir out && cp -r in/. out/ && ls -laR out[0m
2026-11-03T21:23:14.8280841Z shell: sh -e {0}
2026-11-03T21:23:14.8281539Z ##[endgroup]
2026-11-03T21:23:15.0684199Z mkdir: cannot create directory 'out': File exists
2026-11-03T21:23:15.0759382Z ##[error]Process completed with exit code 1.
2026-11-03T21:23:15.0939332Z Stop and remove container: c3c1a4862ed543eeb7eba14cd3214895_ubuntu2404_ed6669
2026-11-03T21:23:15.0950911Z ##[command]/usr/bin/docker rm --force 5cc234aa7324cb799c52543ac7b06b15c8c1082682ff47b7537773b831de9dcf
2026-11-03T21:23:15.4450494Z 5cc234aa7324cb799c52543ac7b06b15c8c1082682ff47b7537773b831de9dcf
2026-11-03T21:23:15.4642912Z Remove container network: github_network_8effdd039fdd46f6b63e4df59714dc43
2026-11-03T21:23:15.4654775Z ##[command]/usr/bin/docker network rm github_network_8effdd039fdd46f6b63e4df59714dc43
2026-11-03T21:23:15.6497440Z github_network_8effdd039fdd46f6b63e4df59714dc43
2026-11-03T21:23:15.6633780Z Cleaning up orphan processes

## rerun after deleting `johannes@lysithea:~$ sudo rm -rf /home/github-runner/actions-runner/_work/spike-caller/spike-caller/out`
2026-11-03T21:38:59.8931176Z Current runner version: '2.338.2'
2026-11-03T21:38:59.8947431Z Runner name: 'lysithea'
2026-11-03T21:38:59.8949746Z Runner group name: 'spike-signing'
2026-11-03T21:38:59.8952087Z Machine name: 'lysithea'
2026-11-03T21:38:59.8960554Z ##[group]GITHUB_TOKEN Permissions
2026-11-03T21:38:59.8965729Z Contents: read
2026-11-03T21:38:59.8967202Z Metadata: read
2026-11-03T21:38:59.8969416Z ##[endgroup]
2026-11-03T21:38:59.8974387Z Secret source: Actions
2026-11-03T21:38:59.8977293Z Cache mode: write
2026-11-03T21:38:59.8979567Z Prepare workflow directory
2026-11-03T21:39:00.0298612Z Prepare all required actions
2026-11-03T21:39:00.0411528Z Getting action download info
2026-11-03T21:39:00.7320370Z Download action repository 'actions/download-artifact@v8' (SHA:9000827ccba6bdab643e8b6fd33ac0654aef8333)
2026-11-03T21:39:02.0192165Z Download action repository 'actions/upload-artifact@v7' (SHA:cf430e030ddbb5b0abf93d22962f4752f3646cd9)
2026-11-03T21:39:03.9704126Z Uses: PoschLabs/spike-signer/.github/workflows/sign.yml@refs/tags/v0.0.2 (77dd8e545cd5ae39559b7c8cb0fd56e8392d3baa)
2026-11-03T21:39:03.9723901Z Complete job name: sign / sign
2026-11-03T21:39:04.1884103Z ##[group]Checking docker version
2026-11-03T21:39:04.1916522Z ##[command]/usr/bin/docker version --format '{{.Server.APIVersion}}'
2026-11-03T21:39:04.2964411Z '1.56'
2026-11-03T21:39:04.2992170Z Docker daemon API version: '1.56'
2026-11-03T21:39:04.2997053Z ##[command]/usr/bin/docker version --format '{{.Client.APIVersion}}'
2026-11-03T21:39:04.3782310Z '1.56'
2026-11-03T21:39:04.3820912Z Docker client API version: '1.56'
2026-11-03T21:39:04.3832943Z ##[endgroup]
2026-11-03T21:39:04.3841564Z ##[group]Clean up resources from previous jobs
2026-11-03T21:39:04.3855344Z ##[command]/usr/bin/docker ps --all --quiet --no-trunc --filter "label=7bf83b"
2026-11-03T21:39:04.4756065Z ##[command]/usr/bin/docker network prune --force --filter "label=7bf83b"
2026-11-03T21:39:04.5619076Z ##[endgroup]
2026-11-03T21:39:04.5622230Z ##[group]Create local container network
2026-11-03T21:39:04.5660114Z ##[command]/usr/bin/docker network create --label 7bf83b github_network_de62a19ec2fc45249331a0b692918f61
2026-11-03T21:39:04.8169797Z 04bb80eb6d06a78f35414450976249b410ff14f459c2ac4abe8b57f47c065c63
2026-11-03T21:39:04.8224875Z ##[endgroup]
2026-11-03T21:39:04.8364407Z ##[group]Starting job container
2026-11-03T21:39:04.8440479Z ##[command]/usr/bin/docker pull ubuntu:24.04
2026-11-03T21:39:05.9428882Z 24.04: Pulling from library/ubuntu
2026-11-03T21:39:06.2156993Z Digest: sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852
2026-11-03T21:39:06.2162966Z Status: Image is up to date for ubuntu:24.04
2026-11-03T21:39:06.2182167Z docker.io/library/ubuntu:24.04
2026-11-03T21:39:06.2847000Z ##[command]/usr/bin/docker create --name 9308d7125e3f47e19842be66218267a6_ubuntu2404_c8d55a --label 7bf83b --workdir /__w/spike-caller/spike-caller --network github_network_de62a19ec2fc45249331a0b692918f61 --user 1001 --cap-drop=ALL --security-opt=no-new-privileges --read-only --tmpfs /tmp --tmpfs /run/sign:mode=0700,uid=1001 --volume /etc/spike-ca.pem:/etc/ssl/certs/spike-ca.pem:ro -e "HOME=/github/home" -e GITHUB_ACTIONS=true -e CI=true -v "/var/run/docker.sock":"/var/run/docker.sock" -v "/home/github-runner/actions-runner/_work":"/__w" -v "/home/github-runner/actions-runner/externals":"/__e":ro -v "/home/github-runner/actions-runner/_work/_temp":"/__w/_temp" -v "/home/github-runner/actions-runner/_work/_actions":"/__w/_actions" -v "/home/github-runner/actions-runner/_work/_tool":"/__w/_tool" -v "/home/github-runner/actions-runner/_work/_temp/_github_home":"/github/home" -v "/home/github-runner/actions-runner/_work/_temp/_github_workflow":"/github/workflow" --entrypoint "tail" ubuntu:24.04 "-f" "/dev/null"
2026-11-03T21:39:06.5626050Z 258a0ff23509202ad84ef13e19d65ce98a89d89f72c439f253a1024d17714eaa
2026-11-03T21:39:06.5815423Z ##[command]/usr/bin/docker start 258a0ff23509202ad84ef13e19d65ce98a89d89f72c439f253a1024d17714eaa
2026-11-03T21:39:07.1348620Z 258a0ff23509202ad84ef13e19d65ce98a89d89f72c439f253a1024d17714eaa
2026-11-03T21:39:07.1466442Z ##[command]/usr/bin/docker ps --all --filter id=258a0ff23509202ad84ef13e19d65ce98a89d89f72c439f253a1024d17714eaa --filter status=running --no-trunc --format "{{.ID}} {{.Status}}"
2026-11-03T21:39:07.2251245Z 258a0ff23509202ad84ef13e19d65ce98a89d89f72c439f253a1024d17714eaa Up Less than a second
2026-11-03T21:39:07.2374795Z ##[command]/usr/bin/docker inspect --format "{{range .Config.Env}}{{println .}}{{end}}" 258a0ff23509202ad84ef13e19d65ce98a89d89f72c439f253a1024d17714eaa
2026-11-03T21:39:07.3086479Z HOME=/github/home
2026-11-03T21:39:07.3087609Z GITHUB_ACTIONS=true
2026-11-03T21:39:07.3089019Z CI=true
2026-11-03T21:39:07.3090266Z PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
2026-11-03T21:39:07.3246695Z ##[endgroup]
2026-11-03T21:39:07.3265784Z ##[group]Waiting for all services to be ready
2026-11-03T21:39:07.3269835Z ##[endgroup]
2026-11-03T21:39:07.3731433Z ##[group]Run id; touch /should-fail || echo "root fs read-only ok"; touch /run/sign/x && echo "tmpfs ok"
2026-11-03T21:39:07.3732985Z [36;1mid; touch /should-fail || echo "root fs read-only ok"; touch /run/sign/x && echo "tmpfs ok"[0m
2026-11-03T21:39:07.3741217Z shell: sh -e {0}
2026-11-03T21:39:07.3742362Z ##[endgroup]
2026-11-03T21:39:07.6059859Z uid=1001 gid=0(root) groups=0(root)
2026-11-03T21:39:07.6061332Z touch: cannot touch '/should-fail': Read-only file system
2026-11-03T21:39:07.6062498Z root fs read-only ok
2026-11-03T21:39:07.6076049Z tmpfs ok
2026-11-03T21:39:07.6478847Z ##[group]Run actions/download-artifact@v8
2026-11-03T21:39:07.6479518Z with:
2026-11-03T21:39:07.6479907Z   name: spike-in
2026-11-03T21:39:07.6480338Z   path: in
2026-11-03T21:39:07.6480735Z   merge-multiple: false
2026-11-03T21:39:07.6481221Z   repository: PoschLabs/spike-caller
2026-11-03T21:39:07.6481731Z   run-id: 41723669846
2026-11-03T21:39:07.6482161Z   skip-decompress: false
2026-11-03T21:39:07.6482621Z   digest-mismatch: error
2026-11-03T21:39:07.6483143Z ##[endgroup]
2026-11-03T21:39:07.6561889Z ##[command]/usr/bin/docker exec  258a0ff23509202ad84ef13e19d65ce98a89d89f72c439f253a1024d17714eaa sh -c "cat /etc/*release | grep ^ID"
2026-11-03T21:39:08.6454412Z Downloading single artifact
2026-11-03T21:39:09.3271672Z Preparing to download the following artifacts:
2026-11-03T21:39:09.3290516Z - spike-in (ID: 13271614105, Size: 156, Expected Digest: sha256:3f5f8ede69952ee2bb4f8828d9c503372f24b3f28985c2e05053179ea7d8f879)
2026-11-03T21:39:10.3633348Z Redirecting to blob download url: https://productionresultssa31.blob.core.windows.net/actions-results/1ae0c752-a6fd-469c-9351-55dc31600887/workflow-job-run-26969ba1-9be3-530a-8716-6945a6a0a01b/artifacts/adceddcc955c86b4aa3f062e2d57e34928791f45e1088d417663bfa255c62065.zip
2026-11-03T21:39:10.3656022Z Starting download of artifact to: /__w/spike-caller/spike-caller/in
2026-11-03T21:39:10.9815184Z (node:24) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
2026-11-03T21:39:10.9820583Z (Use `node --trace-deprecation ...` to show where the warning was created)
2026-11-03T21:39:10.9951998Z SHA256 digest of downloaded artifact is 3f5f8ede69952ee2bb4f8828d9c503372f24b3f28985c2e05053179ea7d8f879
2026-11-03T21:39:10.9955302Z Artifact download completed successfully.
2026-11-03T21:39:10.9978375Z Total of 1 artifact(s) downloaded
2026-11-03T21:39:10.9981514Z Download artifact has finished successfully
2026-11-03T21:39:11.0646850Z ##[group]Run mkdir out && cp -r in/. out/ && ls -laR out
2026-11-03T21:39:11.0648624Z [36;1mmkdir out && cp -r in/. out/ && ls -laR out[0m
2026-11-03T21:39:11.0649842Z shell: sh -e {0}
2026-11-03T21:39:11.0650548Z ##[endgroup]
2026-11-03T21:39:11.3565534Z out:
2026-11-03T21:39:11.3567989Z total 12
2026-11-03T21:39:11.3575931Z drwxr-xr-x 2 1001 root 4096 Nov  3 21:39 .
2026-11-03T21:39:11.3577456Z drwxr-xr-x 4 1001 1001 4096 Nov  3 21:39 ..
2026-11-03T21:39:11.3579123Z -rw-r--r-- 1 1001 root   24 Nov  3 21:39 test.txt
2026-11-03T21:39:11.3913503Z ##[group]Run actions/upload-artifact@v7
2026-11-03T21:39:11.3914535Z with:
2026-11-03T21:39:11.3915182Z   name: spike-out
2026-11-03T21:39:11.3915901Z   path: out
2026-11-03T21:39:11.3916665Z   if-no-files-found: warn
2026-11-03T21:39:11.3917577Z   compression-level: 6
2026-11-03T21:39:11.3918680Z   overwrite: false
2026-11-03T21:39:11.3919430Z   include-hidden-files: false
2026-11-03T21:39:11.3920274Z   archive: true
2026-11-03T21:39:11.3920978Z ##[endgroup]
2026-11-03T21:39:11.3934195Z ##[command]/usr/bin/docker exec  258a0ff23509202ad84ef13e19d65ce98a89d89f72c439f253a1024d17714eaa sh -c "cat /etc/*release | grep ^ID"
2026-11-03T21:39:12.3156805Z With the provided path, there will be 1 file uploaded
2026-11-03T21:39:12.3179524Z Artifact name is valid!
2026-11-03T21:39:12.3184255Z Root directory input is valid!
2026-11-03T21:39:12.9709584Z Uploading artifact: spike-out.zip
2026-11-03T21:39:12.9860018Z Beginning upload of artifact content to blob storage
2026-11-03T21:39:13.6718667Z Uploaded bytes 156
2026-11-03T21:39:13.8225342Z Finished uploading artifact content to blob storage!
2026-11-03T21:39:13.8234008Z SHA256 digest of uploaded artifact is 2b570a5858ac500df77440f9ce663e32d8c896d23ff925ba6bf4f90348ebc44e
2026-11-03T21:39:13.8235692Z Finalizing artifact upload
2026-11-03T21:39:14.6993964Z Artifact spike-out successfully finalized. Artifact ID 13271419323
2026-11-03T21:39:14.6996737Z Artifact spike-out has been successfully uploaded! Final size is 156 bytes. Artifact ID is 13271419323
2026-11-03T21:39:14.7012619Z Artifact download URL: https://github.com/PoschLabs/spike-caller/actions/runs/41723669846/artifacts/13271419323
2026-11-03T21:39:14.7764843Z ##[group]Run set -eu
2026-11-03T21:39:14.7765784Z [36;1mset -eu[0m
2026-11-03T21:39:14.7766490Z [36;1m[0m
2026-11-03T21:39:14.7767251Z [36;1mecho "Checking certificate mount..."[0m
2026-11-03T21:39:14.7768555Z [36;1m[0m
2026-11-03T21:39:14.7769330Z [36;1mtest -f /etc/ssl/certs/spike-ca.pem[0m
2026-11-03T21:39:14.7770399Z [36;1mtest -r /etc/ssl/certs/spike-ca.pem[0m
2026-11-03T21:39:14.7771412Z [36;1m[0m
2026-11-03T21:39:14.7772212Z [36;1mecho "Certificate exists and is readable"[0m
2026-11-03T21:39:14.7773203Z [36;1m[0m
2026-11-03T21:39:14.7774182Z [36;1mif echo "test" >> /etc/ssl/certs/spike-ca.pem 2>/dev/null; then[0m
2026-11-03T21:39:14.7775481Z [36;1m  echo "ERROR: CA mount is writable!"[0m
2026-11-03T21:39:14.7776467Z [36;1m  exit 1[0m
2026-11-03T21:39:14.7777154Z [36;1melse[0m
2026-11-03T21:39:14.7777914Z [36;1m  echo "OK: CA mount is read-only"[0m
2026-11-03T21:39:14.7779307Z [36;1mfi[0m
2026-11-03T21:39:14.7780122Z shell: sh -e {0}
2026-11-03T21:39:14.7780934Z ##[endgroup]
2026-11-03T21:39:15.0701146Z /__w/_temp/acc7dd07-2b18-49c6-bfee-0973aad1c88f.sh: 10: cannot create /etc/ssl/certs/spike-ca.pem: Permission denied
2026-11-03T21:39:15.0709010Z Checking certificate mount...
2026-11-03T21:39:15.0732654Z Certificate exists and is readable
2026-11-03T21:39:15.0772103Z OK: CA mount is read-only
2026-11-03T21:39:15.1074850Z Stop and remove container: 9308d7125e3f47e19842be66218267a6_ubuntu2404_c8d55a
2026-11-03T21:39:15.1091632Z ##[command]/usr/bin/docker rm --force 258a0ff23509202ad84ef13e19d65ce98a89d89f72c439f253a1024d17714eaa
2026-11-03T21:39:15.4981548Z 258a0ff23509202ad84ef13e19d65ce98a89d89f72c439f253a1024d17714eaa
2026-11-03T21:39:15.5437611Z Remove container network: github_network_de62a19ec2fc45249331a0b692918f61
2026-11-03T21:39:15.5478607Z ##[command]/usr/bin/docker network rm github_network_de62a19ec2fc45249331a0b692918f61
2026-11-03T21:39:15.7370409Z github_network_de62a19ec2fc45249331a0b692918f61
2026-11-03T21:39:15.7600720Z Cleaning up orphan processes

# Step 4
For the sign.yaml
~~~ yaml
name: Sign

on:
  workflow_call:

permissions:
  id-token: write
  contents: read

jobs:
  sign:
    name: Inspect GitHub OIDC claims

    runs-on:
      group: spike-signing
      labels: [rpm-signer]

    steps:
      - name: Inspect OIDC token claims
        shell: bash
        run: |
          set -euo pipefail
          set +x

          echo "Requesting GitHub OIDC token..."

          JWT=$(curl --fail --silent --show-error \
            -H "Authorization: Bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" \
            "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=spike-infisical" \
            | jq -r '.value')

          if [[ -z "$JWT" || "$JWT" == "null" ]]; then
            echo "ERROR: No OIDC token received"
            exit 1
          fi

          echo "OIDC claims:"

          python3 -c '
          import sys, json, base64

          token = sys.stdin.read().strip()
          payload = token.split(".")[1]
          payload += "=" * (-len(payload) % 4)

          claims = json.loads(base64.urlsafe_b64decode(payload))

          fields = [
              "iss",
              "aud",
              "sub",
              "repository",
              "repository_owner",
              "ref",
              "job_workflow_ref",
              "workflow_ref",
              "runner_environment",
          ]

          print(json.dumps(
              {key: claims.get(key) for key in fields},
              indent=2
          ))
          ' <<< "$JWT"
~~~

I get the output:

Run set -euo pipefail
Requesting GitHub OIDC token...
OIDC claims:
{
  "iss": "https://token.actions.githubusercontent.com",
  "aud": "spike-infisical",
  "sub": "repo:PoschLabs@317321754/spike-caller@1443868501:ref:refs/heads/main",
  "repository": "PoschLabs/spike-caller",
  "repository_owner": "PoschLabs",
  "ref": "refs/heads/main",
  "job_workflow_ref": "PoschLabs/spike-signer/.github/workflows/sign.yml@refs/tags/v0.0.3",
  "workflow_ref": "PoschLabs/spike-caller/.github/workflows/call.yml@refs/heads/main",
  "runner_environment": "self-hosted"
}

johannes@lysithea:~$ curl -sS -o resp.json -w '%{http_code}\n' -X POST "$INFISICAL_URL/api/v1/auth/oidc-auth/login" \
  --data-urlencode "identityId=$IDENTITY_ID" --data-urlencode "jwt=$JWT"
jq 'keys' resp.json
200
[
  "accessToken",
  "accessTokenMaxTTL",
  "expiresIn",
  "tokenType"
]

johannes@lysithea:~$ curl -sS --fail   -H "Authorization: Bearer $(jq -r '.accessToken' resp.json)"   "$INFISICAL_URL/api/v3/secrets/raw/SPIKE_SECRET?workspaceId=$PROJECT_ID&environment=prod&secretPath=/spike"   | jq 'del(.secret.secretValue)'
{
  "secret": {
    "id": "94f2252b-4129-4a8f-8385-6f9fec9f4321",
    "_id": "94f2252b-4129-4a8f-8385-6f9fec9f4321",
    "workspace": "928959f8-159d-45af-ad61-c893f9111b82",
    "environment": "prod",
    "version": 1,
    "type": "shared",
    "secretKey": "SPIKE_SECRET",
    "secretComment": "",
    "secretReminderNote": null,
    "secretReminderRepeatDays": null,
    "skipMultilineEncoding": false,
    "createdAt": "2026-11-03T21:42:34.158Z",
    "updatedAt": "2026-11-03T21:42:34.158Z",
    "isRotatedSecret": false,
    "rotationId": null,
    "secretValueHidden": false,
    "secretPath": "/spike",
    "tags": [],
    "secretMetadata": []
  }
}

johannes@lysithea:~$ curl -sS --fail   -H "Authorization: Bearer $(jq -r '.accessToken' resp.json)"   "$INFISICAL_URL/api/v3/secrets/raw/SPIKE_SECRET?workspaceId=$PROJECT_ID&environment=prod&secretPath=/spike"   | jq -j '.secret.secretValue'
this is some value
Within three lines
It has some content


## When executing from spike-other

johannes@lysithea:~$ curl -sS -o resp.json -w '%{http_code}\n' -X POST "$INFISICAL_URL/api/v1/auth/oidc-auth/login"   --data-urlencode "identityId=$IDENTITY_ID" --data-urlencode "jwt=$JWT"
401

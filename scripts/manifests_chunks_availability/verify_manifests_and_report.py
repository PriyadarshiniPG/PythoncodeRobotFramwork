"""The script verifies manifests by calling an external script TestChunk.py (Python 3),
which, in turn, reads assets ids from a text file ("asset.txt").

Note: TestChunk.py is kept "as is" and it requires Python 3.

This current script reads all assets ids from "assets.txt" (each line in it is an asset id),
and puts those ids one by one into "asset.txt" to be used by TestChunk.py.
So, TestChunk.py will be executed consequently as many times as many assets we have.

The artifacts of the current script are the following:
 - summary.txt: a summary telling a status of chunks availability for each manifest;
 - <asset_id>.txt: a grabbed output of TestChunk.py - a separate file for each manifest;
 - VSPP_chunk_test_<timestamp>.csv: a CSV file created by TestChunk.py;
 - request_list.txt: a text file containing manifest URLs (created by TestChunk.py).
"""

import subprocess


def run_cmd(cmd):
    stdout = subprocess.Popen(cmd, stdout=subprocess.PIPE).stdout
    output = stdout.read().decode("utf-8")
    return output



if __name__ == "__main__":
    # Read assets ids from "assets.txt" into a list
    with open("assets.txt", "r") as _f:
        assets = [line.strip() for line in _f.readlines()]

    # Write brief results to summary.txt
    with open("summary.txt", "w+") as _f:
        i = 0
        for asset in assets:
            i += 1

            with open("asset.txt", "w") as _g: # if change file name - change it in TestChunks.py
                _g.write(asset) # a single asset, will be picked up by TestChunks.py

            output = run_cmd("python TestChunks.py") # Python 3 required

            # Save output as a text artifact + CSV file will be saved by TestChunks.py
            with open("%s.txt" % asset, "w") as _g:
                _g.write(output)

            # if at least one chunk failed, manifest is considered as failed:
            status = "OK"
            for line in output.split("\r\n"):
                if "Res:" in line and "Res: 200" not in line:
                    status = "FAIL"
            msg = "%s: %s - %s\n" % (i, status, asset)
            print(msg)
            _f.write(msg) # append a line to summary.txt



    
    
    
                

import json, os
    
jsonFile = open("fss-trust-policy.json", "r")

data = json.load(jsonFile)

jsonFile.close()

tmp = data["Statement"]

my_bucket = os.environ['bucket_to_scan_arn']

tmp[0]["Resource"] = my_bucket 

tmp2 = data["Statement"]

my_promote_bucket = os.environ['my_promote_bucket_arn']

my_quarantine_bucket = os.environ['my_quarantine_bucket_arn']

tmp2[1]["Resource"][0] = my_promote_bucket

tmp2[1]["Resource"][1] = my_quarantine_bucket

jsonFile = open("fss-trust-policy.json", "w+")

jsonFile.write(json.dumps(data, indent=3))

jsonFile.close()
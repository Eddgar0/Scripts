#!/usr/bin/python

# @METADATASTART
#@DetailDescriptionStart
################################################
# XIQ-Site     script
# written by:  Zdenek Pala
# modified by  Eddgar Rojas
# date:        30 march 2023
# purpose:     Add the End System to group
################################################
#@DetailDescriptionEnd
# @MetaDataEnd

from requests.auth import HTTPBasicAuth
import requests, logging, sys, re
from datetime import datetime
########LOGGING - FUNCTION DEFINITIONS
def wf_error(log):
    print('Error:' +log)
    logging.error(log)
    
def wf_info(log):
    print('INFO:' +log)
    logging.info(log)

varNow = datetime.now().strftime('%d-%m-%Y_%H:%M')
varGroupName = "desiredgroup"
varUsername = "youruser"
varPassword = "yourpass"
varServerIP = "server-ip"

if len(sys.argv) == 1:
    sys.exit("Could not find MAC in parrameters")

regex = re.compile(r"-([0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2})\s")
found = regex.findall(sys.argv[1])
print(found,regex)
try:
    varMAC = found[0]
except:
    print("Could not find MAC in parrameters")
    sys.exit("Could not find MAC in parrameters")

varURL = 'https://%s:8443/axis/services/NACEndSystemWebService/addMACsToEndSystemGroup?endSystemGroup=%s&macs=%s&descriptions=Expired:%s&reauthorize=true&removeFromOtherGroups=false' %(varServerIP,varGroupName,varMAC,varNow)
print(varURL)
try:
    myResponse = requests.get(varURL, auth=HTTPBasicAuth(varUsername, varPassword), verify=False)
except requests.exceptions.RequestException as e:
    wf_error(str(e))

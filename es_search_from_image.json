import base64
import datetime
import json
import os
import time
import traceback
import urlparse
import botocore.auth
import botocore.awsrequest
import botocore.credentials
import botocore.endpoint
import botocore.session
import boto3.dynamodb.types

rekog = boto3.client('rekognition')

# The following parameters are required to configure the ES cluster
ES_ENDPOINT = 'search-rekog-twk2qgdyaq3dzva7iddeaolc7i.us-east-1.es.amazonaws.com'

# The following parameters can be optionally customized
# DOC_TABLE_FORMAT = '{}'         # Python formatter to generate index name from the DynamoDB table name
DOC_TABLE_FORMAT = 'images'
# DOC_TYPE_FORMAT = '{}_type'     # Python formatter to generate type name from the DynamoDB table name, default is to add '_type' suffix
DOC_TYPE_FORMAT = 'image'
ES_REGION = None  # If not set, use the runtime lambda region
ES_MAX_RETRIES = 3  # Max number of retries for exponential backoff
DEBUG = True  # Set verbose debugging information

# Subclass of boto's TypeDeserializer for DynamoDB to adjust for DynamoDB Stream format.
class TypeDeserializer(boto3.dynamodb.types.TypeDeserializer):
    def _deserialize_n(self, value):
        return float(value)

    def _deserialize_b(self, value):
        return value  # Already in Base64

class ES_Exception(Exception):
    '''Exception capturing status_code from Client Request'''
    status_code = 0
    payload = ''

    def __init__(self, status_code, payload):
        self.status_code = status_code
        self.payload = payload
        Exception.__init__(self, 'ES_Exception: status_code={}, payload={}'.format(status_code, payload))

# Low-level POST data to Amazon Elasticsearch Service generating a Sigv4 signed request
def post_data_to_es(payload, region, creds, host, path, method='POST', proto='https://'):
    '''Post data to ES endpoint with SigV4 signed http headers'''
    sigv4 = botocore.auth.SigV4Auth(creds, 'es', region)
    params = {'context': {}, 'method': method, 'url': proto + host + path, 'region': region, 'headers': {'Host': host},
              'body': payload}
    req = botocore.awsrequest.create_request_object(params)
    sigv4.add_auth(req)
    prep_req = req.prepare()
    http_session = botocore.endpoint.BotocoreHTTPSession()  # PreserveAuthSession()
    res = http_session.send(prep_req)
    if res.status_code >= 200 and res.status_code <= 299:
        return res._content
    else:
        raise ES_Exception(res.status_code, res._content)

# High-level POST data to Amazon Elasticsearch Service with exponential backoff
# according to suggested algorithm: http://docs.aws.amazon.com/general/latest/gr/api-retries.html
def post_to_es(payload):
    
    # Post data to ES cluster with exponential backoff

    # Get aws_region and credentials to post signed URL to ES
    es_region = ES_REGION or os.environ['AWS_REGION']
    session = botocore.session.Session({'region': es_region})
    creds = botocore.credentials.get_credentials(session)
    es_url = urlparse.urlparse(ES_ENDPOINT)
    es_endpoint = es_url.netloc or es_url.path  # Extract the domain name in ES_ENDPOINT

    # Post data with exponential backoff
    retries = 0
    while (retries < ES_MAX_RETRIES):
        if retries > 0:
            millis = 2 ** retries * .100
            if DEBUG:
                print('DEBUG: Wait for {:.1f} seconds'.format(millis))
            time.sleep(millis)

        try:
            es_ret_str = post_data_to_es(payload, es_region, creds, es_endpoint, '/images/_search')
            if DEBUG:
                print('DEBUG: Return from ES: {}'.format(es_ret_str))
            es_ret = json.loads(es_ret_str)

            if es_ret['errors']:
                print('ERROR: ES post unsucessful, errors present, took={}ms'.format(es_ret['took']))
                # Filter errors
                es_errors = [item for item in es_ret['items'] if item.get('index').get('error')]
                print('ERROR: List of items with errors: {}'.format(json.dumps(es_errors)))
            else:
                print('INFO: ES post successful, took={}ms'.format(es_ret['took']))
            break  # Sending to ES was ok, break retry loop
        except ES_Exception as e:
            if (e.status_code >= 500) and (e.status_code <= 599):
                retries += 1  # Candidate for retry
            else:
                raise  # Stop retrying, re-raise exception

def _lambda_handler(event, context):
    if DEBUG:
        print('DEBUG: Event: {}'.format(event))
    now = datetime.datetime.utcnow()

    es_actions = []  # Items to be added/updated/removed from ES - for bulk API

    for record in event['Records']:
        
        # Rekognition - Detect Labels (http://docs.aws.amazon.com/rekognition/latest/dg/API_DetectLabels.html)
        
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        resp = rekog.detect_labels(Image={"S3Object": {"Bucket": bucket, "Name": key}})

        # put results from rekognition into the json ES search

        should = []
        for item in resp['Labels']:
            should.append({ "match": { "Labels.Name": item['Name'] } })
        
        es_search = {
           "query": {
              "bool": {
                 "must": [
                    {
                       "nested": {
                          "path": "Labels",
                          "score_mode": "sum",
                          "query": {
                             "function_score": {
                                "query": {
                                   "bool": {
                                      "should": should
                                   }
                                },
                                "field_value_factor": {
                                   "field": "Labels.Confidence"
                                }
                             }
                          }
                       }
                    }
                 ]
              }
           }
        }

        print('DEBUG: Payload:', es_search)
        post_to_es(json.dumps(es_search))

# Global lambda handler - catches all exceptions
def lambda_handler(event, context):
    try:
        return _lambda_handler(event, context)
    except Exception:
        print('ERROR: ', traceback.format_exc())

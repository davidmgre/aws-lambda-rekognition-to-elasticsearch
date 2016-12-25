# aws-rekognition-to-elasticsearch

## Using [AWS Lambda](https://aws.amazon.com/lambda/), analyze images with AWS Rekognition and write the results to Elasticsearch

Images written to a specific S3 bucket and path are scanned for recognizable objects using [AWS Rekognition](https://aws.amazon.com/rekognition/) and loaded to [Amazon Elasticsearch Service](https://aws.amazon.com/elasticsearch-service/) for searching. 

The Rekognition export for a sample [image](https://awsdmg.com/images/rekognition.jpg) is below.

![alt text](https://awsdmg.com/images/rekognition.jpg "Rekognition Sample Image")


<pre>
{
    "Labels": [
        {
            "Confidence": 99.294921875,
            "Name": "Collage"
        },
        {
            "Confidence": 99.294921875,
            "Name": "Poster"
        },
        {
            "Confidence": 99.08350372314453,
            "Name": "People"
        },
        {
            "Confidence": 99.0835189819336,
            "Name": "Person"
        },
        {
            "Confidence": 99.05677795410156,
            "Name": "Human"
        },
        {
            "Confidence": 57.606666564941406,
            "Name": "Face"
        },
        {
            "Confidence": 57.606666564941406,
            "Name": "Selfie"
        },
        {
            "Confidence": 53.46586227416992,
            "Name": "Hair"
        },
        {
            "Confidence": 53.46586227416992,
            "Name": "Haircut"
        },
        {
            "Confidence": 53.46586227416992,
            "Name": "Portrait"
        },
        {
            "Confidence": 51.43408966064453,
            "Name": "Dimples"
        },
        {
            "Confidence": 51.43408966064453,
            "Name": "Smile"
        },
        {
            "Confidence": 51.38983917236328,
            "Name": "Team"
        },
        {
            "Confidence": 51.38983917236328,
            "Name": "Troop"
        },
        {
            "Confidence": 51.37934112548828,
            "Name": "Head"
        }
    ]
}
</pre>

In addition to the Rekognition output, we add additional metadata to Elasticsearch which includes:

* timestamp
* bucket name
* key name
* imported-by

Please note, proper permissions / roles are required to execute this properly. 
1. 1. 1. 
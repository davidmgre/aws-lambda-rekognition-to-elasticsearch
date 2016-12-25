# aws-rekognition-to-elasticsearch

## Using [AWS Lambda](https://aws.amazon.com/lambda/), analyze images with AWS Rekognition and write the results to Elasticsearch

Images written to a specific S3 bucket and path are scanned for recognizable objects using [AWS Rekognition](https://aws.amazon.com/rekognition/) and loaded to [Amazon Elasticsearch Service](https://aws.amazon.com/elasticsearch-service/) for searching. 

The Rekognition export for a sample image ([AWS Snowmobile](https://aws.amazon.com/snowmobile/)) is below.

The CLI command used is:
<pre>
aws rekognition detect-labels --image '{"S3Object":{"Bucket":"mys3bucket","Name":"snowmobile.jpg"}}'
</pre>

![alt text](https://awsdmg.com/images/snowmobile.jpg "Rekognition Sample Image")


<pre>
{
    "Labels": [
        {
            "Confidence": 96.58794403076172,
            "Name": "Transportation"
        },
        {
            "Confidence": 86.98311614990234,
            "Name": "Trailer Truck"
        },
        {
            "Confidence": 86.98311614990234,
            "Name": "Truck"
        },
        {
            "Confidence": 86.98311614990234,
            "Name": "Vehicle"
        },
        {
            "Confidence": 52.556495666503906,
            "Name": "Engine"
        },
        {
            "Confidence": 52.556495666503906,
            "Name": "Machine"
        },
        {
            "Confidence": 52.556495666503906,
            "Name": "Motor"
        },
        {
            "Confidence": 52.34297561645508,
            "Name": "Tow Truck"
        },
        {
            "Confidence": 51.937294006347656,
            "Name": "Caravan"
        },
        {
            "Confidence": 51.937294006347656,
            "Name": "Van"
        },
        {
            "Confidence": 51.570945739746094,
            "Name": "Car"
        }
    ]
}
</pre>

In addition to the Rekognition output, we add additional metadata to Elasticsearch which includes:

* timestamp 
	* <pre>2016-12-25T22:10:41.983000</pre>
* bucket name
	* <pre>mys3bucket</pre>
* key name
	* <pre>snowmobile.jpg</pre>
* imported-by
	* <pre>lambda-to-es</pre>

Please note, proper permissions / roles are required to execute this properly. 
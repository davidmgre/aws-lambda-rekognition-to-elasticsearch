curl -XPOST "http://search-es-endpoint-here.us-east-1.es.amazonaws.com/images/_search" -d'
{
   "query": {
      "bool": {
         "must": [
            {
               "match": {
                  "s3bucket": "your-s3-bucket"
               }
            },
            {
               "nested": {
                  "path": "Labels",
                  "score_mode": "sum",
                  "query": {
                     "function_score": {
                        "query": {
                           "bool": {
                              "should": [
                                 {
                                    "match": {
                                       "Labels.Name": "People"
                                    }
                                 },
                                 {
                                    "match": {
                                       "Labels.Name": "Nature"
                                    }
                                 }
                              ]
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
}'

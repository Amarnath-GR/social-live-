import json
import boto3
import os
from urllib.parse import unquote_plus

mediaconvert = boto3.client('mediaconvert')

def handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])
        
        input_uri = f's3://{bucket}/{key}'
        output_uri = f's3://{os.environ["OUTPUT_BUCKET"]}/videos/'
        
        job_settings = {
            "Queue": os.environ["MEDIACONVERT_QUEUE"],
            "Role": os.environ["MEDIACONVERT_ROLE"],
            "Settings": {
                "Inputs": [{
                    "FileInput": input_uri,
                    "AudioSelectors": {
                        "Audio Selector 1": {
                            "DefaultSelection": "DEFAULT"
                        }
                    },
                    "VideoSelector": {}
                }],
                "OutputGroups": [
                    {
                        "Name": "HLS",
                        "OutputGroupSettings": {
                            "Type": "HLS_GROUP_SETTINGS",
                            "HlsGroupSettings": {
                                "Destination": f"{output_uri}{key.split('/')[-1].split('.')[0]}/",
                                "SegmentLength": 10,
                                "MinSegmentLength": 0
                            }
                        },
                        "Outputs": [
                            {
                                "NameModifier": "_720p",
                                "VideoDescription": {
                                    "CodecSettings": {
                                        "Codec": "H_264",
                                        "H264Settings": {
                                            "Bitrate": 2000000,
                                            "MaxBitrate": 2000000,
                                            "RateControlMode": "CBR"
                                        }
                                    },
                                    "Width": 1280,
                                    "Height": 720
                                },
                                "AudioDescriptions": [{
                                    "CodecSettings": {
                                        "Codec": "AAC",
                                        "AacSettings": {
                                            "Bitrate": 128000,
                                            "CodingMode": "CODING_MODE_2_0",
                                            "SampleRate": 48000
                                        }
                                    }
                                }],
                                "ContainerSettings": {
                                    "Container": "M3U8"
                                }
                            },
                            {
                                "NameModifier": "_480p",
                                "VideoDescription": {
                                    "CodecSettings": {
                                        "Codec": "H_264",
                                        "H264Settings": {
                                            "Bitrate": 1000000,
                                            "MaxBitrate": 1000000,
                                            "RateControlMode": "CBR"
                                        }
                                    },
                                    "Width": 854,
                                    "Height": 480
                                },
                                "AudioDescriptions": [{
                                    "CodecSettings": {
                                        "Codec": "AAC",
                                        "AacSettings": {
                                            "Bitrate": 96000,
                                            "CodingMode": "CODING_MODE_2_0",
                                            "SampleRate": 48000
                                        }
                                    }
                                }],
                                "ContainerSettings": {
                                    "Container": "M3U8"
                                }
                            },
                            {
                                "NameModifier": "_360p",
                                "VideoDescription": {
                                    "CodecSettings": {
                                        "Codec": "H_264",
                                        "H264Settings": {
                                            "Bitrate": 500000,
                                            "MaxBitrate": 500000,
                                            "RateControlMode": "CBR"
                                        }
                                    },
                                    "Width": 640,
                                    "Height": 360
                                },
                                "AudioDescriptions": [{
                                    "CodecSettings": {
                                        "Codec": "AAC",
                                        "AacSettings": {
                                            "Bitrate": 64000,
                                            "CodingMode": "CODING_MODE_2_0",
                                            "SampleRate": 48000
                                        }
                                    }
                                }],
                                "ContainerSettings": {
                                    "Container": "M3U8"
                                }
                            }
                        ]
                    }
                ]
            }
        }
        
        response = mediaconvert.create_job(**job_settings)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'jobId': response['Job']['Id'],
                'inputUri': input_uri,
                'outputUri': output_uri
            })
        }
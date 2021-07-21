import logging
import sys
import json

# Configure logger
root = logging.getLogger()
if root.handlers:
	for handler in root.handlers:
		root.removeHandler(handler)
logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO, force=True)
logger = logging.getLogger()

def handler(event, context):
	logger.info("Query Lambda invoked.")

	queryParams = event['queryStringParameters']
	query = queryParams['query']

	# Invoke the sagemaker endpoint here
	print("Hello World!")
	print("Query Lambda invoked with query:")
	print(query)

	return {
		'statusCode': 200,
		'isBase64Encoded': False,
		'body': json.dumps({
			'command': "This is a dummy command response."
		})
	}

const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB.DocumentClient({ region: process.env.AWS_REGION });

exports.handler = (event, context, callback) => {
  const params = { TableName: process.env.TABLE_NAME };
  
  dynamodb.scan(params, (err, data) => {
    if (err) {
      console.log(err);
      callback(err);
    } else {
      callback(null, data.Items);
    }
  });
};
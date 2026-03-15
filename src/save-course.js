const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB.DocumentClient({ region: process.env.AWS_REGION });

exports.handler = (event, context, callback) => {
  const item = typeof event.body === 'string' ? JSON.parse(event.body) : event;
  const params = {
    TableName: process.env.TABLE_NAME,
    Item: item
  };
  
  dynamodb.put(params, (err, data) => {
    if (err) {
      console.log(err);
      callback(err);
    } else {
      callback(null, { message: "Course saved successfully" });
    }
  });
};
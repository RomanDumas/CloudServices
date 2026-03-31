const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB.DocumentClient({ region: process.env.AWS_REGION });

const replaceAll = (str, find, replace) => {
  return str.replace(new RegExp(find, 'g'), replace);
};

exports.handler = (event, context, callback) => {
  const body = typeof event.body === 'string' ? JSON.parse(event.body) : event;
  
  const generatedId = replaceAll(body.title, " ", "-").toLowerCase();

  const params = {
    TableName: process.env.TABLE_NAME,
    Item: {
      id: generatedId,
      title: body.title,
      watchHref: `http://www.pluralsight.com/courses/${generatedId}`,
      authorId: body.authorId,
      length: body.length,
      category: body.category
    }
  };
  
  dynamodb.put(params, (err, data) => {
    if (err) {
      console.log(err);
      callback(err);
    } else {
      callback(null, params.Item);
    }
  });
};
const functions = require('firebase-functions');

var admin = require('firebase-admin');

var serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "MY_DATABASE_URL"
});

exports.sendPushNotification = functions.database.ref('/notifications/{receiverId}/{notificationId}').onWrite(event => {

  const data = event.data;
  
  if(data == undefined || !data.val()) { return; }

  const receiverId = event.params.receiverId;
  const notificationId = event.params.notificationId;
    
  const getDeviceTokensPromise = admin.database().ref(`/users/${receiverId}/notificationTokens`).once('value');

  const getMessageTextPromise = admin.database().ref(`/notifications/${receiverId}/${notificationId}/text`).once('value');

  const getSenderPromise = admin.database().ref(`/notifications/${receiverId}/${notificationId}/`).once('value');

  return Promise.all([getDeviceTokensPromise, getSenderPromise, getMessageTextPromise]).then(results => {
   
    const tokensSnapshot = results[0];
    const senderSnapshot = results[1];
    const messageTextData = results[2];
         
    const senderName = senderSnapshot.val().senderName
	         
    if (!tokensSnapshot.hasChildren()) {
      return console.log('There are no notification tokens to send to.');
    }
    
  	const payload = {
      notification: {
        title: `${senderName}`,
        body: messageTextData.val(),
        badge: '1',
      }
    };
    
    var options = {
      priority: "high",
      timeToLive: 60 * 60 * 24,
      mutable_content : true,
      content_available : true,
      category : 'reminder'
    };
        
    const tokens = Object.keys(tokensSnapshot.val());

    return admin.messaging().sendToDevice(tokens, payload, options).then(response => {
    
      console.log(tokens);
    
      const tokensToRemove = [];
      response.results.forEach((result, index) => {

        const error = result.error;
        
        if (error) {
          
          console.error('Failed at sending notification to', tokens[index], error);

          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      
      return Promise.all(tokensToRemove);
      
    });
    
  }); 

});

exports.createMessageNotification = functions.database.ref('/conversations/{conversationId}/{messageId}').onWrite(event => {

   	const data = event.data;
  
  	if(data == undefined || !data.val()) { 
  		return; 
  	}
        
    const messageId = event.params.messageId;
    const getUserIds = admin.database().ref(`/messages/${messageId}/`).once('value');

    return Promise.all([getUserIds]).then(results => {
       	   
       const messageData = results[0];
       
       const senderId = messageData.val().sender;
            
       const currentUserId = messageData.val().receiver;
       
       addNotificationToUserNotificationNode(currentUserId, senderId, messageId);	
       
	});
})


function addNotificationToUserNotificationNode(currentUserId, fromUserId, messageId) {
  
    if(fromUserId == currentUserId) { 
    	return;
    };

    const notificationId = admin.database().ref().push().key;
    
    const getSenderName = admin.database().ref(`/users/${fromUserId}/`).once('value');
    
    const getMessageText = admin.database().ref(`/messages/${messageId}/`).once('value');

        return Promise.all([getSenderName, getMessageText]).then(results => {
        
        	const userSnapshot = results[0]
         	const messageData = results[1]

  		    const senderName = userSnapshot.val().name
            const text = messageData.val().text;
            const timestamp = messageData.val().timestamp;

        	var notificationData = {
        	 senderName: senderName,
   	         senderId: fromUserId,
             timestamp: timestamp,
             text: text,
             isRead: 'false'
            };

            var updates = {};

            updates['/notifications/' + currentUserId + '/' + notificationId] = notificationData;
    
            admin.database().ref().update(updates);
     });
        
}

# Bubble Chat

## Overview:

BubbleChat is a messaging app project using Firebase as a backend, that I built for practice purposes. It allows users to communicate in realtime with their friends. BubbleChat takes advantage of Google's Cloud Functions (NodeJS) for the server-side code, and FCM for the Push Notifications that can be fired to one or multiple devices.

## Dependencies:

* Swift 4.0.
* Javascript (NodeJS).

## Tools:

* Xcode.
* Adobe Illustrator.

## Main Features:

* Chat with other users in realtime.
* Use of the popular MVC pattern (separating app model, views and controllers).
* Cloud Functions to perform all the server-side processing (nodeJS).
* FCM used to distribute messages/campaigns to the app devices.
* iOS UserNotifications framework to support the delivery of local and remote notifications.
* Firebase used to create and log in user accounts.
* Firebase Database to store user data.
* Firebase Storage to store user profile picture.
* Use of Storyboard References feature to split storyboards in smaller sets.
* User Defaults Database to save locally user's personal information and preferences.

## Screenshots:

<inline><img src="https://user-images.githubusercontent.com/29719383/30265803-4317789e-9718-11e7-83ca-855c09bbb99a.PNG" width="240">
<img src="https://user-images.githubusercontent.com/29719383/30265796-40abb8b8-9718-11e7-9630-d53fb54291b0.PNG" width="240"><img src="https://user-images.githubusercontent.com/29719383/30265801-40fa4ac8-9718-11e7-9079-7c7a668c039b.PNG" width="240"><img src="https://user-images.githubusercontent.com/29719383/30265798-40e25efe-9718-11e7-9397-d6dc95d82913.PNG" width="240"><img src="https://user-images.githubusercontent.com/29719383/30265800-40ea6efa-9718-11e7-8f66-31e164e1d7cb.PNG" width="240">
<img src="https://user-images.githubusercontent.com/29719383/30265799-40e76124-9718-11e7-8697-ecfafe6822d7.PNG" width="240">
<inline>

## Previews:

<inline><img src="https://user-images.githubusercontent.com/29719383/30265829-60d36398-9718-11e7-8d5a-bba508465eb7.gif" width="240">
<img src="https://user-images.githubusercontent.com/29719383/30265831-6111a96e-9718-11e7-99bd-c0414c10a990.gif" width="240"><img src="https://user-images.githubusercontent.com/29719383/30265830-610c3722-9718-11e7-9294-736c722bb7b3.gif" width="240">
<inline>

## Database Structure:

Here is an overview of the database structure that I used for this project :

```
root/
|___ users/
|      |___ userID1
|              |___ name : user_name
|              |___ email : user_email
|              |___ picUrl : user_picture_url
|              |___ conversations
|                       |___ conversationID1 : true
|                             |___ text : last_message_text
|                             |___ senderId : last_message_sender_id
|                             |___ receiverId : last_message_receiver_id
|                             |___ timestamp : last_message_timestamp
|                       |___ conversationID2 : true
|                       |___ conversationID3 : true
|                        ...
|              |___ notificationTokens
|                       |___ token1 : true                       
|                       |___ token2 : true
|                        ...
|
|___ conversation_messages/
|      |___ conversationID1
|              |___ messageID1
|                   |___ text : message_text
|                   |___ senderId : message_sender_id
|                   |___ receiverId : message_receiver_id
|                   |___ timestamp : message_timestamp
|                    ...
|      ...
|
|
|___ notifications/
|      |___ receiverID
|     		 |___ notificationID1
|             		 |___ isRead : false/true
|                      |___ senderId : notification_sender_id
|                      |___ senderName : notification_sender_name
|                      |___ text : notification_text
|                      |___ timestamp : notification_timestamp
|                    	  ...
|      ...
```

## To dos:

Obviously there are many things that can be improved as it's just a sample project, but I tried as much as possible to follow the best practices to build this app.

Among others, here are a few things that could be easily added to the project:

* Allow conversations filtering/sorting.
* Add more information to user profile (bio, country, etc)
* Improve User Experience
* ...

## How to use:

A few things you need to build this project properly :

* An Apple Developer Account, and the proper APNS Certifcates to make use of Push Notifications on your iOS Device.
* A Firebase Project (drag & Drop your own GoogleService-Info.plist file into your project).
* CocoaPods installed on your computer.
* NodeJS installed on your computer to use Cloud Functions.
* Drag & Drop your own serviceAccountKey.json into the /functions folder.
* Push Notifications and Background Modes switches turned on in your project Capabilities tab, and check that you got your Entitlement file properly generated.

## Compatibility:

This project is mainly written in Swift 4.0 and requires Xcode 8.0 to build and run.

## Author:

Alexandre Linares

## License:

Copyright ©2017 Alexandre Linares

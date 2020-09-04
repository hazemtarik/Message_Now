![Logo](https://github.com/hazemtarik/Message_Now/blob/master/Docs/Logo.png)
### IOS Messenger Application By Swift

Write your own messenger apps and assistants with an easy-to-learn swift!

# About

Message Now is a Swift lightweight framework to build chat applications. It's been designed to be extensible and performant. It's built without MessageKit and any SDK . You can find more details when you download the app.

| [![VideoBlocks](https://github.com/hazemtarik/Message_Now/blob/master/Docs/Login.png)]()  | [![AudioBlocks](https://github.com/hazemtarik/Message_Now/blob/master/Docs/Sign%20Up.png)]() | [![AudioBlocks](https://github.com/hazemtarik/Message_Now/blob/master/Docs/Edit.png)]() |
|:---:|:---:|:---:|

| [![VideoBlocks](https://github.com/hazemtarik/Message_Now/blob/master/Docs/Chats.png)]()  | [![AudioBlocks](https://github.com/hazemtarik/Message_Now/blob/master/Docs/Add%20Friend.png)]() |
|:---:|:---:|

| [![VideoBlocks](https://github.com/hazemtarik/Message_Now/blob/master/Docs/Dark.png)]()  | [![AudioBlocks](https://github.com/hazemtarik/Message_Now/blob/master/Docs/Light.png)]() |
|:---:|:---:|

| [![VideoBlocks](https://github.com/hazemtarik/Message_Now/blob/master/Docs/Requests.png)]()  | [![AudioBlocks](https://github.com/hazemtarik/Message_Now/blob/master/Docs/Sent.png)]() | [![AudioBlocks](https://github.com/hazemtarik/Message_Now/blob/master/Docs/About.png)]() |
|:---:|:---:|:---:|

# Features 

* Firebase realTime.
* Bubble chat.
* Support light and dark mode.
* Clean code without MessageKit SDK.
* Send Voice.
* Send your location or any else.
* send media.
* Seen message
* Send requests and controll of them.
* Blocking users.
* Reset password.
* Change Password.
* Every user has username.
* Change image profile.

# Manually

### Included firebase plist file
1. Clone or download the source code.
2. Run the app "It's already includ firebase plist file".

### Not included firebase plist file
1. Clone or download the source code.
2. Delete the GoogleService-Info.plist in support file.
3. Change bundle identifire in xcode.
4. Create your own project in firebase.
5. Integrate the GoogleService-Info.plist to the support file.
6. Put the below rules in firebase database realtime:
```json
    { 
     "rules": {
        "users": {
      ".indexOn": "username",
      ".read": "auth.uid != null" ,
    	".write": "auth.uid != null"
  			},
      "messages": {
      ".read": "auth.uid != null" ,
    	".write": "auth.uid != null",
        "$uid": {
          "$user_id": {
            ".indexOn": "timestamp"
          }
        }
  			},
          "unread": {
            ".read": "auth.uid != null" ,
    				".write": "auth.uid != null"
				},
      "recent_message": {
      ".indexOn": "timestamp",
      ".read": "auth.uid != null" ,
    	".write": "auth.uid != null"
  			},
      "request_friends": {
      ".read": "auth.uid != null" ,
    	".write": "auth.uid != null"
  			},
      "friends_list": {
      ".read": "auth.uid != null" ,
    	".write": "auth.uid != null"
  			},
          "typing": {
      ".read": "auth.uid != null" ,
    	".write": "auth.uid != null"
  			},
      "blocked_list": {
      ".read": "auth.uid != null" ,
    	".write": "auth.uid != null"
  			}
  	    }
    }
```
    

# Contacts

[Linkedin](https://www.linkedin.com/in/hazemtarik/)


# MyFeed Social Media App

CMSC 23 – Mobile Computing

This project is a social media flutter application connected to Firebase.

## Author
Mark Lewis S. Damalerio

2020-03903

Lab Section: WX-2L

## Features

| Feature          | Description                                                             |
| ----------------- | ------------------------------------------------------------------ |
| Register a new user | Register a new user with the help of Firebase Authentication |
| Log in | Log in the user |
| Log out | Log the user out |
| Update profile | Change user's bio |
| Update password | Update user password |
| View list of public posts | View a list of public posts with pagination |
| View a profile | View a user profile|
| Follow a user | Follow a user (limited to 8 users only) |
| List followers | List user followers |
| List following | List user following |
| Unfollow a user | Unfollow a user |
| Create a post | Create a public post |
| View a post | View post along with its comments |
| Comment on a post | Comment on a post |
| View all of user's posts | View all of user's post with pagination |
| Update a post | Edit a post |
| Remove a post | Remove your own post |


## Instructions
If errors exist in the project, run flutter packages get inside the myfeed folder
```bash
location\project-social-media-application-msdamalerio\myfeed_flutter> flutter packages get
```

Run the program by running the flutter run command inside the myfeed folder
```bash
location\project-social-media-application-msdamalerio\myfeed_flutter> flutter run
```

For VSCode

You can also go to lib/main.dart to run the file without debugging

If you want to test the app on a real device (android), run:
```bash
flutter build apk --release
```
Then install the apk found in build/app/outputs/flutter-apk/app-release.apk


## Challenges Met
One of the biggest challenges throughout the development of this application is the usage of firebase.
I had no idea how to interact with its server and user authentication. 
Luckily, there are a lot of online resources that I can use as a guide in order to understand the interaction
between the application and the server.

Another challenge that I met was the idea of implementing Futures and Streams. I had a hard time
understanding the specifics of how to use them. After watching a lot of tutorials about asynchronous
programming in Flutter, I managed to learn about them.


## Happy Paths
### 1.) Path/Testcase (register user) <br />
To reproduce:<br/>
- From the the login screen, go to sign up screen and create an account. <br/>

Result: <br />
- The registration works if the device has an internet connection and passes the new user authentication.
<br /><br />
<img src="myfeed_flutter/images/signupscreen.png" alt="viewpage" width="300"><br />

### 2.) Path/Testcase (login user) <br />
To reproduce:<br/>
- From the the login screen, log in with the created account. <br/>

Result: <br />
- The user logs in if the device has an internet connection and passes the user authentication.
<br /><br />
<img src="myfeed_flutter/images/postscreen.png" alt="viewpage" width="300"><br />

### 3.) Path/Testcase (log out user) <br />
To reproduce:<br/>
- From the the profile screen, click log out. <br/>

Result: <br />
- The user logs out, and the app redirects to the login screen.
<br /><br />
<img src="myfeed_flutter/images/logout.png" alt="viewpage" width="300"><br />

### 4.) Path/Testcase (update user profile) <br />
To reproduce:<br/>
- From the the profile screen, click edit profile, then edit bio. Enter a new bio then submit.<br/>

Result: <br />
- The profile bio changes if there is an internet. Else, it will only change if the user is connected to the internet.
<br /><br />
<img src="myfeed_flutter/images/newbio.png" alt="viewpage" width="300"><br />

### 5.) Path/Testcase (update user password) <br />
To reproduce:<br/>
- From the the profile screen, click edit profile, then change password. Enter a new password then submit.<br/>

Result: <br />
- The password changes if there is an internet. The user will also be redirected to the login screen.
<br /><br />
<img src="myfeed_flutter/images/changepass.png" alt="viewpage" width="300"><br />

### 6.) Path/Testcase (View list of public posts with pagination) <br />
To reproduce:<br/>
- Go to the home screen.<br/>

Result: <br />
- Public posts can be seen with pagination (8 items at a time).
<br /><br />
<img src="myfeed_flutter/images/postscreen.png" alt="viewpage" width="300"><br />

### 7.) Path/Testcase (follow user) <br />
To reproduce:<br/>
- Find another user through the search icon or click their username. Clicking follow will follow user, then clicking unfollow will unfollow the user as long as there is an internet connection
(only 8 users can be followed)<br/>

Result: <br />
- The user will be followed/unfollowed and will reflect on the number of followers/following in your profile.
<br /><br />
<img src="myfeed_flutter/images/followuser.png" alt="viewpage" width="300"><br />

### 8.) Path/Testcase (view following/followers) <br />
To reproduce:<br/>
- Go to your profile and click followers/following<br/>

Result: <br />
- The user will see the list of followers/following on their profile. If there is no internet, the data follower/following list may be outdated, since user is viewing a local copy of list of followers/following.
<br /><br />
<img src="myfeed_flutter/images/followuser.png" alt="viewpage" width="300"><br />

### 9.) Path/Testcase (create post) <br />
To reproduce:<br/>
- Go to post tab, and add a post. Posts without content will be sent to unhappy paths (number 5)<br/>

Result: <br />
- The new post can be viewed in the home screen and profile screen.
<br /><br />
<img src="myfeed_flutter/images/newpost.png" alt="viewpage" width="300"><br />

### 10.) Path/Testcase (view post) <br />
To reproduce:<br/>
- Click on the magnifying glass icon on any post.<br/>

Result: <br />
- The post and its comments will be displayed.
<br /><br />
<img src="myfeed_flutter/images/focuspost.png" alt="viewpage" width="300"><br />

### 11.) Path/Testcase (comment on a post) <br />
To reproduce:<br/>
- Click on the comment icon on any post. Type a comment. Comment without content will be redirected to unhappy path (number 6).<br/>

Result: <br />
- The comment will be added.
<br /><br />
<img src="myfeed_flutter/images/newcomment.png" alt="viewpage" width="300"><br />

### 12.) Path/Testcase (view all comments on a post) <br />
To reproduce:<br/>
- Click on the comment icon on any post.<br/>

Result: <br />
- All comments will be displayed.
<br /><br />
<img src="myfeed_flutter/images/viewcomments.png" alt="viewpage" width="300"><br />

### 13.) Path/Testcase (delete your own comment) <br />
To reproduce:<br/>
- From the comments screen, click the triple dot on the right side of your own comment then click delete.<br/>

Result: <br />
- Comment will be deleted. If there is no internet, path will be redirected to unhappy path (number 7).
<br /><br />

### 14.) Path/Testcase (view follower/following post) <br />
To reproduce:<br/>
- Find the user through search or click their username on their public post to go to their profile.<br/>

Result: <br />
- You can find their posts in their profile with pagination (8 items at a time).
<br /><br />
<img src="myfeed_flutter/images/viewposts.png" alt="viewpage" width="300"><br />

### 15.) Path/Testcase (update post) <br />
To reproduce:<br/>
- On any of your post, click the triple dot on the right and click edit post. Enter a new post and confirm.<br/>

Result: <br />
- Post will be updated. If user does not have connection, this path will be redirected to unhappy path (number 8).
<br /><br />
<img src="myfeed_flutter/images/viewposts.png" alt="viewpage" width="300"><br />

### 16.) Path/Testcase (delete post) <br />
To reproduce:<br/>
- On any of your post, click the triple dot on the right and click delete. <br/>

Result: <br />
- Post will be deleted. If user does not have connection, this path will be redirected to unhappy path (number 9).
<br /><br />
<img src="myfeed_flutter/images/deletepost.png" alt="viewpage" width="300"><br />






## Unhappy Paths
### 1.) Path/Testcase (contacting server without internet connection) <br />
To reproduce:<br/>
- Do server-related transactions without internet. <br/>

Result: <br />
- The transaction will not proceed or might not proceed instantly, a notification about internet will be displayed, along with a bottom snackbar that contains the transaction error.
<br /><br />
<img src="myfeed_flutter/images/nointernet.png" alt="viewpage" width="300"><br />
<br /><br />
<img src="myfeed_flutter/images/interneterrorsnackbar.png" alt="viewpage" width="300"><br />

### 2.) Path/Testcase (register user where email is already taken) <br />
To reproduce:<br/>
- From the the login screen, go to sign up screen and create an account with the same email as a registered user. <br/>

Result: <br />
- The registration will not proceed and the app notifies the user through a snack bar.
<br /><br />
<img src="myfeed_flutter/images/alreadyused.png" alt="viewpage" width="300"><br />

### 3.) Path/Testcase (post without internet) <br />
To reproduce:<br/>
- From the post tab, create post without internet. <br/>

Result: <br />
- Without internet, nothing will happen. But if the internet comes back, the post will be posted.
<br /><br />

### 4.) Path/Testcase (comment without internet) <br />
To reproduce:<br/>
- From a post, comment anything without internet. <br/>

Result: <br />
- Without internet, nothing will happen. But if the internet comes back, the comment will be posted.
<br /><br />

### 5.) Path/Testcase (post without content) <br />
To reproduce:<br/>
- From the post screen, post without any text. <br/>

Result: <br />
- The textfield will prompt that it needs a value.
<br /><br />
<img src="myfeed_flutter/images/postcannotbeempty.png" alt="viewpage" width="300"><br />

### 6.) Path/Testcase (comment without content) <br />
To reproduce:<br/>
- From any post screen, comment without any text. <br/>

Result: <br />
- The textfield will prompt that it needs a value.
<br /><br />
<img src="myfeed_flutter/images/commentcannotbeempty.png" alt="viewpage" width="300"><br />

### 7.) Path/Testcase (delete comment without internet) <br />
To reproduce:<br/>
- From comment screen, delete your own comment without internet. <br/>

Result: <br />
- The comment in your local app will be deleted, but it will only reflect to the database and other users if your device gets an internet connection.
<br /><br />

### 8.) Path/Testcase (edit post without internet) <br />
To reproduce:<br/>
- Edit your post without internet. <br/>

Result: <br />
- The post in your local app will be updated, but it will only reflect to the database and other users if your device gets an internet connection.
<br /><br />

### 9.) Path/Testcase (delete post without internet) <br />
To reproduce:<br/>
- Delete your post without internet. <br/>

Result: <br />
- The post in your local app will be deleted, but it will only reflect to the database and other users if your device gets an internet connection.
<br /><br />

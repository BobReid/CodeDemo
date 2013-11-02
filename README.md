# Robert Reid Code Demo #

This is a simple application meant to demonstrate iOS proficiency.
This application searches Flickr for photos and allows you to download them to a device

## Features ##

- Flikr search
- CoreData model persistence
- AFNetworking integration
- Bandwidth optimization by use of a NSURLCache and filesystem storage
- Flickr search in batches + on demand loading when scrolling to bottom of list 
- Sound MVC design
- Photo share integration to save / email / print / etc.
- Cocoapods package management


## Building ##

### Step 0: Install Cocoapodas ###

```
sudo gem install cocoapods
```

### Step 1: Install Dependencies ###

From project root

```
 pod install
```

### Step 2: Enter API Key in App Delegate ###

Enter a flicker API key in the App delegate

### Step 3: Build & Run ###

Well this part should be self explanatory 

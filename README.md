# VirtualTourist

#### Brief

VirtualTourist is a project *required* to graduate as an *iOS Developer* from the [Udacity](https://www.udacity.com) [iOS Developer Nanodegree](https://www.udacity.com/course/ios-developer-nanodegree--nd003) Program.

Every required iOS projects has a number of [features](#features) that are *required* to for the project to be valid. Those features are shown below in [required features](#required-features). However, the student is free to add any additioinal features that could enhance the app and make it stand out. Those are under [extra features](#extra-features).

Apart from the features, these apps *require* certain technology to be used to conform to the requirements. These technologies are listed in the [technology(#technology) section, more specifically in the [required technology](#required-technology) section. The student is free to use any additional frameworks / libraries or technology to satisfy any of the desired features, these are listed under [extra technology](#extra-technology).

This readme also includes a [design analysis](#design-analysis) section that tells the reader about the thought process behind the app, including the decision making on the technologies used, features added, to the more deep decisions about algoriths and code decisions.

## Index
1. [Overview](#overview)
	- [Description](#description)
	- [Basic Requirements](#basic-requirements)
2. [Features](#features)
	- [Required Features](#required-features)
	- [Extra Features](#extra-features)
3. [Technology](#technology)
	- [Required Technology](#required-technology)
	- [Extra Technology](#extra-technology)
4. [Design Analysis](#design-analysis)
	- [Abstract](#abstract)
	- [Model](#model)
	- [View](#view)
	- [Controller](#controller)
5. [Credits](#credits)
6. [Notes](#notes)

## Overview

### Description

VirtualTourist is an iOS App that allows users to search or select a location from a map and drop a pin. After the pin is dropped, users can tap on the pin and download photos associated with the pin's coordinates.

### Basic Requirements 

VirtualTourist should allow users to navigate a map with the normal map gestures (zooming, moving, rotating), and use a long hold gesture to drop a pin. After said pin is dropped, it should allow users to tap on the pin and with a navigation controller, push to a controller that shows the region of the map and download images with the pins coordinates using the Flickr API.

## Features

### Required Features
- Must have a navigable map
- The state of the map should be persisted (region and zoom)
- Must allow users to use a touch and hold gesture to drop pins
- Must allow users to tap on the pin and navigate to another view controller that shows the region of the pin and start downloading images
- Images must be shown in a collection view
- All images that will be loaded must have a placeholder while they load
- Images must appear as they load in their correct cell
- User should be able to tap on an image and delete it
- The pins and images associated with the pins must be persisted on the phone
- All already downloaded images must be shown instead of redownloaded

### Extra Features
- First time users will have a welcome screen and an instruction that will automatically appear
- Instruction controller that is accessible if the user needs instructions
- Ability to search for a desired location with text
- When user taps on a pin, they have a change to either "travel" or enter "selection mode"
	- Selection mode allows users to select different pins and delete them all by tapping on the trash navigation bar button
	- Travel allows users to go into a view controller and start downloading or retrieving images associated with the pins
- Refreshed UI
- In the photo album view controller: tapping on an image / photo enters into selection mode, allowing users to tap on different images and then using the trash navigation bar button to delete them

## Technology

### Required Technology
- Core Data
	- Used as a database to persist the pins and the images associated with the pins
- User Default
	- Used to persisted the state of the map (current region and span)
- Map Kit
	- The map technology used for the app
- Navigation Controller
	- To navigate between map and album controllers
- Collection View
	- To use as the photo album for the presented photos
- HTTP Requests (URLSession, URLRequest, URL...)
	- To connect to the Flickr API and make the photo requests

### Extra Technology
- Core Location (conveniently included in the MapKit framework)
	- To geocode the text in the users search
- Core Animation
	- To animate text in the instructions view controller
	- To animate the selection of pins and images
	- To add gradient CAGradientLayer into the instructions view controller

## Design Analysis

### Abstract

### Model

### View

### Controller

## Credits

This project is an iOS app required to graduate as an iOS Developer from Udacity, therefore the idea behind it goes to Udacity. However, the code was programmed by me, and the idea behind the extra features and extra technology belongs to me.

## Notes

No notes at this time.

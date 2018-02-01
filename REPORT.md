# Report
**Name:** Jimi Duiveman \
**Student number:** 11023163

## Description
People who are active in the fairly new world of the cryptocurrencies want to be up-to-date all day long. \
Coinr will take care of that!

<img src="https://github.com/jimiduiveman/CryptoApp/blob/master/doc/detail_ethereum.png" width="200">

## Technical Design 

#### Overview
First of all the user will see a page where they can register themselves or login. \
Whenever they've logged in or registered, they will be re-directed to the overview of all cryptocurrencies. \
When a certain coin is tapped, a new page will be shown with some details of this coin. \
Here users can see the price history of the coin and some other details. \
On this page users can also add a transaction that they've made. \
This transaction will be visible under the tab "Trades". \
Furthermore, users can watch their "Portfolio" which will show the current value of their holdings. \
At last, users can also communicate with eachother by messages.

#### Login/Register page
When an user opens the app for the first time they don't have an account yet. \
They can register themselves with an emailaddress and a password. \
If it isn't the first time opening the app, users can login with their credentials. \
All of this will be checked against data stored in Firebase.

#### Cryptocurrencies page
Whenever the user has succefully logged in, they will be redirected to the homepage.\
An overview of all cryptocurrencies, with their current price and 24h change.\
This data is being retrieved from the coinmarketcap API and transformed into objects of type "Coin".\
The page has two different tabs, "all" and "favorites", the last one will hold your personal favorite coins.\
Personal favorites will be stored by simply using their symbol as a string.\
To load the correct favorite coins, all symbols stored in Firebase will be checked against all objects of type "Coin".

#### Detail page
Users can select a coin from the overview, which will bring them to a detail page. \
The detail page will show the current price, 24h change, 7d change, price history, marketcap and the available supply. \
Users can interact with the chart that shows the price history by hovering over it. \
All data comes from the "Coin" object, except for the price history. \
The price history comes from the cryptocompare API and can be retrieved for different time periods. \
Furthermore, at the bottom of the detail page users find an "Add Transaction" button.

#### Add Transaction page
When users want to add a transaction and they've clicked the button, they will be redirected to this page. \
On top of the page users can select "Buy" or "Sell" with a segmented control.\
After that there are two textfields, one for the price and one for the amount.\
When filling in these two textfields, a total will be calculated and updated on change in textfields.\
After that users can add the transaction, which will trigger a function that creates an new object of type "Trade".\
This object will store the symbol, buy price, total price, amount, timestamp and type of transaction.\
When the new "Trade" object is created, it will be saved to Firebase.

#### Trades page
On this page the user can see all of their added transactions, most recent at top.\
All trades are loaded from Firebase and transformed to a list of objects of type "Trade".\
These are loaded into the tableview and can also be removed from it by swiping left on the specific cell.\
This will trigger two events, removing it from the tableview and removing it from Firebase.

#### Social page
Here, users can communicate with eachother by messages.\
Messages are created in two ways, by users and by adding transactions.\
When the user creates a message, they create an object of type "Message".\
This object will hold the message, user who's written it and the timestamp.\
When a transaction has been added, an automatically message will be created.\
This object, also of type "Message", will hold the coin, the user and the timestamp of the transaction.\
All of this messages are stored in Firebase and will be loaded into the tableview, most recent at top.\
Whenever the number of messages in Firebase reaches more than 25, the oldest one will be deleted.

#### Portfolio page
Final but most important page, users can track their portfolio value and holdings.\
The calculations are based on all the user's "Trade" objects and the current price of the "Coin" objects.\
Current holding are shown in the tableView with the amount, current price and total value.\
Also a pie chart will be created based on the current value of your holdings, to visualize things.

## Challenges

#### Subject
My very first challenge was determining the subject of my application.\
I had no clue untill 5 pm, but finally had a great idea.

#### Theme
When I started building my app I encountered a problem regarding the theme.\
I had a really fine idea for the detail page with regards to the price history chart.\
But that design didn't fit well into the overall design.\
So I switched from a light theme to a completely dark theme for the app.

#### Building
I also encountered a problem when making a search function.\
The search function must work with two different tableviews, connected by a segmented control.\
I already implemented the two tableViewControllers, but I had to change it to one viewController.\
In this viewController I had to manually put in the two different tableViews.\
This caused a lot of work, especially because I already had it working without the search function.

#### Values and calculations
Another problem was the calculation of trades.\
When users put in the price and the amount, I wanted to calculate the total order value live.\
There also is a difference between a "," and "." when calculating.\
These two constraints made it difficult to implement the feature.

#### User Experience
In general, I've made a lot of changes regarding the UI.\
My goal was to create a simple but elegant application.\
When creating and using the app, you'll notice a lot of things where of you think "mwahhh".\
These things need to change, it must be perfect!

## Decisions

All changes made during the development are based on thoughtful decisions.\
Changing from a light theme to a dark theme, was a great decision.\
Not only because the overall design, but I discovered that white text on a black background is easier to the eyes.\
Especially when watching it at night and the marktet of cryptocurrencies goes on al night.\
Furthermore, I think the decision to use a simple design was a good one.\
All the data and different kinds of data are already complicated enough, so the design must be simple.\
This makes it an app that is great to use!



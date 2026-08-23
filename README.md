# Alegre Allen B.
## INF231
## CTADMOBL Advanced Mobile Programming

## Lab Activity Instance

## Lab Activity 1: setState keeps state isolated inside a single widget. To share data with child widgets, you have to pass parameters down manually ("prop drilling"). Whenever state changes, the entire widget and its subtree rebuild. Meanwhile the provider makes state accessible across the entire widget tree. Any widget anywhere below the provider can read or update the data directly without passing props. Whenever state changes, only the specific widgets listening to that data rebuild.

## Lab Activity 2: The Product model turns API JSON into objects, ProductService fetches that JSON from the /products endpoint and returns Product instances, and ProductScreen asks the service (via a FutureBuilder) to get and display those products in a searchable grid, then navigates to ProductDetailsScreen with the tapped Product. This split (model → service → view) keeps networking, data parsing, and UI separate so each part is easier to change or test.

## Lab Activity 3: discussion
The cart models convert DummyJSON data into Dart objects. CartService handles API requests, converts JSON, manages errors, and performs cart actions. CartScreen displays the logged-in user’s cart. When an item is selected, the app gets its full product details and opens the product details screen. Users can also add products using the cart API.

## Lab Activity 4: discussion
The user model stores login information, while UserService handles login and saves the user’s details locally. SplashScreen checks whether a user is already logged in and opens the correct screen. SignInScreen manages login, and ProfileScreen displays the user’s information. Logging out clears the saved data. The user ID is also sent to CartScreen, so each user sees their own cart instead of a hardcoded cart.


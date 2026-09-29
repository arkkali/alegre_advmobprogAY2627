# Alegre Allen B.
## INF231
## CTADMOBL Advanced Mobile Programming

## Lab Activity Instance

## Lab Activity 1: setState keeps state isolated inside a single widget. To share data with child widgets, you have to pass parameters down manually ("prop drilling"). Whenever state changes, the entire widget and its subtree rebuild. Meanwhile the provider makes state accessible across the entire widget tree. Any widget anywhere below the provider can read or update the data directly without passing props. Whenever state changes, only the specific widgets listening to that data rebuild.

## Lab Activity 2: The Product model turns API JSON into objects, ProductService fetches that JSON from the /products endpoint and returns Product instances, and ProductScreen asks the service (via a FutureBuilder) to get and display those products in a searchable grid, then navigates to ProductDetailsScreen with the tapped Product. This split (model → service → view) keeps networking, data parsing, and UI separate so each part is easier to change or test.

## Lab Activity 3: The cart models convert DummyJSON data into Dart objects. CartService handles API requests, converts JSON, manages errors, and performs cart actions. CartScreen displays the logged-in user’s cart. When an item is selected, the app gets its full product details and opens the product details screen. Users can also add products using the cart API.

## Lab Activity 4: The user model stores login information, while UserService handles login and saves the user’s details locally. SplashScreen checks whether a user is already logged in and opens the correct screen. SignInScreen manages login, and ProfileScreen displays the user’s information. Logging out clears the saved data. The user ID is also sent to CartScreen, so each user sees their own cart instead of a hardcoded cart.

## Lab Activity 5: The application supports two authentication workflows: DummyJSON authenticates a username and password via an external endpoint to populate the local user model, whereas Firebase uses email/password authentication where sign-up creates a managed account, stores extra profile fields (e.g., name, age, contact) in Cloud Firestore under the user's UID, and automatically restores persistent sessions upon app relaunch. The UserService serves as the core abstraction layer that decouples authentication and account-management logic from Flutter UI widgets, handling sign-in, account creation, profile loading, reauthentication for sensitive actions, and account deletion. Ultimately, integrating Firebase benefits the Flutter application by providing managed accounts, persistent state, token refreshes, and Firestore security rules out of the box, eliminating the need to build custom credential storage in the app.

## Lab Activity 6: Discussion

Firestore stores registered users in the `userProfiles` collection. Each direct conversation uses a deterministic document ID built from the two participant Firebase UIDs, and its messages are stored in the nested `messages` collection under that chat document. Each message contains the sender ID, receiver ID, text, timestamp, and delivery status.

The chat list excludes the currently logged-in user, so a user cannot normally start a conversation with themselves. The chat service also rejects a self-chat when both participant IDs are equal. This prevents ambiguous sender and receiver behavior.

The chat service separates Firestore reads and writes from the widgets. The chat list loads registered users and filters them by name, username, or email. The chat detail screen listens for messages in real time, sends new messages, updates sending and delivered states, marks received messages as seen, and animates message bubbles.


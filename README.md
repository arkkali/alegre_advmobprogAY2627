# Alegre Allen B.
## INF231
## CTADMOBL Advanced Mobile Programming

## Lab Activity Instance

## Lab Activity 1: setState keeps state isolated inside a single widget. To share data with child widgets, you have to pass parameters down manually ("prop drilling"). Whenever state changes, the entire widget and its subtree rebuild. Meanwhile the provider makes state accessible across the entire widget tree. Any widget anywhere below the provider can read or update the data directly without passing props. Whenever state changes, only the specific widgets listening to that data rebuild.

## Lab Activity 2: The Product model turns API JSON into objects, ProductService fetches that JSON from the /products endpoint and returns Product instances, and ProductScreen asks the service (via a FutureBuilder) to get and display those products in a searchable grid, then navigates to ProductDetailsScreen with the tapped Product. This split (model → service → view) keeps networking, data parsing, and UI separate so each part is easier to change or test.
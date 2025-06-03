// Pizza related types
type Pizza record {|
    int id;
    string name;
    string description;
    float price;
    string[] toppings;
|};

// Order related types
type OrderRequest record {|
    int pizzaId;
    int quantity;
    string customerName;
    string? specialInstructions = ();
|};

type OrderStatus "PENDING"|"PREPARING"|"READY"|"DELIVERED";

type Order record {|
    int id;
    int pizzaId;
    int quantity;
    string customerName;
    OrderStatus status;
    float totalPrice;
|};

type ErrorDetails record {|
    string message;
|};
import ballerina/http;
import ballerina/log;
import ballerinax/wso2.controlplane as _;

// In-memory storage
final map<Pizza> pizzaDb = {};
final map<Order> orderDb = {};

// Initialize some sample pizzas
function init() {
    pizzaDb["1"] = {
        id: 1,
        name: "Margherita",
        description: "Classic tomato and mozzarella",
        price: 10.99,
        toppings: ["tomato", "mozzarella", "basil"]
    };
    pizzaDb["2"] = {
        id: 2,
        name: "Pepperoni",
        description: "Spicy pepperoni with cheese",
        price: 12.99,
        toppings: ["tomato", "mozzarella", "pepperoni"]
    };
}

service /v1 on new http:Listener(8080) {
    // List all pizzas
    resource function get pizzas() returns Pizza[]|error {
        return pizzaDb.toArray();
    }

    // Get pizza by ID
    resource function get pizzas/[int pizzaId]() returns Pizza|http:NotFound {
        string pizzaIdString = pizzaId.toString();
        Pizza? pizza = pizzaDb[pizzaIdString];
        if pizza is () {
            log:printError(string `Pizza not found for ID: ${pizzaId}`);
            return http:NOT_FOUND;
        }
        return pizza;
    }

    // Create new order
    resource function post orders(@http:Payload OrderRequest orderRequest) returns Order|http:BadRequest {
        string pizzaIdString = orderRequest.pizzaId.toString();
        Pizza? pizza = pizzaDb[pizzaIdString];
        if pizza is () {
            log:printError(string `Cannot create order. Pizza not available for ID: ${orderRequest.pizzaId}`);
            return http:BAD_REQUEST;
        }

        int orderId = orderDb.length() + 1;
        string orderIdString = orderId.toString();

        Order newOrder = {
            id: orderId,
            pizzaId: orderRequest.pizzaId,
            quantity: orderRequest.quantity,
            customerName: orderRequest.customerName,
            status: "PENDING",
            totalPrice: pizza.price * orderRequest.quantity
        };

        orderDb[orderIdString] = newOrder;

        return newOrder;
    }

    // Get order status
    resource function get orders/[int orderId]() returns Order|http:NotFound {
        string orderIdString = orderId.toString();
        Order? 'order = orderDb[orderIdString];
        if 'order is () {
            return http:NOT_FOUND;
        }
        return 'order;
    }
}

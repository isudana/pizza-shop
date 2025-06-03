import ballerina/http;
import ballerina/test;

final http:Client clientEp = check new ("http://localhost:8080/v1");

// Helper function to initialize test data
@test:BeforeSuite
function beforeSuite() returns error? {
    // Test data initialization is handled by the service's init() function
}

// Test Scenario 1.1: List all pizzas (Happy Path)
@test:Config {}
function testListAllPizzas() returns error? {
    // Send request to get all pizzas
    Pizza[] response = check clientEp->/pizzas;
    
    // Validate response
    test:assertEquals(response.length(), 2, "Expected 2 pizzas in the response");
    
    // Validate first pizza
    test:assertEquals(response[0].id, 1, "First pizza should have ID 1");
    test:assertEquals(response[0].name, "Margherita", "First pizza should be Margherita");
    test:assertEquals(response[0].price, 10.99, "First pizza should cost 10.99");
    
    // Validate second pizza
    test:assertEquals(response[1].id, 2, "Second pizza should have ID 2");
    test:assertEquals(response[1].name, "Pepperoni", "Second pizza should be Pepperoni");
    test:assertEquals(response[1].price, 12.99, "Second pizza should cost 12.99");
}

// Test Scenario 2.1: Get pizza by valid ID (Happy Path)
@test:Config {
    dependsOn: [testListAllPizzas]
}
function testGetPizzaById() returns error? {
    Pizza response = check clientEp->/pizzas/[1];
    
    test:assertEquals(response.id, 1, "Pizza ID should be 1");
    test:assertEquals(response.name, "Margherita", "Pizza name should be Margherita");
    test:assertEquals(response.description, "Classic tomato and mozzarella", "Pizza description mismatch");
    test:assertEquals(response.price, 10.99, "Pizza price should be 10.99");
}

// Test Scenario 2.2: Get pizza by invalid ID (Error Path)
@test:Config {
    dependsOn: [testListAllPizzas]
}
function testGetPizzaByInvalidId() returns error? {
    http:Response response = check clientEp->/pizzas/[999];
    test:assertEquals(response.statusCode, 404, "Expected 404 status code for non-existent pizza");
}

// Test Scenario 3.1: Create order with valid pizza ID (Happy Path)
@test:Config {
    dependsOn: [testListAllPizzas]
}
function testCreateValidOrder() returns error? {
    OrderRequest orderRequest = {
        pizzaId: 1,
        quantity: 2,
        customerName: "John Doe"
    };
    
    Order response = check clientEp->/orders.post(orderRequest);
    
    test:assertEquals(response.id, 1, "First order should have ID 1");
    test:assertEquals(response.pizzaId, 1, "Order should reference pizza ID 1");
    test:assertEquals(response.quantity, 2, "Order quantity should be 2");
    test:assertEquals(response.customerName, "John Doe", "Customer name should match");
    test:assertEquals(response.status, "PENDING", "Initial order status should be PENDING");
    test:assertEquals(response.totalPrice, 21.98, "Total price should be 21.98 (10.99 * 2)");
}

// Test Scenario 3.2: Create order with invalid pizza ID (Error Path)
@test:Config {
    dependsOn: [testListAllPizzas]
}
function testCreateOrderInvalidPizza() returns error? {
    OrderRequest orderRequest = {
        pizzaId: 999,
        quantity: 1,
        customerName: "Jane Doe"
    };
    
    http:Response response = check clientEp->/orders.post(orderRequest);
    test:assertEquals(response.statusCode, 400, "Expected 400 status code for invalid pizza ID");
}

// Test Scenario 4.1: Get order by valid ID (Happy Path)
@test:Config {
    dependsOn: [testCreateValidOrder]
}
function testGetOrderById() returns error? {
    Order response = check clientEp->/orders/[1];
    
    test:assertEquals(response.id, 1, "Order ID should be 1");
    test:assertEquals(response.pizzaId, 1, "Order should reference pizza ID 1");
    test:assertEquals(response.quantity, 2, "Order quantity should be 2");
    test:assertEquals(response.customerName, "John Doe", "Customer name should match");
    test:assertEquals(response.status, "PENDING", "Order status should be PENDING");
}

// Test Scenario 4.2: Get order by invalid ID (Error Path)
@test:Config {
    dependsOn: [testCreateValidOrder]
}
function testGetOrderByInvalidId() returns error? {
    http:Response response = check clientEp->/orders/[999];
    test:assertEquals(response.statusCode, 404, "Expected 404 status code for non-existent order");
}